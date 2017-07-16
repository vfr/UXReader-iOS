//
//	UXReaderPageScrollView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageScrollView.h"
#import "UXReaderPageImageView.h"
#import "UXReaderPageTiledView.h"
#import "UXReaderTiledLayer.h"
#import "UXReaderSelection.h"
#import "UXReaderFramework.h"

@interface UXReaderPageScrollView () <UIScrollViewDelegate, UXReaderPageTiledViewDelegate>

@end

@implementation UXReaderPageScrollView
{
	UIView *contentView;

	UXReaderPageImageView *pageImageViewA, *pageImageViewB;

	UXReaderPageTiledView *pageTiledViewA, *pageTiledViewB;

	NSMutableDictionary<NSNumber *, UXReaderPageTiledView *> *tiledViews;

	CGFloat realMaximumZoom, tempMaximumZoom; CGFloat zoomFactor;

	BOOL showRTL; BOOL zoomBounced;
}

#pragma mark - Properties

@synthesize message;

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.autoresizesSubviews = NO; self.delaysContentTouches = NO;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];
		self.showsHorizontalScrollIndicator = NO; self.showsVerticalScrollIndicator = NO;
		self.scrollsToTop = NO; self.delegate = self; // UIScrollViewDelegate

		tiledViews = [[NSMutableDictionary alloc] init]; zoomFactor = 2.0;
	}

	return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document page:(NSUInteger)page
{
	//NSLog(@"%s %@ %@ %i", __FUNCTION__, NSStringFromCGRect(frame), document, int(page));

	if ((self = [self initWithFrame:frame])) // Initialize self
	{
		if ((document != nil) && (page < [document pageCount])) // Single page
		{
			showRTL = [document showRTL]; //[self setPage:page];

			[self openPage:page document:document];
		}
		else // On failure
		{
			self = nil;
		}
	}

	return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document pages:(nonnull NSIndexSet *)pages
{
	//NSLog(@"%s %@ %@ %@", __FUNCTION__, NSStringFromCGRect(frame), document, pages);

	if ((self = [self initWithFrame:frame])) // Initialize self
	{
		if ((document != nil) && (pages != nil)) // Open double page
		{
			showRTL = [document showRTL]; //[self setPages:pages];

			[self openPages:pages document:document];
		}
		else // On failure
		{
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

- (void)setFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	[super setFrame:frame];

	if (CGSizeEqualToSize(self.contentSize, CGSizeZero) == false)
	{
		const CGFloat oldMinimumZoomScale = self.minimumZoomScale;

		[self updateMinimumMaximumZoom];

		CGFloat zoomScale = self.zoomScale;

		if (zoomScale == oldMinimumZoomScale)
		{
			zoomScale = self.minimumZoomScale;
		}
		else // Check against minimum zoom scale
		{
			if (zoomScale < self.minimumZoomScale)
			{
				zoomScale = self.minimumZoomScale;
			}
			else // Check against maximum zoom scale
			{
				if (zoomScale > self.maximumZoomScale)
				{
					zoomScale = self.maximumZoomScale;
				}
			}
		}

		if (zoomScale == self.zoomScale)
			[self centerScrollViewContent];
		else
			self.zoomScale = zoomScale;
	}
}

#pragma mark - UXReaderPageScrollView instance methods

- (void)openPage:(NSUInteger)page document:(nonnull UXReaderDocument *)document
{
	//NSLog(@"%s %i %@", __FUNCTION__, int(page), document);

	const CGSize pageSize = [document pageSize:page]; CGRect rect = CGRectZero; rect.size = pageSize;

	if ((pageImageViewA = [[UXReaderPageImageView alloc] initWithFrame:rect document:document page:page]))
	{
		if ((pageTiledViewA = [[UXReaderPageTiledView alloc] initWithFrame:rect document:document page:page]))
		{
			[pageImageViewA addSubview:pageTiledViewA]; [self addSubview:pageImageViewA];

			contentView = pageImageViewA; pageTiledViewA.delegate = self;

			[tiledViews setObject:pageTiledViewA forKey:@(page)];

			self.contentSize = pageSize; [self updateMinimumMaximumZoom];

			if (self.minimumZoomScale != self.zoomScale)
				self.zoomScale = self.minimumZoomScale;
			else
				[self centerScrollViewContent];
		}
	}
}

- (void)openPages:(nonnull NSIndexSet *)pages document:(nonnull UXReaderDocument *)document
{
	//NSLog(@"%s %@ %@", __FUNCTION__, pages, document);

	if ([pages count] == 2) // Handle showing two pages side-by-side
	{
		const NSUInteger pageA = (showRTL ? [pages lastIndex] : [pages firstIndex]);
		const NSUInteger pageB = (showRTL ? [pages firstIndex] : [pages lastIndex]);

		if ((pageA < [document pageCount]) && (pageB < [document pageCount])) // Carry on
		{
			CGRect rectA = CGRectZero; const CGSize pageSizeA = [document pageSize:pageA];
			CGRect rectB = CGRectZero; const CGSize pageSizeB = [document pageSize:pageB];

			const CGFloat ch = ((pageSizeA.height > pageSizeB.height) ? pageSizeA.height : pageSizeB.height);

			const CGFloat gap = 2.0; const CGFloat cw = (pageSizeA.width + gap + pageSizeB.width);

			rectA.size = pageSizeA; rectB.size = pageSizeB;

			rectA.origin.y = floor((ch - rectA.size.height) * 0.5);
			rectB.origin.y = floor((ch - rectB.size.height) * 0.5);

			rectB.origin.x += (rectA.size.width + gap); rectA.origin.x = 0.0;

			const CGRect contentRect = CGRectMake(0.0, 0.0, cw, ch); // Content rect

			if ((contentView = [[UIView alloc] initWithFrame:contentRect])) // View hierarchy
			{
				contentView.backgroundColor = [UIColor clearColor]; contentView.contentMode = UIViewContentModeRedraw;
				contentView.userInteractionEnabled = NO; //contentView.translatesAutoresizingMaskIntoConstraints = YES;
				contentView.autoresizesSubviews = NO; //contentView.opaque = NO; contentView.hidden = YES;

				pageImageViewA = [[UXReaderPageImageView alloc] initWithFrame:rectA document:document page:pageA];
				pageTiledViewA = [[UXReaderPageTiledView alloc] initWithFrame:rectA document:document page:pageA];

				pageImageViewB = [[UXReaderPageImageView alloc] initWithFrame:rectB document:document page:pageB];
				pageTiledViewB = [[UXReaderPageTiledView alloc] initWithFrame:rectB document:document page:pageB];

				if (pageImageViewA && pageTiledViewA && pageImageViewB && pageTiledViewB) // Stack views
				{
					[contentView addSubview:pageImageViewA]; [contentView addSubview:pageImageViewB];
					[contentView addSubview:pageTiledViewA]; [contentView addSubview:pageTiledViewB];

					[self addSubview:contentView];

					[tiledViews setObject:pageTiledViewA forKey:@(pageA)];
					[tiledViews setObject:pageTiledViewB forKey:@(pageB)];

					pageTiledViewA.delegate = self; pageTiledViewB.delegate = self;

					self.contentSize = contentRect.size; [self updateMinimumMaximumZoom];

					if (self.minimumZoomScale != self.zoomScale)
						self.zoomScale = self.minimumZoomScale;
					else
						[self centerScrollViewContent];
				}
			}
		}
	}
	else if ([pages count] == 1) // One page
	{
		const NSUInteger pageA = [pages firstIndex];

		if (pageA < [document pageCount]) // Carry on
		{
			const CGSize pageSizeA = [document pageSize:pageA];

			const CGFloat ch = pageSizeA.height; const CGFloat gap = 2.0;

			const CGFloat cw = (pageSizeA.width + gap + pageSizeA.width);

			CGRect rectA = CGRectZero; rectA.size = pageSizeA;

			if (showRTL == YES) rectA.origin.x += (rectA.size.width + gap);

			const CGRect contentRect = CGRectMake(0.0, 0.0, cw, ch); // Content rect

			if ((contentView = [[UIView alloc] initWithFrame:contentRect])) // View hierarchy
			{
				contentView.backgroundColor = [UIColor clearColor]; contentView.contentMode = UIViewContentModeRedraw;
				contentView.userInteractionEnabled = NO; //contentView.translatesAutoresizingMaskIntoConstraints = YES;
				contentView.autoresizesSubviews = NO; //contentView.opaque = NO; contentView.hidden = YES;

				pageImageViewA = [[UXReaderPageImageView alloc] initWithFrame:rectA document:document page:pageA];
				pageTiledViewA = [[UXReaderPageTiledView alloc] initWithFrame:rectA document:document page:pageA];

				if ((pageImageViewA != nil) && (pageTiledViewA != nil)) // Stack views
				{
					[contentView addSubview:pageImageViewA]; [contentView addSubview:pageTiledViewA];

					[self addSubview:contentView]; pageTiledViewA.delegate = self;

					[tiledViews setObject:pageTiledViewA forKey:@(pageA)];

					self.contentSize = contentRect.size; [self updateMinimumMaximumZoom];

					if (self.minimumZoomScale != self.zoomScale)
						self.zoomScale = self.minimumZoomScale;
					else
						[self centerScrollViewContent];
				}
			}
		}
	}
}

- (void)centerScrollViewContent
{
	//NSLog(@"%s", __FUNCTION__);

	CGFloat iw = 0.0; CGFloat ih = 0.0; // Content width and height insets

	const CGSize boundsSize = self.bounds.size; const CGSize contentSize = self.contentSize;

	if (contentSize.width < boundsSize.width) iw = ((boundsSize.width - contentSize.width) * 0.5);

	if (contentSize.height < boundsSize.height) ih = ((boundsSize.height - contentSize.height) * 0.5);

	const UIEdgeInsets insets = UIEdgeInsetsMake(ih, iw, ih, iw); // Create (possibly new) content insets

	if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, insets) == false) self.contentInset = insets;
}

- (void)updateMinimumMaximumZoom
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat zoomLevels = [UXReaderTiledLayer maximumZoom]; // Zoom levels

	const CGFloat zoomScale = UXScaleThatFits(self.bounds.size, contentView.bounds.size);

	self.minimumZoomScale = zoomScale; self.maximumZoomScale = (zoomScale * zoomLevels);

	realMaximumZoom = self.maximumZoomScale; tempMaximumZoom = (realMaximumZoom * zoomFactor);
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(center));

	CGRect zoomRect = CGRectZero; // Centered zoom rect

	zoomRect.size.width = (self.bounds.size.width / scale);
	zoomRect.size.height = (self.bounds.size.height / scale);

	zoomRect.origin.y = (center.y - (zoomRect.size.height * 0.5));
	zoomRect.origin.x = (center.x - (zoomRect.size.width * 0.5));

	return zoomRect;
}

- (void)zoomIncrement:(nonnull UITapGestureRecognizer *)recognizer
{
	//NSLog(@"%s %@", __FUNCTION__, recognizer);

	CGFloat zoomScale = self.zoomScale; // Current zoom

	const CGPoint point = [recognizer locationInView:contentView];

	if (zoomScale < self.maximumZoomScale) // Zoom in
	{
		zoomScale *= zoomFactor; // Zoom in by zoom factor amount

		if (zoomScale > self.maximumZoomScale) zoomScale = self.maximumZoomScale;

		const CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];

		[self zoomToRect:zoomRect animated:YES]; // Zoom zoom
	}
	else // Handle fully zoomed in
	{
		if (zoomBounced == NO) // Zoom bounce
		{
			self.maximumZoomScale = tempMaximumZoom;

			[self setZoomScale:tempMaximumZoom animated:YES];
		}
		else // Zoom all the way back out
		{
			zoomScale = self.minimumZoomScale;

			[self setZoomScale:zoomScale animated:YES];
		}
	}
}

- (void)zoomDecrement:(nonnull UITapGestureRecognizer *)recognizer
{
	//NSLog(@"%s %@", __FUNCTION__, recognizer);

	CGFloat zoomScale = self.zoomScale; // Current zoom

	const CGPoint point = [recognizer locationInView:contentView];

	if (zoomScale > self.minimumZoomScale) // Zoom out
	{
		zoomScale /= zoomFactor; // Zoom out by zoom factor amount

		if (zoomScale < self.minimumZoomScale) zoomScale = self.minimumZoomScale;

		const CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];

		[self zoomToRect:zoomRect animated:YES]; // Zoom zoom
	}
	else // Handle fully zoomed out
	{
		zoomScale = self.maximumZoomScale; // Full zoom in

		const CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];

		[self zoomToRect:zoomRect animated:YES];
	}
}

- (void)ensureVisibleSelection:(nonnull UXReaderSelection *)selection
{
	//NSLog(@"%s %@", __FUNCTION__, selection);

	if (UXReaderPageTiledView *tiledView = tiledViews[@([selection page])])
	{
		const CGRect area = [self convertRect:[selection rectangle] fromView:tiledView];

		[self scrollRectToVisible:area animated:YES];
	}
}

- (CGRect)frameForPage:(NSUInteger)page inView:(nonnull UIView *)inView
{
	//NSLog(@"%s %i %@", __FUNCTION__, int(page), inView);

	CGRect frame = CGRectZero; // Default frame - none

	if (UXReaderPageTiledView *tiledView = tiledViews[@(page)])
	{
		frame = [tiledView convertRect:[tiledView bounds] toView:inView];
	}

	return frame;
}

- (BOOL)containsPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	return (tiledViews[@(page)] != nil);
}

- (void)pageNeedsDisplay
{
	//NSLog(@"%s", __FUNCTION__);

	[pageTiledViewA setNeedsDisplay];

	[pageTiledViewB setNeedsDisplay];
}

- (void)wentOffScreen
{
	//NSLog(@"%s", __FUNCTION__);

	if (self.zoomScale > self.minimumZoomScale) // Reset zoom
	{
		self.zoomScale = self.minimumZoomScale; zoomBounced = NO;
	}
}

- (void)resetZoom
{
	//NSLog(@"%s", __FUNCTION__);

	if (self.zoomScale > self.minimumZoomScale) // Reset zoom - animate
	{
		[self setZoomScale:self.minimumZoomScale animated:YES]; zoomBounced = NO;
	}
}

- (nullable UXReaderAction *)processSingleTap:(nonnull UITapGestureRecognizer *)recognizer
{
	//NSLog(@"%s %@", __FUNCTION__, recognizer);

	UXReaderAction *action = nil;

	if ((pageTiledViewA != nil) && (action == nil))
	{
		action = [pageTiledViewA processSingleTap:recognizer];
	}

	if ((pageTiledViewB != nil) && (action == nil))
	{
		action = [pageTiledViewB processSingleTap:recognizer];
	}

	return action;
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	//NSLog(@"%s %@", __FUNCTION__, scrollView);

	return contentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	//NSLog(@"%s %@ %@ %g", __FUNCTION__, scrollView, view, scale);

	if (self.zoomScale > realMaximumZoom) // Bounce back to real maximum zoom scale
	{
		[self setZoomScale:realMaximumZoom animated:YES]; self.maximumZoomScale = realMaximumZoom; zoomBounced = YES;
	}
	else // Normal -scrollViewDidEndZooming: user interaction handling
	{
		if (self.zoomScale < realMaximumZoom) zoomBounced = NO;
	}
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	//NSLog(@"%s %@", __FUNCTION__, scrollView);

	[self centerScrollViewContent];
}

#pragma mark - UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%s", __FUNCTION__);

	[super touchesBegan:touches withEvent:event];

	[message pageScrollView:self touchesBegan:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%s", __FUNCTION__);

	[super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%s", __FUNCTION__);

	[super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%s", __FUNCTION__);

	[super touchesMoved:touches withEvent:event];
}

#pragma mark - UXReaderPageTiledViewDelegate methods

@end

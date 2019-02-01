//
//	UXReaderPageControl.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageControl.h"
#import "UXReaderPageThumbView.h"

@implementation UXReaderPageControl
{
	UXReaderDocument *document; NSUInteger pageCount;

	UXReaderPageThumbView *trackThumbView; NSUInteger currentPage;

	NSMutableDictionary<NSNumber *, UXReaderPageThumbView *> *thumbViews;

	NSTimer *trackingTimer; NSValue *lastPointValue; BOOL showRTL;

	CGFloat smallThumbWidth, smallThumbHeight, smallThumbSpace;

	CGFloat trackThumbWidth, trackThumbHeight;

	CGFloat wantedControlWidth;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIControl instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = NO; self.exclusiveTouch = YES;

		wantedControlWidth = UIViewNoIntrinsicMetric; currentPage = NSUIntegerMax;

		smallThumbWidth = 22.0; smallThumbHeight = 28.0; smallThumbSpace = 2.0;

		trackThumbWidth = 30.0; trackThumbHeight = 38.0;
	}

	return self;
}

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if ((self = [self initWithFrame:CGRectZero])) // Initialize self
	{
		if (documentx != nil) [self prepare:documentx]; else self = nil;
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (CGSize)intrinsicContentSize
{
	//NSLog(@"%s", __FUNCTION__);

	return CGSizeMake(wantedControlWidth, UIViewNoIntrinsicMetric);
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);

	[self layoutTrackThumbForPage:currentPage]; [self layoutThumbViews];
}

#pragma mark - UXReaderPageControl instance methods

- (void)prepare:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	document = documentx; pageCount = [document pageCount];

	const CGSize size = [[UIScreen mainScreen] bounds].size;

	const CGFloat maximum = ((size.height > size.width) ? size.height : size.width);

	const CGFloat wanted = ((smallThumbWidth + smallThumbSpace) * pageCount);

	wantedControlWidth = ((wanted < maximum) ? wanted : maximum);

	thumbViews = [[NSMutableDictionary alloc] init];

	showRTL = [document showRTL];
}

- (CGPoint)trackThumbCenterForPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	CGPoint center = [self center]; center.y = floor(center.y + 1.0);

	if (pageCount > 1) // Position track thumb for page
	{
		const CGFloat controlWidth = [self bounds].size.width;

		const CGFloat stride = ((controlWidth - trackThumbWidth) / (pageCount - 1));

		center.x = floor((page * stride) + (trackThumbWidth * 0.5));

		if (showRTL == YES) center.x = (controlWidth - center.x);
	}
	else // Default track thumb position
	{
		center.x = floor(trackThumbWidth * 0.5);
	}

	return center;
}

- (void)layoutTrackThumbForPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	if (page < pageCount) // Valid page number
	{
		if (trackThumbView == nil) // Create track thumb view
		{
			const CGRect thumbRect = CGRectMake(0.0, 0.0, trackThumbWidth, trackThumbHeight);

			if ((trackThumbView = [[UXReaderPageThumbView alloc] initWithFrame:thumbRect document:document page:page mini:NO]))
			{
				[trackThumbView setCenter:[self trackThumbCenterForPage:page]]; [self addSubview:trackThumbView];
			}
		}
		else // Update track thumb view
		{
			[trackThumbView setCenter:[self trackThumbCenterForPage:page]];
		}
	}
}

- (nullable UXReaderPageThumbView *)thumbViewForPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	UXReaderPageThumbView *thumbView = thumbViews[@(page)];

	if (thumbView == nil) // Create a new UXReaderPageThumbView and cache it
	{
		const CGRect thumbRect = CGRectMake(0.0, 0.0, smallThumbWidth, smallThumbHeight);

		if ((thumbView = [[UXReaderPageThumbView alloc] initWithFrame:thumbRect document:document page:page mini:YES]))
		{
			thumbViews[@(page)] = thumbView;
		}
	}

	return thumbView;
}

- (void)layoutThumbViews
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat controlWidth = [self bounds].size.width;

	const CGFloat controlHeight = [self bounds].size.height;

	const CGFloat thumbWidth = (smallThumbWidth + smallThumbSpace);

	const NSUInteger thumbs = (controlWidth / thumbWidth);

	const NSUInteger maximumPage = (pageCount - 1); // Page limit

	NSMutableSet<NSNumber *> *pageKeys = [[thumbViews allKeys] mutableCopy];

	NSInteger thumbStride = (thumbs - 1); if (thumbStride < 1) thumbStride = 1;

	const CGFloat stride = (CGFloat(pageCount) / CGFloat(thumbStride));

	const CGFloat thumbX = floor((controlWidth - (thumbs * thumbWidth)) * 0.5);

	const CGFloat thumbY = floor(((controlHeight - smallThumbHeight) * 0.5) + 1.0);

	CGRect thumbRect = CGRectMake(thumbX, thumbY, smallThumbWidth, smallThumbHeight);

	if (showRTL == YES) thumbRect.origin.x = (controlWidth - thumbRect.origin.x - thumbWidth);

	for (NSUInteger thumb = 0; thumb < thumbs; thumb++) // Iterate over needed thumbs
	{
		NSUInteger page = (stride * thumb); if (page > maximumPage) page = maximumPage;

		if (UXReaderPageThumbView *thumbView = [self thumbViewForPage:page]) // Get thumb view
		{
			[thumbView setFrame:thumbRect]; if (![thumbView superview]) [self addSubview:thumbView];
		}

		thumbRect.origin.x += ((showRTL == YES) ? -thumbWidth : +thumbWidth);

		[pageKeys removeObject:@(page)];
	}

	[pageKeys enumerateObjectsUsingBlock:^(NSNumber *key, BOOL * stop)
	{
		if (UXReaderPageThumbView *thumbView = self->thumbViews[key])
		{
			[thumbView removeFromSuperview];
		}
	}];
}

- (void)stopTrackingTimer
{
	//NSLog(@"%s", __FUNCTION__);

	if (trackingTimer != nil) { [trackingTimer invalidate]; trackingTimer = nil; }
}

- (void)startTrackingTimer
{
	//NSLog(@"%s", __FUNCTION__);

	[self stopTrackingTimer]; const NSTimeInterval ti = 0.25; // Seconds

	trackingTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(trackingTimerFired:) userInfo:nil repeats:NO];
}

- (void)trackingTimerFired:(nonnull NSTimer *)timer
{
	//NSLog(@"%s %@", __FUNCTION__, timer);

	if (lastPointValue != nil) // Goto page
	{
		const CGPoint point = [lastPointValue CGPointValue];

		lastPointValue = nil; [self gotoPageForPoint:point];
	}
}

- (NSUInteger)pageForPoint:(CGPoint)point
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));

	const CGFloat controlWidth = [self bounds].size.width;

	if (showRTL == YES) point.x = (controlWidth - point.x);

	return ((pageCount - 1) * (point.x / (controlWidth - 1.0)));
}

- (void)trackPageForPoint:(CGPoint)point
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));

	const NSUInteger page = [self pageForPoint:point];

	[trackThumbView setImage:nil]; [self layoutTrackThumbForPage:page];

	if ([delegate respondsToSelector:@selector(pageControl:trackPage:)])
	{
		[delegate pageControl:self trackPage:page];
	}
}

- (void)gotoPageForPoint:(CGPoint)point
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));

	const NSUInteger page = [self pageForPoint:point]; currentPage = page;

	if ([delegate respondsToSelector:@selector(pageControl:gotoPage:)])
	{
		[delegate pageControl:self gotoPage:page];
	}

	[trackThumbView requestThumb:document page:page];
}

- (void)showPageNumber:(NSUInteger)page ofPages:(NSUInteger)pages
{
	//NSLog(@"%s %i %i", __FUNCTION__, int(page), int(pages));

	if (page != currentPage) // Current page changed
	{
		currentPage = page; [self layoutTrackThumbForPage:page];

		[trackThumbView requestThumb:document page:page];
	}
}

#pragma mark - UIControl tracking methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	//NSLog(@"%s %@ %@", __FUNCTION__, touch, event);

	const CGPoint point = [touch locationInView:self];

	if ([self pointInside:point withEvent:event] == YES)
	{
		[self startTrackingTimer]; [self trackPageForPoint:point];

		lastPointValue = [NSValue valueWithCGPoint:point];
	}

	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	//NSLog(@"%s %@ %@", __FUNCTION__, touch, event);

	if (self.touchInside == YES) // Inside the control
	{
		const CGPoint point = [touch locationInView:self];

		if ([self pointInside:point withEvent:event] == YES)
		{
			[self startTrackingTimer]; [self trackPageForPoint:point];

			lastPointValue = [NSValue valueWithCGPoint:point];
		}
	}

	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	//NSLog(@"%s %@ %@", __FUNCTION__, touch, event);

	[super endTrackingWithTouch:touch withEvent:event];

	const CGPoint point = [touch locationInView:self];

	if ([self pointInside:point withEvent:event] == YES)
	{
		[self stopTrackingTimer]; lastPointValue = nil;

		[self gotoPageForPoint:point];
	}
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	//NSLog(@"%s %@", __FUNCTION__, event);

	[self stopTrackingTimer]; lastPointValue = nil;

	[super cancelTrackingWithEvent:event];
}

@end

//
//	UXReaderPageTiledView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageTiledView.h"
#import "UXReaderDocumentPage.h"
#import "UXReaderTiledLayer.h"
#import "UXReaderFramework.h"

@implementation UXReaderPageTiledView
{
	UXReaderDocument *document;

	UXReaderDocumentPage *documentPage;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView class methods

+ (Class)layerClass
{
	//NSLog(@"%s", __FUNCTION__);

	return [UXReaderTiledLayer class];
}

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = NO; self.userInteractionEnabled = NO;
	}

	return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)documentx page:(NSUInteger)page
{
	//NSLog(@"%s %@ %@ %i", __FUNCTION__, NSStringFromCGRect(frame), documentx, int(page));

	if ((self = [self initWithFrame:frame])) // Initialize self
	{
		if ((documentx != nil) && (page < [documentx pageCount]))
		{
			document = documentx; [self openPage:page document:documentx];
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

	self.layer.delegate = nil;
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

/*
- (void)removeFromSuperview
{
	//NSLog(@"%s", __FUNCTION__);

	//self.layer.delegate = nil;

	[super removeFromSuperview];
}
*/

#pragma mark - UXReaderPageTiledView instance methods

- (void)openPage:(NSUInteger)page document:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %i %@", __FUNCTION__, int(page), documentx);

	[UXReaderFramework dispatch_async_on_work_queue:
	^{
		self->documentPage = [documentx documentPage:page];

		if (self->documentPage != nil) // Redraw view
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				[self setNeedsDisplay];
			});
		}
	}];
}

- (nullable UXReaderAction *)processSingleTap:(nonnull UITapGestureRecognizer *)recognizer
{
	//NSLog(@"%s %@", __FUNCTION__, recognizer);

	if ([document highlightLinks])
	{
		if ([documentPage extractPageURLs])
		{
			[self setNeedsDisplay];
		}

		if ([documentPage extractPageLinks])
		{
			[self setNeedsDisplay];
		}
	}

	UXReaderAction *action = nil;

	const CGPoint point = [recognizer locationInView:self];

	if ([self pointInside:point withEvent:nil] == YES) // Ours
	{
		if (action == nil) action = [documentPage linkAction:point];

		if (action == nil) action = [documentPage textAction:point];
	}

	return action;
}

#pragma mark - CATiledLayer delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
	//NSLog(@"%s %@ %p", __FUNCTION__, layer, context);

	if (UXReaderPageTiledView *hold = self) // Retain
	{
		[documentPage renderTileInContext:context]; // Render tile

		if (id <UXReaderRenderTileInContext> renderTile = [document renderTile])
		{
			if ([renderTile respondsToSelector:@selector(documentPage:renderTileInContext:)])
			{
				[renderTile documentPage:documentPage renderTileInContext:context];
			}
		}

		if (hold != nil) hold = nil; // Release
	}
}

@end

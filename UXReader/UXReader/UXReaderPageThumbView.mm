//
//	UXReaderPageThumbView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageThumbView.h"
#import "UXReaderFramework.h"
#import "UXReaderCanceller.h"

@implementation UXReaderPageThumbView
{
	__weak UXReaderCanceller *canceller;
}

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame mini:(BOOL)mini
{
	//NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(frame), mini);

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.contentMode = UIViewContentModeScaleAspectFit;
		self.userInteractionEnabled = NO; self.opaque = NO;
		self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];

		const CALayer *layer = [self layer]; layer.borderWidth = 1.0;
		layer.borderColor = [[UIColor colorWithWhite:0.4 alpha:0.6] CGColor];
		if (mini == NO) layer.zPosition = 1.0;
	}

	return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document page:(NSUInteger)page mini:(BOOL)mini
{
	//NSLog(@"%s %@ %@ %i %i", __FUNCTION__, NSStringFromCGRect(frame), document, int(page), mini);

	if ((self = [self initWithFrame:frame mini:mini])) // Initialize self
	{
		if ((document != nil) && (page < [document pageCount]))
		{
			[self requestThumb:document page:page];
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

	[canceller cancel];
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

- (void)removeFromSuperview
{
	//NSLog(@"%s", __FUNCTION__);

	[super removeFromSuperview];
}

- (void)requestThumb:(nonnull UXReaderDocument *)document page:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, document, int(page));

	if ((document != nil) && (page < [document pageCount]))
	{
		[canceller cancel]; //[self setPage:page];

		const CGFloat scale = [[UIScreen mainScreen] scale];

		const CGSize size = UXSizeScale(self.bounds.size, scale, scale);

		UXReaderCanceller *request = [[UXReaderCanceller alloc] initWithUUID]; canceller = request;

		__weak UXReaderPageThumbView *weakSelf = self;

		[document thumbForPage:page size:size canceller:request completion:^(UIImage *thumb)
		{
			[weakSelf setImage:thumb];
		}];
	}
}

@end

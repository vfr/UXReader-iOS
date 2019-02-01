//
//	UXReaderPageImageView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageImageView.h"
#import "UXReaderFramework.h"
#import "UXReaderCanceller.h"

@implementation UXReaderPageImageView
{
	__weak UXReaderCanceller *canceller;
}

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.autoresizesSubviews = NO; self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeScaleAspectFit; self.opaque = YES;
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	}

	return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document page:(NSUInteger)page
{
	//NSLog(@"%s %@ %@ %i", __FUNCTION__, NSStringFromCGRect(frame), document, int(page));

	if ((self = [self initWithFrame:frame])) // Initialize self
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

- (void)requestThumb:(nonnull UXReaderDocument *)document page:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, document, int(page));

	if ((document != nil) && (page < [document pageCount])) // Carry on
	{
		[canceller cancel]; UIScreen *mainScreen = [UIScreen mainScreen];

		const CGSize screenSize = mainScreen.bounds.size; CGSize targetSize = self.bounds.size;

		const CGFloat screenMax = ((screenSize.width > screenSize.height) ? screenSize.width : screenSize.height);

		const CGFloat targetMax = ((targetSize.width > targetSize.height) ? targetSize.width : targetSize.height);

		if (targetMax > screenMax) {CGFloat r = (screenMax / targetMax); targetSize = UXSizeScale(targetSize, r, r);}

		const CGFloat scale = ([mainScreen scale] / 3.0); const CGSize size = UXSizeScale(targetSize, scale, scale);

		UXReaderCanceller *request = [[UXReaderCanceller alloc] initWithUUID]; canceller = request;

		__weak UXReaderPageImageView *weakSelf = self;

		[document thumbForPage:page size:size canceller:request completion:^(UIImage *thumb)
		{
			[weakSelf setImage:thumb];
		}];
	}
}

@end

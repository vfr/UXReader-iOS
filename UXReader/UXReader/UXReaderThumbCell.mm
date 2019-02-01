//
//	UXReaderThumbCell.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderThumbCell.h"
#import "UXReaderThumbShow.h"
#import "UXReaderCanceller.h"
#import "UXReaderFramework.h"

@interface UXReaderThumbCell ()

@end

@implementation UXReaderThumbCell
{
	UXReaderCanceller *canceller;

	UXReaderThumbShow *thumbShow;
}

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];

		[self populateView:[self contentView]];
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

	[thumbShow setFrame:[[self contentView] bounds]];
}

#pragma mark - UICollectionViewCell instance methods

- (void)prepareForReuse
{
	//NSLog(@"%s", __FUNCTION__);

	[canceller cancel]; canceller = nil;

	[thumbShow prepareForReuse];

	[super prepareForReuse];
}

- (void)setHighlighted:(BOOL)highlighted
{
	//NSLog(@"%s %i", __FUNCTION__, highlighted);

	[thumbShow setHighlighted:highlighted];

	[super setHighlighted:highlighted];
}

#pragma mark - UXReaderThumbCell instance methods

- (void)populateView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if ((thumbShow = [[UXReaderThumbShow alloc] initWithFrame:[view bounds]]))
	{
		[view addSubview:thumbShow]; //[thumbShow setContentMode:UIViewContentModeScaleToFill];
	}
}

- (void)requestThumb:(nonnull UXReaderDocument *)document page:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, document, int(page));

	if ((document != nil) && (page < [document pageCount])) // Carry on
	{
		[canceller cancel]; canceller = [[UXReaderCanceller alloc] initWithUUID];

		const CGFloat scale = [[UIScreen mainScreen] scale]; // Points to pixels

		const CGSize size = UXSizeScale(thumbShow.bounds.size, scale, scale);

		[thumbShow prepareForUse]; __weak UXReaderThumbShow *weakThumbShow = thumbShow;

		[document thumbForPage:page size:size canceller:canceller completion:^(UIImage *thumb)
		{
			[weakThumbShow setImage:thumb];
		}];
	}
}

- (nullable UXReaderThumbShow *)thumbShow
{
	//NSLog(@"%s", __FUNCTION__);

	return thumbShow;
}

- (void)showText:(nonnull NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	[thumbShow showText:text];
}

- (void)showCurrentPage:(BOOL)show
{
	//NSLog(@"%s %i", __FUNCTION__, show);

	[thumbShow showCurrentPage:show];
}

@end

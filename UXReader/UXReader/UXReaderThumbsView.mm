//
//	UXReaderThumbsView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderThumbsView.h"
#import "UXReaderThumbCell.h"
#import "UXReaderThumbShow.h"
#import "UXReaderFramework.h"

@interface UXReaderThumbsView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation UXReaderThumbsView
{
	UXReaderDocument *document;

	UICollectionView *thumbsView;

	CGFloat maximumCellSize;

	NSUInteger currentPage;

	BOOL updateCells;
}

#pragma mark - Constants

static NSString *const kUXReaderThumbCell = @"UXReaderThumbCell";

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView instance methods

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if ((self = [self initWithFrame:CGRectZero])) // Initialize self
	{
		if (documentx != nil) [self populateView:documentx]; else self = nil;
	}

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO; self.hidden = YES;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];

		maximumCellSize = ([UXReaderFramework isSmallDevice] ? 108.0 : 220.0);

		currentPage = NSUIntegerMax;
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

#pragma mark - UXReaderThumbsView instance methods

- (void)populateView:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	document = documentx; const CGFloat is = 64.0;

	const CGFloat sp = ([UXReaderFramework isSmallDevice] ? 8.0 : 16.0);

	if (UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init])
	{
		[layout setMinimumInteritemSpacing:sp]; [layout setMinimumLineSpacing:sp]; // Defaults

		[layout setSectionInset:UIEdgeInsetsMake(sp, sp, sp, sp)]; [layout setItemSize:CGSizeMake(is, is)];

		if ((thumbsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout]))
		{
			thumbsView.translatesAutoresizingMaskIntoConstraints = NO; [self addSubview:thumbsView];

			const CGFloat ti = ([UXReaderFramework mainToolbarHeight] + [UXReaderFramework statusBarHeight]);

			thumbsView.contentInset = UIEdgeInsetsMake(ti, 0.0, 0.0, 0.0); thumbsView.backgroundColor = [UIColor clearColor];

			thumbsView.exclusiveTouch = YES; thumbsView.scrollsToTop = NO; thumbsView.dataSource = self; thumbsView.delegate = self;

			[thumbsView registerClass:[UXReaderThumbCell class] forCellWithReuseIdentifier:kUXReaderThumbCell]; // Cell class to use

			[self addConstraint:[NSLayoutConstraint constraintWithItem:thumbsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:thumbsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:thumbsView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:thumbsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
		}
	}
}

- (void)setCurrentPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	if (thumbsView != nil) // Center page
	{
		if (currentPage != page) currentPage = page;

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10000000ull), dispatch_get_main_queue(),
		^{
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:page inSection:0]; // Dispatch hack

			[thumbsView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];

			dispatch_async(dispatch_get_main_queue(), ^{ updateCells = YES; [thumbsView reloadData]; [thumbsView flashScrollIndicators]; });
		});
	}
}

- (void)didAppear
{
	//NSLog(@"%s", __FUNCTION__);

	if (updateCells == YES) [thumbsView flashScrollIndicators];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	//NSLog(@"%s %@ %i", __FUNCTION__, collectionView, int(section));

	return [document pageCount];
}

- (UXReaderThumbCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@ %@", __FUNCTION__, collectionView, indexPath);

	UXReaderThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUXReaderThumbCell forIndexPath:indexPath];

	if (updateCells == YES) // Update UXReaderThumbCell cell contents
	{
		const NSUInteger page = [indexPath item]; NSString *label = [document pageLabel:page];

		NSString *text = ((label == nil) ? [NSString stringWithFormat:@"%i", int(page+1)] : label);

		[cell requestThumb:document page:page]; [cell showText:text];

		[cell showCurrentPage:(page == currentPage)];
	}

	return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@ %@", __FUNCTION__, collectionView, indexPath);

	const NSUInteger page = [indexPath item];

	if ([delegate respondsToSelector:@selector(thumbsView:gotoPage:)])
	{
		[delegate thumbsView:self gotoPage:page];
	}

	CGRect frame = CGRectZero; // Default frame - none

	if ([delegate respondsToSelector:@selector(thumbsView:frameForPage:inView:)])
	{
		frame = [delegate thumbsView:self frameForPage:page inView:self];
	}

	if (CGRectEqualToRect(frame, CGRectZero) == false) // Animate thumb selection
	{
		if (UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath])
		{
			const CGRect from = [cell convertRect:[cell bounds] toView:self]; // Start

			if (UIImageView *imageView = [[UIImageView alloc] initWithFrame:from])
			{
				UIImage *thumb = [[(UXReaderThumbCell *)cell thumbShow] image];

				//[imageView setTranslatesAutoresizingMaskIntoConstraints:YES];
				[imageView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
				[imageView setContentMode:UIViewContentModeScaleAspectFit]; [imageView setOpaque:YES];
				[imageView setImage:thumb]; [self addSubview:imageView];

				[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void)
				{
					[imageView setFrame:frame];
				}
				completion:^(BOOL finished)
				{
					[imageView removeFromSuperview];

					if ([delegate respondsToSelector:@selector(thumbsView:dismiss:)])
					{
						[delegate thumbsView:self dismiss:nil];
					}
				}];
			}
		}
	}
	else if ([delegate respondsToSelector:@selector(thumbsView:dismiss:)])
	{
		[delegate thumbsView:self dismiss:nil];
	}
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@ %@ %@", __FUNCTION__, collectionView, layout, indexPath);

	const NSUInteger page = [indexPath item];

	const CGSize pageSize = [document pageSize:page];

	const CGSize cellSize = CGSizeMake(maximumCellSize, maximumCellSize);

	const CGFloat scale = UXScaleThatFits(cellSize, pageSize);

	return UXSizeFloor(UXSizeScale(pageSize, scale, scale));
}

@end

//
//	UXReaderPageToolbar.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageToolbar.h"
#import "UXReaderPageControl.h"
#import "UXReaderPageNumbers.h"
#import "UXReaderFramework.h"

@interface UXReaderPageToolbar () <UXReaderPageControlDelegate>

@end

@implementation UXReaderPageToolbar
{
	UIView *contentView;

	UXReaderDocument *document;

	__weak NSLayoutConstraint *layoutConstraintY;

	UXReaderPageControl *pageControl;

	UXReaderPageNumbers *pageNumbers;

	NSUInteger pageCount;
}

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
		self.translatesAutoresizingMaskIntoConstraints = NO; self.contentMode = UIViewContentModeRedraw;

		self.backgroundColor = [UIColor clearColor]; const CGFloat th = [UXReaderFramework pageToolbarHeight];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
															toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);

	[pageNumbers removeFromSuperview];
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

- (void)didMoveToSuperview
{
	//NSLog(@"%s %@", __FUNCTION__, [self superview]);

	[super didMoveToSuperview];

	if ((self.superview != nil) && (pageNumbers == nil))
	{
		[self addPageNumbers:[self superview]];
	}
}

#pragma mark - UXReaderPageToolbar instance methods

- (void)populateView:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	document = documentx; pageCount = [document pageCount];

	UIView *view = [self addEffectsView:self]; [self addSeparator:view];
}

- (nonnull UIView *)addEffectsView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	[blurEffectView setBackgroundColor:[UXReaderFramework toolbarBackgroundColor]];
	[blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[view addSubview:blurEffectView];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

	contentView = [blurEffectView contentView]; return contentView;
}

- (void)addSeparator:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
	line.translatesAutoresizingMaskIntoConstraints = NO;
	line.backgroundColor = [UXReaderFramework toolbarSeparatorLineColor];
	line.userInteractionEnabled = NO; line.contentMode = UIViewContentModeRedraw;
	[view addSubview:line];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:1.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
}

- (void)addPageControl:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (pageControl == nil) // Create UXReaderPageControl
	{
		if ((pageControl = [[UXReaderPageControl alloc] initWithDocument:document]))
		{
			[view addSubview:pageControl]; [pageControl setDelegate:self]; // UXReaderPageControlDelegate

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual
																toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-8.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
		}
	}
}

- (void)addPageNumbers:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (pageNumbers == nil) // Create UXReaderPageNumbers
	{
		if ((pageNumbers = [[UXReaderPageNumbers alloc] initWithFrame:CGRectZero]))
		{
			[view addSubview:pageNumbers]; const CGFloat yo = ([UXReaderFramework isSmallDevice] ? 64.0 : 80.0);

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageNumbers attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageNumbers attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-yo]];
		}
	}
}

- (void)showPageNumber:(NSUInteger)page ofPages:(NSUInteger)pages
{
	//NSLog(@"%s %i %i", __FUNCTION__, int(page), int(pages));

	if (pageControl == nil) [self addPageControl:contentView];

	[pageControl showPageNumber:page ofPages:pages];

	[self showPage:page ofPages:pages];
}

- (void)showPage:(NSUInteger)page ofPages:(NSUInteger)pages
{
	//NSLog(@"%s %i %i", __FUNCTION__, int(page), int(pages));

	if (NSString *label = [document pageLabel:page]) [pageNumbers showPageLabel:label]; else [pageNumbers showPageNumber:page ofPages:pages];
}

- (void)setLayoutConstraintY:(nonnull NSLayoutConstraint *)constraint
{
	//NSLog(@"%s %@", __FUNCTION__, constraint);

	layoutConstraintY = constraint;
}

- (void)hideAnimated
{
	//NSLog(@"%s", __FUNCTION__);

	if (layoutConstraintY.constant <= 0.0) // Visible
	{
		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void)
		{
			layoutConstraintY.constant = +self.bounds.size.height; [[self superview] layoutIfNeeded]; pageNumbers.alpha = 0.0;
		}
		completion:^(BOOL finished)
		{
			pageNumbers.hidden = YES; self.hidden = YES;
		}];
	}
}

- (void)showAnimated
{
	//NSLog(@"%s", __FUNCTION__);

	if (layoutConstraintY.constant > 0.0) // Hidden
	{
		pageNumbers.hidden = NO; self.hidden = NO; // Unhide the view

		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void)
		{
			layoutConstraintY.constant -= self.bounds.size.height; [[self superview] layoutIfNeeded]; pageNumbers.alpha = 1.0;
		}
		completion:^(BOOL finished)
		{
		}];
	}
}

- (BOOL)isVisible
{
	//NSLog(@"%s", __FUNCTION__);

	return (layoutConstraintY.constant <= 0.0);
}

- (void)setEnabled:(BOOL)enabled
{
	//NSLog(@"%s %i", __FUNCTION__, enabled);

	[pageControl setEnabled:enabled];
}

#pragma mark - UXReaderPageControlDelegate

- (void)pageControl:(nonnull UXReaderPageControl *)control trackPage:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, control, int(page));

	[self showPage:page ofPages:pageCount];
}

- (void)pageControl:(nonnull UXReaderPageControl *)control gotoPage:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, control, int(page));

	if ([delegate respondsToSelector:@selector(pageToolbar:gotoPage:)])
	{
		[delegate pageToolbar:self gotoPage:page];
	}
}

@end

//
//	UXReaderMainToolbar.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderMainToolbar.h"
#import "UXReaderSearchView.h"
#import "UXReaderFramework.h"

@interface UXReaderMainToolbar () <UXReaderSearchViewDelegate>

@end

@implementation UXReaderMainToolbar
{
	NSBundle *bundle;

	UXReaderDocument *document;

	__weak NSLayoutConstraint *layoutConstraintY;

	UXReaderSearchView *searchView;

	UIView *contentView;

	UIButton *closeButton;
	UIButton *searchButton;
	UIButton *shareButton;
	UIButton *stuffButton;

	UILabel *titleLabel;
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
		self.backgroundColor = [UIColor clearColor]; //self.userInteractionEnabled = YES; self.opaque = NO;

		const CGFloat vh = ([UXReaderFramework mainToolbarHeight] + [UXReaderFramework statusBarHeight]); // Total height

		[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
															toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:vh]];

		bundle = [NSBundle bundleForClass:[self class]]; //[self populateView];
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);

	[searchView removeFromSuperview];
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

	if ((self.superview != nil) && (searchView == nil))
	{
		[self addSearchView:[self superview]];
	}
}

#pragma mark - UXReaderMainToolbar instance methods

- (void)populateView:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	document = documentx; UIView *view = [self addEffectsView:self]; [self addSeparator:view];

	const CGFloat th = [UXReaderFramework mainToolbarHeight]; const CGFloat sh = floor([UXReaderFramework statusBarHeight] * 0.5);

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const closeName = @"UXReader-Toolbar-Close";
	UIImage *closeImage = [UIImage imageNamed:closeName inBundle:bundle compatibleWithTraitCollection:nil];
	closeImage = [closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	closeButton = [[UIButton alloc] initWithFrame:CGRectZero]; [closeButton setEnabled:NO];
	[closeButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [closeButton setExclusiveTouch:YES];
	[closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[closeButton setImage:closeImage forState:UIControlStateNormal]; [closeButton setShowsTouchWhenHighlighted:YES];
	[closeButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
	[view addSubview:closeButton]; //[closeButton setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const shareName = @"UXReader-Toolbar-Share";
	UIImage *shareImage = [UIImage imageNamed:shareName inBundle:bundle compatibleWithTraitCollection:nil];
	shareImage = [shareImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	shareButton = [[UIButton alloc] initWithFrame:CGRectZero]; [shareButton setEnabled:NO];
	[shareButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [shareButton setExclusiveTouch:YES];
	[shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[shareButton setImage:shareImage forState:UIControlStateNormal]; [shareButton setShowsTouchWhenHighlighted:YES];
	[shareButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
	[view addSubview:shareButton]; //[shareButton setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:closeButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	titleLabel = [[UILabel alloc] initWithFrame:CGRectZero]; //[titleLabel setEnabled:NO];
	[titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; [titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
	[titleLabel setTextColor:[UXReaderFramework toolbarTitleTextColor]]; [titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:[document title]]; [titleLabel setFont:[UIFont systemFontOfSize:16.0]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES]; [titleLabel setMinimumScaleFactor:0.75];
	[titleLabel setHidden:[UXReaderFramework isSmallDevice]];
	[view addSubview:titleLabel]; //[titleLabel setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:shareButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const stuffName = @"UXReader-Toolbar-Outline";
	UIImage *stuffImage = [UIImage imageNamed:stuffName inBundle:bundle compatibleWithTraitCollection:nil];
	stuffImage = [stuffImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	stuffButton = [[UIButton alloc] initWithFrame:CGRectZero]; [stuffButton setEnabled:NO];
	[stuffButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [stuffButton setExclusiveTouch:YES];
	[stuffButton addTarget:self action:@selector(stuffButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[stuffButton setImage:stuffImage forState:UIControlStateNormal]; [stuffButton setShowsTouchWhenHighlighted:YES];
	[stuffButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
	[view addSubview:stuffButton]; //[stuffButton setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:titleLabel attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const searchName = @"UXReader-Toolbar-Search";
	UIImage *searchImage = [UIImage imageNamed:searchName inBundle:bundle compatibleWithTraitCollection:nil];
	searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	searchButton = [[UIButton alloc] initWithFrame:CGRectZero]; [searchButton setEnabled:NO];
	[searchButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [searchButton setExclusiveTouch:YES];
	[searchButton addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[searchButton setImage:searchImage forState:UIControlStateNormal]; [searchButton setShowsTouchWhenHighlighted:YES];
	[searchButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
	[view addSubview:searchButton]; //[searchButton setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:stuffButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	[self stuffButtonWhat:[[[UXReaderFramework defaults] objectForKey:@"CurrentWhat"] unsignedIntegerValue]];
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

	[view addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}

- (void)addSearchView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (searchView == nil) // Create UXReaderSearchView
	{
		if ((searchView = [[UXReaderSearchView alloc] initWithFrame:CGRectZero]))
		{
			[view addSubview:searchView]; [searchView setDelegate:self]; // UXReaderSearchViewDelegate

			[view addConstraint:[NSLayoutConstraint constraintWithItem:searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:searchView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-8.0]];
		}
	}
}

- (void)setLayoutConstraintY:(nonnull NSLayoutConstraint *)constraint
{
	//NSLog(@"%s %@", __FUNCTION__, constraint);

	layoutConstraintY = constraint;
}

- (void)stuffButtonWhat:(NSUInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	NSDictionary<NSNumber *, NSString *> *names = @{@(0) : @"UXReader-Toolbar-Outline", @(1) : @"UXReader-Toolbar-Preview", @(2) : @"UXReader-Toolbar-Options"};

	if (NSString *name = names[@(index)]) // Lookup image name for requested index
	{
		if (UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil])
		{
			if ((image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]))
			{
				[stuffButton setImage:image forState:UIControlStateNormal];
			}
		}
	}
}

- (void)setAllowShare:(BOOL)allow
{
	//NSLog(@"%s %i", __FUNCTION__, allow);

	[shareButton setHidden:(allow ? NO : YES)];
}

- (void)setAllowClose:(BOOL)allow
{
    //NSLog(@"%s %i", __FUNCTION__, allow);

    [closeButton setHidden:(allow ? NO : YES)];
}


- (void)hideAnimated
{
	//NSLog(@"%s", __FUNCTION__);

	if (layoutConstraintY.constant >= 0.0) // Visible
	{
		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void)
		{
			layoutConstraintY.constant = -self.bounds.size.height; [[self superview] layoutIfNeeded];
		}
		completion:^(BOOL finished)
		{
			self.hidden = YES;
		}];
	}
}

- (void)showAnimated
{
	//NSLog(@"%s", __FUNCTION__);

	if (layoutConstraintY.constant < 0.0) // Hidden
	{
		self.hidden = NO; // Unhide the view before animation

		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void)
		{
			layoutConstraintY.constant += self.bounds.size.height; [[self superview] layoutIfNeeded];
		}
		completion:^(BOOL finished)
		{
		}];
	}
}

- (BOOL)isVisible
{
	//NSLog(@"%s", __FUNCTION__);

	return (layoutConstraintY.constant >= 0.0);
}

- (void)setEnabled:(BOOL)enabled
{
	//NSLog(@"%s %i", __FUNCTION__, enabled);

	[closeButton setEnabled:enabled]; [shareButton setEnabled:enabled];

	[stuffButton setEnabled:enabled]; [searchButton setEnabled:enabled];
}

- (void)clearSearchText
{
	//NSLog(@"%s", __FUNCTION__);

	[searchView clearSearchText];
}

- (void)showSearchBusy:(BOOL)show
{
	//NSLog(@"%s", __FUNCTION__);

	[searchView showSearchBusy:show];
}

- (void)showFound:(NSUInteger)x of:(NSUInteger)n
{
	//NSLog(@"%s %i %i", __FUNCTION__, int(x), int(n));

	[searchView showFound:x of:n];
}

- (void)showFound:(NSUInteger)x of:(NSUInteger)n on:(NSUInteger)o;
{
	//NSLog(@"%s %i %i %i", __FUNCTION__, int(x), int(n), int(o));

	[searchView showFound:x of:n on:o];
}

- (void)showFoundCount:(NSUInteger)count
{
	//NSLog(@"%s %i", __FUNCTION__, int(count));

	[searchView showFoundCount:count];
}

- (void)showSearchNotFound
{
	//NSLog(@"%s", __FUNCTION__);

	[searchView showSearchNotFound];
}

- (void)dismissKeyboard
{
	//NSLog(@"%s", __FUNCTION__);

	[searchView dismissKeyboard];
}

#pragma mark - UIButton action methods

- (void)closeButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	[self dismissKeyboard];

	if ([delegate respondsToSelector:@selector(mainToolbar:closeButton:)])
	{
		[delegate mainToolbar:self closeButton:button];
	}
}

- (void)shareButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	[self dismissKeyboard];

	if ([delegate respondsToSelector:@selector(mainToolbar:shareButton:)])
	{
		[delegate mainToolbar:self shareButton:button];
	}
}

- (void)stuffButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	[self dismissKeyboard];

	if ([delegate respondsToSelector:@selector(mainToolbar:stuffButton:)])
	{
		[delegate mainToolbar:self stuffButton:button];
	}
}

- (void)searchButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	if ([searchView isVisible]) [searchView hideAnimated]; else [searchView showAnimated];

	if ([delegate respondsToSelector:@selector(mainToolbar:searchButton:)])
	{
		[delegate mainToolbar:self searchButton:button];
	}
}

#pragma mark - UXReaderSearchViewDelegate methods

- (void)searchView:(nonnull UXReaderSearchView *)view searchTextDidChange:(nonnull NSString *)text
{
	//NSLog(@"%s '%@'", __FUNCTION__, text);

	if ([delegate respondsToSelector:@selector(mainToolbar:searchTextDidChange:)])
	{
		[delegate mainToolbar:self searchTextDidChange:text];
	}
}

- (void)searchView:(nonnull UXReaderSearchView *)view beginSearching:(nonnull NSString *)text
{
	//NSLog(@"%s '%@'", __FUNCTION__, text);

	if ([delegate respondsToSelector:@selector(mainToolbar:beginSearching:)])
	{
		[delegate mainToolbar:self beginSearching:text];
	}
}

@end

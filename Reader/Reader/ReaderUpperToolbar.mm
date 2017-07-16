//
//	ReaderUpperToolbar.mm
//	Reader v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "ReaderUpperToolbar.h"
#import "ReaderAppearance.h"

@interface ReaderUpperToolbar () <UISearchBarDelegate>

@end

@implementation ReaderUpperToolbar
{
	NSBundle *bundle;

	UIView *contentView;

	UILabel *titleLabel;

	UISearchBar *searchField;

	NSLayoutConstraint *searchConstraintX;

	UIButton *optionsButton;

	UIButton *searchButton;

	BOOL searchVisible;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO; self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor clearColor]; //self.userInteractionEnabled = YES; self.opaque = NO;

		const CGFloat vh = ([ReaderAppearance mainToolbarHeight] + [ReaderAppearance statusBarHeight]); // Total height

		[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
															toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:vh]];

		bundle = [NSBundle bundleForClass:[self class]]; [self populateView];
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

#pragma mark - ReaderUpperToolbar instance methods

- (void)populateView
{
	//NSLog(@"%s", __FUNCTION__);

	UIView *view = [self addEffectsView:self]; [self addSeparator:view];

	const CGFloat sw = ([ReaderAppearance isSmallDevice] ? 192.0 : 256.0);

	const CGFloat th = [ReaderAppearance mainToolbarHeight]; const CGFloat sh = floor([ReaderAppearance statusBarHeight] * 0.5);

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const optionsName = @"Reader-Toolbar-Options";
	UIImage *optionsImage = [UIImage imageNamed:optionsName inBundle:bundle compatibleWithTraitCollection:nil];
	optionsImage = [optionsImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	optionsButton = [[UIButton alloc] initWithFrame:CGRectZero]; [optionsButton setEnabled:NO];
	[optionsButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [optionsButton setExclusiveTouch:YES];
	[optionsButton addTarget:self action:@selector(optionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[optionsButton setImage:optionsImage forState:UIControlStateNormal]; [optionsButton setShowsTouchWhenHighlighted:YES];
	[optionsButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
	[view addSubview:optionsButton]; //[optionsButton setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:optionsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:optionsButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:optionsButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:optionsButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	NSString *titleText = [bundle localizedStringForKey:@"Documents" value:nil table:nil];

	titleLabel = [[UILabel alloc] initWithFrame:CGRectZero]; //[titleLabel setEnabled:NO];
	[titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; [titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
	[titleLabel setTextColor:[ReaderAppearance toolbarTitleTextColor]]; [titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:titleText]; [titleLabel setFont:[UIFont systemFontOfSize:16.0]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES]; [titleLabel setMinimumScaleFactor:0.75];
	[view addSubview:titleLabel]; //[titleLabel setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:optionsButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const searchName = @"Reader-Toolbar-Search";
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
														toItem:titleLabel attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	searchField = [[UISearchBar alloc] initWithFrame:CGRectZero]; // UISearchBar
	[searchField setTranslatesAutoresizingMaskIntoConstraints:NO]; [searchField setSearchBarStyle:UISearchBarStyleMinimal];
	[searchField setDelegate:self]; [searchField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[searchField setReturnKeyType:UIReturnKeySearch]; [searchField setEnablesReturnKeyAutomatically:YES];
	[searchField setPlaceholder:[bundle localizedStringForKey:@"Filter" value:nil table:nil]];
	[view addSubview:searchField]; //[searchField setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:sw]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

	searchConstraintX = [NSLayoutConstraint constraintWithItem:searchField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];

	[view addConstraint:searchConstraintX]; searchVisible = NO;
}

- (nonnull UIView *)addEffectsView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	//[blurEffectView setBackgroundColor:[ReaderAppearance toolbarBackgroundColor]];
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
	line.backgroundColor = [ReaderAppearance toolbarSeparatorLineColor];
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

- (void)toggleSearchField:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	NSLayoutConstraint *oldConstraint = searchConstraintX; // Old one

	UIView *view1 = nil; NSLayoutAttribute attr1 = NSLayoutAttributeNotAnAttribute;
	UIView *view2 = nil; NSLayoutAttribute attr2 = NSLayoutAttributeNotAnAttribute;

	if (searchVisible == YES)
		{ attr1 = NSLayoutAttributeLeading; attr2 = NSLayoutAttributeTrailing; view1 = searchField; view2 = view; }
	else
		{ attr2 = NSLayoutAttributeLeading; attr1 = NSLayoutAttributeTrailing; view1 = searchField; view2 = searchButton; }

	searchConstraintX = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:NSLayoutRelationEqual
														toItem:view2 attribute:attr2 multiplier:1.0 constant:0.0];

	if (searchVisible == YES) [searchField resignFirstResponder]; else [searchField becomeFirstResponder];

	UIViewAnimationOptions options = (searchVisible ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut);

	searchVisible = !searchVisible; const NSTimeInterval ti = ([ReaderAppearance animationDuration] + 0.1);

	[UIView animateWithDuration:ti delay:0.0 options:options animations:^(void)
	{
		[view removeConstraint:oldConstraint]; [view addConstraint:searchConstraintX]; [view layoutIfNeeded];

		const CGFloat a = (searchVisible ? 0.0 : 1.0); [titleLabel setAlpha:a];
	}
	completion:^(BOOL finished)
	{
	}];
}

- (void)setEnabled:(BOOL)enabled
{
	//NSLog(@"%s %i", __FUNCTION__, enabled);

	if ((enabled == NO) && (searchVisible == YES)) [self toggleSearchField:[searchField superview]];

	[searchButton setEnabled:enabled]; //[optionsButton setEnabled:enabled];
}

- (void)dismissKeyboard
{
	//NSLog(@"%s", __FUNCTION__);

	[searchField resignFirstResponder];
}

#pragma mark - UIButton action methods

- (void)optionsButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	[self dismissKeyboard];

	if ([delegate respondsToSelector:@selector(upperToolbar:optionsButton:)])
	{
		[delegate upperToolbar:self optionsButton:button];
	}
}

- (void)searchButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	[self toggleSearchField:[searchField superview]];
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text
{
	//NSLog(@"%s '%@'", __FUNCTION__, [searchBar text]);

	if ([delegate respondsToSelector:@selector(upperToolbar:searchTextDidChange:)])
	{
		[delegate upperToolbar:self searchTextDidChange:[searchBar text]];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	//NSLog(@"%s '%@'", __FUNCTION__, [searchBar text]);

	if ([delegate respondsToSelector:@selector(upperToolbar:beginSearching:)])
	{
		[delegate upperToolbar:self beginSearching:[searchBar text]];
	}
}

@end

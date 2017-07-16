//
//	UXReaderSearchView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderSearchView.h"
#import "UXReaderFramework.h"

@interface UXReaderSearchView () <UISearchBarDelegate>

@end

@implementation UXReaderSearchView
{
	NSBundle *bundle;

	UISearchBar *searchField;

	UIActivityIndicatorView *busyControl;

	UILabel *searchLabel;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
		[self setContentMode:UIViewContentModeRedraw];
		[self setAlpha:0.0]; [self setHidden:YES];

		const CGFloat sw = ([UXReaderFramework isSmallDevice] ? 256.0 : 320.0); // Search view width

		[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
															toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:sw]];

		bundle = [NSBundle bundleForClass:[self class]]; [self populateView:self];
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

	self.layer.shadowOpacity = 1.0; self.layer.shadowRadius = 2.0; self.layer.shadowOffset = CGSizeZero;

	self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self bounds]] CGPath];

	self.layer.shadowColor = [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor];
}

#pragma mark - UXReaderSearchView instance methods

- (void)populateView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	searchField = [[UISearchBar alloc] initWithFrame:CGRectZero]; // UISearchBar
	[searchField setTranslatesAutoresizingMaskIntoConstraints:NO]; [searchField setSearchBarStyle:UISearchBarStyleMinimal];
	[searchField setDelegate:self]; [searchField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[searchField setReturnKeyType:UIReturnKeySearch]; [searchField setEnablesReturnKeyAutomatically:YES];
	[searchField setPlaceholder:[bundle localizedStringForKey:@"SearchDocument" value:nil table:nil]];
	[view addSubview:searchField]; //[searchField setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

// --------------------------------------------------------------------------------------------------------------------------------

	searchLabel = [[UILabel alloc] initWithFrame:CGRectZero]; // UILabel
	[searchLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; [searchLabel setTextAlignment:NSTextAlignmentCenter];
	[searchLabel setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]]; [searchLabel setBackgroundColor:[UIColor clearColor]];
	[searchLabel setAdjustsFontSizeToFitWidth:YES]; [searchLabel setMinimumScaleFactor:0.75];
	[searchLabel setFont:[UIFont systemFontOfSize:14.0]]; [searchLabel setText:@"-"];
	[view addSubview:searchLabel]; //[searchLabel setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
														toItem:searchField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:searchLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeBottomMargin multiplier:1.0 constant:0.0]];

// --------------------------------------------------------------------------------------------------------------------------------

	busyControl = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[busyControl setTranslatesAutoresizingMaskIntoConstraints:NO]; [busyControl setHidesWhenStopped:YES];
	[view addSubview:busyControl]; //[busyControl setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:busyControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
														toItem:searchField attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:busyControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:searchField attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

- (void)hideAnimated
{
	//NSLog(@"%s", __FUNCTION__);

	if (self.alpha > 0.0) // Visible
	{
		[searchField resignFirstResponder]; // Hide keyboard

		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void)
		{
			self.alpha = 0.0;
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

	if (self.alpha < 1.0) // Hidden
	{
		self.hidden = NO; // Unhide before animation

		[searchField becomeFirstResponder]; // Show keyboard

		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void)
		{
			self.alpha = 1.0;
		}
		completion:^(BOOL finished)
		{
		}];
	}
}

- (BOOL)isVisible
{
	//NSLog(@"%s", __FUNCTION__);

	return (self.alpha > 0.0);
}

- (void)clearSearchText
{
	//NSLog(@"%s", __FUNCTION__);

	[searchLabel setText:@"-"];
}

- (void)showSearchBusy:(BOOL)show
{
	//NSLog(@"%s", __FUNCTION__);

	if (show == YES) [busyControl startAnimating]; else [busyControl stopAnimating];
}

- (void)showFound:(NSUInteger)x of:(NSUInteger)n
{
	//NSLog(@"%s %i %i", __FUNCTION__, int(x), int(n));

	NSString *format = [bundle localizedStringForKey:@"%i of %i" value:nil table:nil];

	[searchLabel setText:[NSString stringWithFormat:format, int(x), int(n)]];
}

- (void)showFound:(NSUInteger)x of:(NSUInteger)n on:(NSUInteger)o
{
	//NSLog(@"%s %i %i %i", __FUNCTION__, int(x), int(n), int(o));

	NSString *format = [bundle localizedStringForKey:@"%i of %i on %i" value:nil table:nil];

	[searchLabel setText:[NSString stringWithFormat:format, int(x), int(n), int(o)]];
}

- (void)showFoundCount:(NSUInteger)count
{
	//NSLog(@"%s %i", __FUNCTION__, int(count));

	NSString *format = [bundle localizedStringForKey:@"SearchIntCount" value:nil table:nil];

	[searchLabel setText:[NSString stringWithFormat:format, int(count)]];
}

- (void)showSearchNotFound
{
	//NSLog(@"%s", __FUNCTION__);

	NSString *text = [bundle localizedStringForKey:@"SearchNotFound" value:nil table:nil];

	[searchLabel setText:text];
}

- (void)dismissKeyboard
{
	//NSLog(@"%s", __FUNCTION__);

	[searchField resignFirstResponder];
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text
{
	//NSLog(@"%s '%@'", __FUNCTION__, [searchBar text]);

	if ([delegate respondsToSelector:@selector(searchView:searchTextDidChange:)])
	{
		[delegate searchView:self searchTextDidChange:[searchBar text]];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	//NSLog(@"%s '%@'", __FUNCTION__, [searchBar text]);

	if ([delegate respondsToSelector:@selector(searchView:beginSearching:)])
	{
		[delegate searchView:self beginSearching:[searchBar text]];
	}
}

@end

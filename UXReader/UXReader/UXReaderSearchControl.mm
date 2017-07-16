//
//	UXReaderSearchControl.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderSearchControl.h"
#import "UXReaderFramework.h"

@implementation UXReaderSearchControl
{
	UIButton *closeButton;
	UIButton *forwardButton;
	UIButton *reverseButton;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UXReaderSearchControl instance methods

- (nullable instancetype)initWithView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if ((self = [super init])) // Initialize superclass
	{
		if (view != nil) [self populateView:view]; else self = nil;
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (void)populateView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	NSBundle *bundle = [NSBundle bundleForClass:[self class]]; const CGFloat ch = [UXReaderFramework searchControlHeight];

	const CGFloat sf = ([UXReaderFramework isSmallDevice] ? 0.3 : 0.7); const CGFloat sp = floor(ch + (ch * sf));

	const CGFloat bf = ([UXReaderFramework isSmallDevice] ? 2.1 : 3.0); const CGFloat bi = floor(ch * bf);

// --------------------------------------------------------------------------------------------------------------------------------

	UIImage *closeImage = [UIImage imageNamed:@"UXReader-Search-Close" inBundle:bundle compatibleWithTraitCollection:nil];

	closeButton = [[UIButton alloc] initWithFrame:CGRectZero]; [closeButton setHidden:YES];
	[closeButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [closeButton setExclusiveTouch:YES];
	[closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[closeButton setImage:closeImage forState:UIControlStateNormal]; [closeButton setShowsTouchWhenHighlighted:YES];
	[closeButton setAlpha:0.0]; //[closeButton setBackgroundColor:[UIColor lightGrayColor]];
	[view addSubview:closeButton];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:ch]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:ch]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-bi]];

// --------------------------------------------------------------------------------------------------------------------------------

	UIImage *forwardImage = [UIImage imageNamed:@"UXReader-Search-Forward" inBundle:bundle compatibleWithTraitCollection:nil];

	forwardButton = [[UIButton alloc] initWithFrame:CGRectZero]; [forwardButton setHidden:YES];
	[forwardButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [forwardButton setExclusiveTouch:YES];
	[forwardButton addTarget:self action:@selector(forwardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[forwardButton setImage:forwardImage forState:UIControlStateNormal]; [forwardButton setShowsTouchWhenHighlighted:YES];
	[forwardButton setAlpha:0.0]; //[forwardButton setBackgroundColor:[UIColor lightGrayColor]];
	[view addSubview:forwardButton];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:forwardButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:ch]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:forwardButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:ch]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:forwardButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
														toItem:closeButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:+sp]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:forwardButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:closeButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

// --------------------------------------------------------------------------------------------------------------------------------

	UIImage *reverseImage = [UIImage imageNamed:@"UXReader-Search-Reverse" inBundle:bundle compatibleWithTraitCollection:nil];

	reverseButton = [[UIButton alloc] initWithFrame:CGRectZero]; [reverseButton setHidden:YES];
	[reverseButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [reverseButton setExclusiveTouch:YES];
	[reverseButton addTarget:self action:@selector(reverseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[reverseButton setImage:reverseImage forState:UIControlStateNormal]; [reverseButton setShowsTouchWhenHighlighted:YES];
	[reverseButton setAlpha:0.0]; //[reverseButton setBackgroundColor:[UIColor lightGrayColor]];
	[view addSubview:reverseButton];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:reverseButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:ch]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:reverseButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
														toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:ch]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:reverseButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
														toItem:closeButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-sp]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:reverseButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:closeButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

- (void)removeControls
{
	//NSLog(@"%s", __FUNCTION__);

	[closeButton removeFromSuperview]; [forwardButton removeFromSuperview]; [reverseButton removeFromSuperview];
}

- (void)setHidden:(BOOL)hidden
{
	//NSLog(@"%s %i", __FUNCTION__, hidden);

	[closeButton setHidden:hidden]; [forwardButton setHidden:hidden]; [reverseButton setHidden:hidden];
}

- (void)showControls:(BOOL)show
{
	//NSLog(@"%s %i", __FUNCTION__, show);

	if ((show == YES) && ([closeButton alpha] < 1.0))
	{
		const NSTimeInterval ti = [UXReaderFramework animationDuration]; [self setHidden:NO];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void)
		{
			[closeButton setAlpha:1.0]; [forwardButton setAlpha:1.0]; [reverseButton setAlpha:1.0];
		}
		completion:^(BOOL finished)
		{
		}];
	}

	if ((show != YES) && ([closeButton alpha] > 0.0))
	{
		const NSTimeInterval ti = [UXReaderFramework animationDuration]; //[self setHidden:NO];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void)
		{
			[closeButton setAlpha:0.0]; [forwardButton setAlpha:0.0]; [reverseButton setAlpha:0.0];
		}
		completion:^(BOOL finished)
		{
			[self setHidden:YES];
		}];
	}
}

#pragma mark - UIButton action methods

- (void)forwardButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	if ([delegate respondsToSelector:@selector(searchControl:forwardButton:)])
	{
		[delegate searchControl:self forwardButton:button];
	}
}

- (void)reverseButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	if ([delegate respondsToSelector:@selector(searchControl:reverseButton:)])
	{
		[delegate searchControl:self reverseButton:button];
	}
}

- (void)closeButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	if ([delegate respondsToSelector:@selector(searchControl:closeButton:)])
	{
		[delegate searchControl:self closeButton:button];
	}
}

@end

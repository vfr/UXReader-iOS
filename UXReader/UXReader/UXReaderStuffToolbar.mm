//
//	UXReaderStuffToolbar.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderStuffToolbar.h"
#import "UXReaderFramework.h"

@interface UXReaderStuffToolbar ()

@end

@implementation UXReaderStuffToolbar
{
	NSBundle *bundle;

	UIView *contentView;

	UISegmentedControl *showControl;

	UIButton *closeButton;

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
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

#pragma mark - UXReaderStuffToolbar instance methods

- (void)populateView:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	UIView *view = [self addEffectsView:self]; [self addSeparator:view];

	UIEdgeInsets lm = view.layoutMargins; lm.right += lm.right; view.layoutMargins = lm; [self layoutMarginsDidChange];

	const CGFloat th = [UXReaderFramework mainToolbarHeight]; const CGFloat sh = floor([UXReaderFramework statusBarHeight] * 0.5);

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const closeName = @"UXReader-Toolbar-Close";
	UIImage *closeImage = [UIImage imageNamed:closeName inBundle:bundle compatibleWithTraitCollection:nil];
	closeImage = [closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	closeButton = [[UIButton alloc] initWithFrame:CGRectZero]; //[closeButton setEnabled:NO];
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

	titleLabel = [[UILabel alloc] initWithFrame:CGRectZero]; //[titleLabel setEnabled:NO];
	[titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; [titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
	[titleLabel setTextColor:[UXReaderFramework toolbarTitleTextColor]]; [titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:[documentx title]]; [titleLabel setFont:[UIFont systemFontOfSize:16.0]];
	[titleLabel setAdjustsFontSizeToFitWidth:YES]; [titleLabel setMinimumScaleFactor:0.75];
	[titleLabel setHidden:[UXReaderFramework isSmallDevice]];
	[view addSubview:titleLabel]; //[titleLabel setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:closeButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];

// --------------------------------------------------------------------------------------------------------------------------------

	static NSString *const outlineName = @"UXReader-Toolbar-Outline";
	UIImage *outlineImage = [UIImage imageNamed:outlineName inBundle:bundle compatibleWithTraitCollection:nil];
	outlineImage = [outlineImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	static NSString *const previewName = @"UXReader-Toolbar-Preview";
	UIImage *previewImage = [UIImage imageNamed:previewName inBundle:bundle compatibleWithTraitCollection:nil];
	previewImage = [previewImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	static NSString *const optionsName = @"UXReader-Toolbar-Options";
	UIImage *optionsImage = [UIImage imageNamed:optionsName inBundle:bundle compatibleWithTraitCollection:nil];
	optionsImage = [optionsImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	showControl = [[UISegmentedControl alloc] initWithItems:@[outlineImage, previewImage, optionsImage]];
	[showControl setTranslatesAutoresizingMaskIntoConstraints:NO]; [showControl setExclusiveTouch:YES];
	[showControl addTarget:self action:@selector(showControlTapped:) forControlEvents:UIControlEventValueChanged];
	[showControl setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
	[view addSubview:showControl]; //[showControl setBackgroundColor:[UIColor lightGrayColor]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:showControl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:titleLabel attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:showControl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:showControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:sh]];
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

- (void)selectSegmentIndex:(NSInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	[showControl setSelectedSegmentIndex:index];
}

#pragma mark - UISegmentedControl action methods

- (void)showControlTapped:(UISegmentedControl *)control
{
	//NSLog(@"%s %@", __FUNCTION__, control);

	if ([delegate respondsToSelector:@selector(mainToolbar:showControl:)])
	{
		[delegate mainToolbar:self showControl:control];
	}
}

#pragma mark - UIButton action methods

- (void)closeButtonTapped:(UIButton *)button
{
	//NSLog(@"%s %@", __FUNCTION__, button);

	if ([delegate respondsToSelector:@selector(mainToolbar:closeButton:)])
	{
		[delegate mainToolbar:self closeButton:button];
	}
}

@end

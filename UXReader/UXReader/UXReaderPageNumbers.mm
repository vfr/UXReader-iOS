//
//	UXReaderPageNumbers.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderPageNumbers.h"

@implementation UXReaderPageNumbers
{
	NSString *textFormat;

	UILabel *textLabel;
}

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO; self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];

		[self setLayoutMargins:UIEdgeInsetsMake(6.0, 8.0, 6.0, 8.0)]; [self addTextLabel:self];

		NSBundle *bundle = [NSBundle bundleForClass:[self class]]; // Framework bundle

		textFormat = [bundle localizedStringForKey:@"%i of %i" value:nil table:nil];
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

	self.layer.shadowOpacity = 0.8; self.layer.shadowRadius = 1.0; self.layer.shadowOffset = CGSizeZero;

	self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self bounds]] CGPath];

	self.layer.shadowColor = [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor];
}

- (void)addTextLabel:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if ((textLabel = [[UILabel alloc] initWithFrame:CGRectZero])) // UILabel
	{
		[textLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; [textLabel setText:@"-"];
		[textLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
		[textLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
		[textLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]]; [textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setFont:[UIFont systemFontOfSize:16.0]];
		[view addSubview:textLabel];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTopMargin multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeBottomMargin multiplier:1.0 constant:0.0]];
	}
}

#pragma mark - UXReaderPageNumbers instance methods

- (void)showPageNumber:(NSUInteger)page ofPages:(NSUInteger)pages
{
	//NSLog(@"%s %i of %i", __FUNCTION__, int(page), int(pages));

	[textLabel setText:[NSString stringWithFormat:textFormat, int(page+1), int(pages)]];
}

- (void)showPageLabel:(nonnull NSString *)label
{
	//NSLog(@"%s '%@'", __FUNCTION__, label);

	[textLabel setText:[NSString stringWithFormat:@" %@ ", label]];
}

@end

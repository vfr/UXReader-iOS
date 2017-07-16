//
//	UXReaderThumbShow.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderThumbShow.h"
#import "UXReaderFramework.h"

@implementation UXReaderThumbShow
{
	UILabel *textLabel;

	UIView *highlightView;

	CGFloat shadowRadius;

	BOOL showCurrentPage;
}

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.userInteractionEnabled = NO; self.contentMode = UIViewContentModeScaleAspectFit;
		self.opaque = YES; self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		self.autoresizesSubviews = NO; self.hidden = YES;

		shadowRadius = 1.0; [self populateView:self];
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

	[highlightView setFrame:[self bounds]]; [self layoutTextLabel];

	if (self.layer.shadowOpacity != 0.0) [self setLayerShadow];
}

#pragma mark - UXReaderThumbShow instance methods

- (void)populateView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if ((textLabel = [[UILabel alloc] initWithFrame:CGRectZero]))
	{
		//[textLabel setTranslatesAutoresizingMaskIntoConstraints:YES];
		[textLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
		[textLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[textLabel setFont:[UIFont systemFontOfSize:12.0]]; [textLabel setText:@"-"];
		[textLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
		[textLabel setTextAlignment:NSTextAlignmentCenter];
		[view addSubview:textLabel];
	}

	if ((highlightView = [[UIView alloc] initWithFrame:[view bounds]]))
	{
		[highlightView setBackgroundColor:[UIColor clearColor]];
		//[highlightView setTranslatesAutoresizingMaskIntoConstraints:YES];
		[highlightView setContentMode:UIViewContentModeRedraw];
		[highlightView setUserInteractionEnabled:NO];
		[view addSubview:highlightView];
	}
}

- (void)prepareForUse
{
	//NSLog(@"%s", __FUNCTION__);

	if (self.layer.shadowOpacity == 0.0)
	{
		[self setHidden:NO]; [self setLayerShadow];
	}
}

- (void)prepareForReuse
{
	//NSLog(@"%s", __FUNCTION__);

	[self showCurrentPage:NO];

	[self setImage:nil];
}

- (void)setHighlighted:(BOOL)highlighted
{
	//NSLog(@"%s %i", __FUNCTION__, highlighted);

	[highlightView setBackgroundColor:(highlighted ? [UIColor colorWithWhite:0.0 alpha:0.25] : [UIColor clearColor])];
}

- (void)showText:(nonnull NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	[textLabel setText:text]; [self layoutTextLabel];
}

- (void)showCurrentPage:(BOOL)show
{
	//NSLog(@"%s %i", __FUNCTION__, show);

	if (show != showCurrentPage) // Change shadow color
	{
		showCurrentPage = show; shadowRadius = (show ? 2.0 : 1.0); self.layer.shadowRadius = shadowRadius;

		UIColor *c = (show ? [UIColor blueColor] : [UIColor blackColor]); self.layer.shadowColor = [c CGColor];
	}
}

- (void)setLayerShadow
{
	//NSLog(@"%s", __FUNCTION__);

	self.layer.shadowOpacity = 1.0; self.layer.shadowRadius = shadowRadius; self.layer.shadowOffset = CGSizeZero;

	self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self bounds]] CGPath];
}

- (void)layoutTextLabel
{
	//NSLog(@"%s", __FUNCTION__);

	NSDictionary<NSString *, id> *attributes = @{NSFontAttributeName : [textLabel font]};

	const CGRect bounds = [self bounds]; const UIEdgeInsets insets = [self layoutMargins];

	CGSize size = [[textLabel text] sizeWithAttributes:attributes]; size = UXSizeInflate(UXSizeCeil(size), 8.0, 2.0);

	const CGFloat mw = (bounds.size.width - insets.left - insets.right); if (size.width > mw) size.width = mw;

	CGRect frame = CGRectZero; frame.size = size; // Text label frame

	frame.origin.y = (bounds.size.height - size.height - insets.bottom);

	frame.origin.x = (bounds.size.width - size.width - insets.right);

	[textLabel setFrame:frame];
}

@end

//
//	UXReaderShadowView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderShadowView.h"

@implementation UXReaderShadowView

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO; self.userInteractionEnabled = NO;

		self.contentMode = UIViewContentModeRedraw; //self.backgroundColor = [UIColor clearColor];
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

@end

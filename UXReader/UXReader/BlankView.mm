//
//	BlankView.mm
//	UXReader Framework v1.0
//
//	Created by Julius Oklamcak on 2017-01-01.
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "BlankView.h"

@interface BlankView ()

@end

@implementation BlankView
{
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor lightGrayColor];
	}

	return self;
}

- (void)dealloc
{
	NSLog(@"%s", __FUNCTION__);
}

- (void)layoutSubviews
{
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

#pragma mark - BlankView instance methods

@end

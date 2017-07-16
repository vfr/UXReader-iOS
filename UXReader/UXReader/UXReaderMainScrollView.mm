//
//	UXReaderMainScrollView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderMainScrollView.h"

@implementation UXReaderMainScrollView

#pragma mark - Properties

@synthesize message;

#pragma mark - UIScrollView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.autoresizesSubviews = NO; self.delaysContentTouches = NO;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];
		self.showsHorizontalScrollIndicator = NO; self.showsVerticalScrollIndicator = NO;
		self.scrollsToTop = NO; self.pagingEnabled = YES;
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

@end

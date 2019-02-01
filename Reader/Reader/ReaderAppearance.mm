//
//	ReaderAppearance.mm
//	Reader v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "ReaderAppearance.h"

@implementation ReaderAppearance

#pragma mark - ReaderAppearance class methods

+ (BOOL)isSmallDevice
{
	//NSLog(@"%s", __FUNCTION__);

	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

+ (CGFloat)statusBarHeight
{
	//NSLog(@"%s", __FUNCTION__);

	const CGRect frame = [[UIApplication sharedApplication] statusBarFrame];

	const CGFloat w = frame.size.width; const CGFloat h = frame.size.height;

	return ((h < w) ? h : w); // Should be 0.0 or 20.0
}

+ (CGFloat)mainToolbarHeight
{
	//NSLog(@"%s", __FUNCTION__);

	return 44.0; // Points
}

+ (NSTimeInterval)searchBeginTimer
{
	//NSLog(@"%s", __FUNCTION__);

	return 1.25; // Seconds
}

+ (NSTimeInterval)animationDuration
{
	//NSLog(@"%s", __FUNCTION__);

	return 0.25; // Seconds
}

+ (nonnull UIColor *)controlTintColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.24 alpha:1.00];
}

+ (nonnull UIColor *)toolbarTitleTextColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.24 alpha:1.00];
}

+ (nonnull UIColor *)toolbarBackgroundColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:1.00 alpha:0.20];
}

+ (nonnull UIColor *)toolbarSeparatorLineColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.64 alpha:0.92];
}

+ (nonnull UIColor *)lightTextColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.64 alpha:1.00];
}

+ (BOOL)showRTL
{
	//NSLog(@"%s", __FUNCTION__);

	const UIApplication *application = [UIApplication sharedApplication];

	const UIUserInterfaceLayoutDirection direction = [application userInterfaceLayoutDirection];

	return (direction == UIUserInterfaceLayoutDirectionRightToLeft);
}

@end

//
//	ReaderAppearance.h
//	Reader v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReaderAppearance : NSObject <NSObject>

+ (BOOL)isSmallDevice;

+ (CGFloat)statusBarHeight;

+ (CGFloat)mainToolbarHeight;

+ (NSTimeInterval)searchBeginTimer;

+ (NSTimeInterval)animationDuration;

+ (nonnull UIColor *)controlTintColor;

+ (nonnull UIColor *)toolbarTitleTextColor;

+ (nonnull UIColor *)toolbarBackgroundColor;

+ (nonnull UIColor *)toolbarSeparatorLineColor;

+ (nonnull UIColor *)lightTextColor;

@end

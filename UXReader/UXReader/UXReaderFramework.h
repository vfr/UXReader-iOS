//
//	UXReaderFramework.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UXReaderFramework : NSObject <NSObject>

+ (nullable instancetype)sharedInstance;

+ (BOOL)isSmallDevice;

+ (CGFloat)statusBarHeight;

+ (CGFloat)mainToolbarHeight;

+ (CGFloat)pageToolbarHeight;

+ (CGFloat)searchControlHeight;

+ (NSTimeInterval)searchBeginTimer;

+ (NSTimeInterval)animationDuration;

+ (nonnull UIColor *)toolbarTitleTextColor;

+ (nonnull UIColor *)toolbarBackgroundColor;

+ (nonnull UIColor *)toolbarSeparatorLineColor;

+ (nonnull UIColor *)scrollViewBackgroundColor;

+ (nonnull UIColor *)lightTextColor;

+ (void)dispatch_sync_on_work_queue:(nonnull dispatch_block_t)block;

+ (void)dispatch_async_on_work_queue:(nonnull dispatch_block_t)block;

+ (nonnull NSMutableDictionary<NSString *, id> *)defaults;

+ (void)saveDefaults;

+ (size_t)deviceMemory;

+ (nonnull NSString *)deviceModel;

+ (uint64_t)time:(uint64_t)from;

+ (uint64_t)time;

@end

CG_INLINE CGRect UXRectScale(CGRect rect, const CGFloat sx, const CGFloat sy)
{
	rect.origin.x *= sx; rect.size.width *= sx; rect.origin.y *= sy; rect.size.height *= sy; return rect;
}

CG_INLINE CGSize UXSizeScale(CGSize size, const CGFloat sx, const CGFloat sy)
{
	size.width *= sx; size.height *= sy; return size;
}

CG_INLINE CGSize UXSizeInflate(CGSize size, const CGFloat dw, const CGFloat dh)
{
	size.width += dw; size.height += dh; return size;
}

CG_INLINE CGSize UXSizeCeil(CGSize size)
{
	size.width = ceil(size.width); size.height = ceil(size.height); return size;
}

CG_INLINE CGSize UXSizeFloor(CGSize size)
{
	size.width = floor(size.width); size.height = floor(size.height); return size;
}

CG_INLINE CGSize UXSizeSwap(const CGSize size)
{
	CGSize swap; swap.width = size.height; swap.height = size.width; return swap;
}

CG_INLINE CGSize UXAspectFitInSize(CGFloat max, CGSize size)
{
	const CGFloat ws = (max / size.width); const CGFloat hs = (max / size.height); const CGFloat ts = ((ws < hs) ? ws : hs);

	const CGFloat tw = floor(size.width * ts); const CGFloat th = floor(size.height * ts); return CGSizeMake(tw, th);
}

CG_INLINE CGFloat UXScaleThatFits(CGSize target, CGSize source)
{
	const CGFloat ws = (target.width / source.width); const CGFloat hs = (target.height / source.height);

	return ((ws < hs) ? ws : hs);
}

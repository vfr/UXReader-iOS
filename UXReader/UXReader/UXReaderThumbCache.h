//
//	UXReaderThumbCache.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UXReaderThumbCache : NSObject <NSObject>

+ (nullable instancetype)sharedInstance; // Singleton

+ (nullable UIImage *)loadThumbForUUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size;

+ (void)saveThumb:(nonnull UIImage *)thumb UUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size;

+ (void)touchDirectoryForUUID:(nonnull NSUUID *)UUID;

+ (void)purgeDiskThumbCache:(NSTimeInterval)age;

+ (void)purgeMemoryThumbCache;

@end

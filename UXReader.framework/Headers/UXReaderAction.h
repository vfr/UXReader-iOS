//
//	UXReaderAction.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDestination;

typedef NS_ENUM(NSUInteger, UXReaderActionType)
{
	UXReaderActionTypeNone, UXReaderActionTypeURI, UXReaderActionTypeGoto,
	UXReaderActionTypeRemoteGoto, UXReaderActionTypeLaunch, UXReaderActionTypeLink
};

@interface UXReaderAction : NSObject <NSObject>

- (nullable instancetype)initWithURI:(nonnull NSString *)URI rectangle:(CGRect)rect;

- (nullable instancetype)initWithGoto:(nonnull UXReaderDestination *)destination rectangle:(CGRect)rect;

- (nullable instancetype)initWithRemoteGoto:(nonnull UXReaderDestination *)destination path:(nonnull NSString *)path rectangle:(CGRect)rect;

- (nullable instancetype)initWithLaunch:(nonnull NSString *)path rectangle:(CGRect)rect;

- (nullable instancetype)initWithLink:(nonnull NSString *)URI rectangles:(nonnull NSArray<NSValue *> *)rectangles;

- (BOOL)containsPoint:(CGPoint)point;

- (UXReaderActionType)type;

- (nullable NSString *)URI;

- (nullable NSString *)path;

- (nullable UXReaderDestination *)destination;

- (nullable NSArray<NSValue *> *)rectangles;

- (CGRect)rectangle;

@end

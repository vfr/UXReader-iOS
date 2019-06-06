//
//	UXReaderOutline.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderAction;

@interface UXReaderOutline : NSObject <NSObject>

- (nullable instancetype)initWithName:(nonnull NSString *)name action:(nonnull UXReaderAction *)action level:(NSUInteger)level;

- (nonnull NSString *)name;

- (nonnull UXReaderAction *)action;

- (NSUInteger)level;

@end

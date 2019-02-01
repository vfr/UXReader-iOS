//
//	UXReaderCanceller.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UXReaderCanceller : NSObject <NSObject>

- (nullable instancetype)initWithLock;

- (nullable instancetype)initWithUUID;

- (void)cancel;

- (BOOL)isCancelled;

- (nonnull NSLock *)lock;

- (nonnull NSUUID *)UUID;

@end

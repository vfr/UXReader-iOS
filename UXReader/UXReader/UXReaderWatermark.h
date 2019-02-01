//
//	UXReaderWatermark.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UXReaderDocument.h"

//
//	This class demonstrates implementing watermarking document page display
//	by adopting and implementing the UXReaderRenderTileInContext protocol.
//

@interface UXReaderWatermark : NSObject <NSObject, UXReaderRenderTileInContext>

- (nullable instancetype)initWithText:(nonnull NSArray<NSString *> *)lines NS_DESIGNATED_INITIALIZER;

@end

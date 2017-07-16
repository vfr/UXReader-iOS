//
//	UXReaderSelection.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;

@interface UXReaderSelection : NSObject <NSObject>

+ (nullable instancetype)document:(nonnull UXReaderDocument *)document page:(NSUInteger)page index:(NSUInteger)index count:(NSUInteger)count rectangles:(nonnull NSArray<NSValue *> *)rectangles;

- (NSUInteger)page;

- (nullable NSArray<NSValue *> *)rectangles;
- (CGRect)rectangle;

- (void)setHighlight:(BOOL)state;
- (BOOL)isHighlighted;

@end

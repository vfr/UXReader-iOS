//
//	UXReaderDocumentPage.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderCanceller;
@class UXReaderSelection;
@class UXReaderAction;

@interface UXReaderDocumentPage : NSObject <NSObject>

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document page:(NSUInteger)page;

- (nonnull UXReaderDocument *)document;

- (nullable void *)pdfPageCG;
- (nullable void *)pdfPageFP;

- (nullable void *)textPage;

- (NSUInteger)page;
- (NSUInteger)rotation;
- (CGSize)pageSize;

- (CGRect)convertToPageFromViewRect:(CGRect)rect;
- (CGPoint)convertToPageFromViewPoint:(CGPoint)point;
- (CGRect)convertFromPageX1:(CGFloat)x1 Y1:(CGFloat)y1 X2:(CGFloat)x2 Y2:(CGFloat)y2;

- (void)renderTileInContext:(nonnull CGContextRef)context;

- (void)thumbWithSize:(CGSize)size canceller:(nonnull UXReaderCanceller *)canceller completion:(nonnull void (^)(UIImage *_Nonnull thumb))handler;

- (void)setSearchSelections:(nullable NSArray<UXReaderSelection *> *)selections;
- (nullable NSArray<UXReaderSelection *> *)searchSelections;

- (nullable UXReaderAction *)linkAction:(CGPoint)point;
- (nullable UXReaderAction *)textAction:(CGPoint)point;

- (BOOL)extractPageLinks;
- (BOOL)extractPageURLs;

- (NSUInteger)unicharCount;
- (nullable NSString *)text;
- (nullable NSString *)textAtIndex:(NSUInteger)index count:(NSUInteger)count;
- (unichar)unicharAtIndex:(NSUInteger)index;
- (CGFloat)unicharFontSizeAtIndex:(NSUInteger)index;
- (CGRect)unicharRectangleAtIndex:(NSUInteger)index;
- (NSUInteger)unicharIndexAtPoint:(CGPoint)point tolerance:(CGSize)size;
- (nonnull NSArray<NSValue *> *)rectanglesForTextAtIndex:(NSUInteger)index count:(NSUInteger)count;
- (nullable NSString *)textInRectangle:(CGRect)rectangle;

@end

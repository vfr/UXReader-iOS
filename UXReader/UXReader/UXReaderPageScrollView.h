//
//	UXReaderPageScrollView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderPageScrollView;
@class UXReaderDocumentPage;
@class UXReaderSelection;
@class UXReaderAction;

@protocol UXReaderPageScrollViewDelegate <NSObject>

@required // Delegate protocols

- (void)pageScrollView:(nonnull UXReaderPageScrollView *)view touchesBegan:(nonnull NSSet *)touches;

@end

@interface UXReaderPageScrollView : UIScrollView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderPageScrollViewDelegate> message;

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document page:(NSUInteger)page;

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document pages:(nonnull NSIndexSet *)pages;

- (nullable UXReaderAction *)processSingleTap:(nonnull UITapGestureRecognizer *)recognizer;

- (void)zoomIncrement:(nonnull UITapGestureRecognizer *)recognizer;
- (void)zoomDecrement:(nonnull UITapGestureRecognizer *)recognizer;

- (void)ensureVisibleSelection:(nonnull UXReaderSelection *)selection;

- (CGRect)frameForPage:(NSUInteger)page inView:(nonnull UIView *)inView;

- (BOOL)containsPage:(NSUInteger)page;

- (void)pageNeedsDisplay;

- (void)wentOffScreen;

- (void)resetZoom;

@end

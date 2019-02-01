//
//	UXReaderThumbsView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderThumbsView;

@protocol UXReaderThumbsViewDelegate <NSObject>

@required // Delegate protocols

- (void)thumbsView:(nonnull UXReaderThumbsView *)view gotoPage:(NSUInteger)page;
- (CGRect)thumbsView:(nonnull UXReaderThumbsView *)view frameForPage:(NSUInteger)page inView:(nonnull UIView *)inView;
- (void)thumbsView:(nonnull UXReaderThumbsView *)view dismiss:(nullable id)that;

@end

@interface UXReaderThumbsView : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderThumbsViewDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (void)setCurrentPage:(NSUInteger)page;

- (void)didAppear;

@end

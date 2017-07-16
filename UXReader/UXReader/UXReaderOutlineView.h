//
//	UXReaderOutlineView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderOutlineView;

@protocol UXReaderOutlineViewDelegate <NSObject>

@required // Delegate protocols

- (void)outlineView:(nonnull UXReaderOutlineView *)view gotoPage:(NSUInteger)page;
- (void)outlineView:(nonnull UXReaderOutlineView *)view dismiss:(nullable id)that;

@end

@interface UXReaderOutlineView : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderOutlineViewDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (void)setCurrentPage:(NSUInteger)page;

- (void)didAppear;

@end

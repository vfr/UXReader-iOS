//
//	UXReaderPageControl.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderPageControl;

@protocol UXReaderPageControlDelegate <NSObject>

@required // Delegate protocols

- (void)pageControl:(nonnull UXReaderPageControl *)control trackPage:(NSUInteger)page;
- (void)pageControl:(nonnull UXReaderPageControl *)control gotoPage:(NSUInteger)page;

@end

@interface UXReaderPageControl : UIControl

@property (nullable, weak, nonatomic, readwrite) id <UXReaderPageControlDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (void)showPageNumber:(NSUInteger)page ofPages:(NSUInteger)pages;

@end

//
//	UXReaderSearchControl.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderSearchControl;

@protocol UXReaderSearchControlDelegate <NSObject>

@required // Delegate protocols

- (void)searchControl:(nonnull UXReaderSearchControl *)control closeButton:(nonnull UIButton *)button;
- (void)searchControl:(nonnull UXReaderSearchControl *)control forwardButton:(nonnull UIButton *)button;
- (void)searchControl:(nonnull UXReaderSearchControl *)control reverseButton:(nonnull UIButton *)button;

@end

@interface UXReaderSearchControl : NSObject <NSObject>

@property (nullable, weak, nonatomic, readwrite) id <UXReaderSearchControlDelegate> delegate;

- (nullable instancetype)initWithView:(nonnull UIView *)view;

- (void)showControls:(BOOL)show;

- (void)removeControls;

@end

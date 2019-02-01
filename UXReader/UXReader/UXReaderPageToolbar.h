//
//	UXReaderPageToolbar.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderPageToolbar;

@protocol UXReaderPageToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)pageToolbar:(nonnull UXReaderPageToolbar *)toolbar gotoPage:(NSUInteger)page;

@end

@interface UXReaderPageToolbar : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderPageToolbarDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (void)showPageNumber:(NSUInteger)page ofPages:(NSUInteger)pages;

- (void)setLayoutConstraintY:(nonnull NSLayoutConstraint *)constraint;

- (void)setEnabled:(BOOL)enabled;

- (void)hideAnimated;
- (void)showAnimated;
- (BOOL)isVisible;

@end

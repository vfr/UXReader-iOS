//
//	UXReaderMainToolbar.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderMainToolbar;

@protocol UXReaderMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar closeButton:(nonnull UIButton *)button;
- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar shareButton:(nonnull UIButton *)button;
- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar stuffButton:(nonnull UIButton *)button;

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar searchButton:(nonnull UIButton *)button;
- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar searchTextDidChange:(nonnull NSString *)text;
- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar beginSearching:(nonnull NSString *)text;

@end

@interface UXReaderMainToolbar : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderMainToolbarDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (void)setLayoutConstraintY:(nonnull NSLayoutConstraint *)constraint;

- (void)stuffButtonWhat:(NSUInteger)index;

- (void)setAllowShare:(BOOL)allow;

- (void)clearSearchText;
- (void)showSearchBusy:(BOOL)show;
- (void)showFound:(NSUInteger)x of:(NSUInteger)n;
- (void)showFound:(NSUInteger)x of:(NSUInteger)n on:(NSUInteger)o;
- (void)showFoundCount:(NSUInteger)count;
- (void)showSearchNotFound;
- (void)dismissKeyboard;

- (void)setEnabled:(BOOL)enabled;

- (void)hideAnimated;
- (void)showAnimated;
- (BOOL)isVisible;

@end

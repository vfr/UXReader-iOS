//
//	ReaderUpperToolbar.h
//	Reader v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReaderUpperToolbar;

@protocol ReaderUpperToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)upperToolbar:(nonnull ReaderUpperToolbar *)toolbar optionsButton:(nonnull UIButton *)button;
- (void)upperToolbar:(nonnull ReaderUpperToolbar *)toolbar searchTextDidChange:(nonnull NSString *)text;
- (void)upperToolbar:(nonnull ReaderUpperToolbar *)toolbar beginSearching:(nonnull NSString *)text;

@end

@interface ReaderUpperToolbar : UIView

@property (nullable, weak, nonatomic, readwrite) id <ReaderUpperToolbarDelegate> delegate;

- (void)setEnabled:(BOOL)enabled;

- (void)dismissKeyboard;

@end

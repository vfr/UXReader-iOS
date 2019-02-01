//
//	UXReaderStuffToolbar.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderStuffToolbar;

@protocol UXReaderStuffToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)mainToolbar:(nonnull UXReaderStuffToolbar *)toolbar showControl:(nonnull UISegmentedControl *)control;
- (void)mainToolbar:(nonnull UXReaderStuffToolbar *)toolbar closeButton:(nonnull UIButton *)button;

@end

@interface UXReaderStuffToolbar : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderStuffToolbarDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (void)selectSegmentIndex:(NSInteger)index;

@end

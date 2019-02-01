//
//	UXReaderThumbShow.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UXReaderThumbShow : UIImageView

- (void)prepareForUse;

- (void)prepareForReuse;

- (void)setHighlighted:(BOOL)highlighted;

- (void)showText:(nonnull NSString *)text;

- (void)showCurrentPage:(BOOL)show;

@end

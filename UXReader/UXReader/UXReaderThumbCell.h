//
//	UXReaderThumbCell.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderThumbShow;

@interface UXReaderThumbCell : UICollectionViewCell

- (void)requestThumb:(nonnull UXReaderDocument *)document page:(NSUInteger)page;

- (nullable UXReaderThumbShow *)thumbShow;

- (void)showText:(nonnull NSString *)text;

- (void)showCurrentPage:(BOOL)show;

@end

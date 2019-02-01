//
//	UXReaderPageImageView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;

@interface UXReaderPageImageView : UIImageView

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document page:(NSUInteger)page;

@end

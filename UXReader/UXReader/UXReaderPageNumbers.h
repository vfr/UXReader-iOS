//
//	UXReaderPageNumbers.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UXReaderPageNumbers : UIView

- (void)showPageNumber:(NSUInteger)page ofPages:(NSUInteger)pages;

- (void)showPageLabel:(nonnull NSString *)label;

@end

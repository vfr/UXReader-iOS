//
//	ReaderLowerToolbar.h
//	Reader v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReaderLowerToolbar;

@protocol ReaderLowerToolbarDelegate <NSObject>

@required // Delegate protocols

@end

@interface ReaderLowerToolbar : UIView

@property (nullable, weak, nonatomic, readwrite) id <ReaderLowerToolbarDelegate> delegate;

- (void)setEnabled:(BOOL)enabled;

@end

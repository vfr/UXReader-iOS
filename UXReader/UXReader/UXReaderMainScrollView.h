//
//	UXReaderMainScrollView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderMainScrollView;

@protocol UXReaderMainScrollViewDelegate <NSObject>

@required // Delegate protocols

@end

@interface UXReaderMainScrollView : UIScrollView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderMainScrollViewDelegate> message;

@end

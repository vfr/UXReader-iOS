//
//	BlankView.h
//	UXReader Framework v1.0
//
//	Created by Julius Oklamcak on 2017-01-01.
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlankView;

@protocol BlankViewDelegate <NSObject>

@required // Delegate protocols

@end

@interface BlankView : UIView

@property (nullable, weak, nonatomic, readwrite) id <BlankViewDelegate> delegate;

@end

//
//	BlankViewController.h
//	UXReader Framework v1.0
//
//	Created by Julius Oklamcak on 2017-01-01.
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlankViewController;

@protocol BlankViewControllerDelegate <NSObject>

@required // Delegate protocols

- (void)dismissBlankViewController:(nonnull BlankViewController *)viewController;

@end

@interface BlankViewController : UIViewController

@property (nullable, weak, nonatomic, readwrite) id <BlankViewControllerDelegate> delegate;

@end

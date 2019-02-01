//
//	ReaderViewController.h
//	Reader v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class ReaderViewController;

@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)readerViewController:(nonnull ReaderViewController *)viewController showDocument:(nonnull UXReaderDocument *)document;

@end

@interface ReaderViewController : UIViewController

@property (nullable, weak, nonatomic, readwrite) id <ReaderViewControllerDelegate> delegate;

@end

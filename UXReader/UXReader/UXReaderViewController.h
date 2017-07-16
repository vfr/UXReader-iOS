//
//	UXReaderViewController.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderViewController;

typedef NS_ENUM(NSUInteger, UXReaderDisplayMode)
{
	UXReaderDisplayModeSinglePageScrollH, // Horizontal scroll
	UXReaderDisplayModeSinglePageScrollV, // Vertical scroll
	UXReaderDisplayModeDoublePageScrollH, // Horizontal scroll
	UXReaderDisplayModeDoublePageScrollV, // Vertical scroll
};

typedef NS_OPTIONS(NSUInteger, UXReaderPermissions)
{
	UXReaderPermissionAllowAll = 0xFFFF,
	UXReaderPermissionAllowNone = 0x0000,
	UXReaderPermissionAllowShare = (1 << 0),
	UXReaderPermissionAllowEmail = (1 << 1),
	UXReaderPermissionAllowPrint = (1 << 2),
	UXReaderPermissionAllowCopy = (1 << 3),
	UXReaderPermissionAllowSave = (1 << 4)
};

@protocol UXReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)readerViewController:(nonnull UXReaderViewController *)viewController didChangePage:(NSUInteger)page;
- (void)readerViewController:(nonnull UXReaderViewController *)viewController didChangeDocument:(nullable UXReaderDocument *)document;
- (void)readerViewController:(nonnull UXReaderViewController *)viewController didChangeMode:(UXReaderDisplayMode)mode;

@required // Delegate protocols

- (void)dismissReaderViewController:(nonnull UXReaderViewController *)viewController;

@end

@interface UXReaderViewController : UIViewController

@property (nullable, weak, nonatomic, readwrite) id <UXReaderViewControllerDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (nonnull UXReaderDocument *)document;
- (void)setDocument:(nonnull UXReaderDocument *)document;
- (BOOL)hasDocument:(nonnull UXReaderDocument *)document;

- (void)setPermissions:(UXReaderPermissions)permissions;
- (UXReaderPermissions)permissions;

- (void)setDisplayMode:(UXReaderDisplayMode)mode;
- (UXReaderDisplayMode)displayMode;

/*!
 Set the default page to which the document will be opened. Call before presenting UXReaderViewController.

 @param page Default page index.
*/
- (void)setDefaultPage:(NSUInteger)page;

@end

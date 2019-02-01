//
//	UXReaderStuffController.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderStuffController;

@protocol UXReaderStuffControllerDelegate <NSObject>

@required // Delegate protocols

- (void)stuffController:(nonnull UXReaderStuffController *)controller gotoPage:(NSUInteger)page;
- (void)stuffController:(nonnull UXReaderStuffController *)controller setDisplayMode:(NSUInteger)displayMode;
- (void)stuffController:(nonnull UXReaderStuffController *)controller setSearchMatch:(NSUInteger)searchMatch;

- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getCurrentPage:(nullable id)o;
- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getCurrentWhat:(nullable id)o;
- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getDisplayMode:(nullable id)o;
- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getSearchMatch:(nullable id)o;

- (CGRect)stuffController:(nonnull UXReaderStuffController *)controller frameForPage:(NSUInteger)page inView:(nonnull UIView *)inView;

- (void)dismissStuffController:(nonnull UXReaderStuffController *)controller currentWhat:(NSUInteger)index;

@end

@interface UXReaderStuffController : UIViewController

@property (nullable, weak, nonatomic, readwrite) id <UXReaderStuffControllerDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (nonnull UXReaderDocument *)document;
- (void)setDocument:(nonnull UXReaderDocument *)document;

@end

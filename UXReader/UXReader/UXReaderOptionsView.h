//
//	UXReaderOptionsView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderOptionsView;

@protocol UXReaderOptionsViewDelegate <NSObject>

@required // Delegate protocols

- (NSUInteger)optionsView:(nonnull UXReaderOptionsView *)view getDisplayMode:(nullable id)o;
- (NSUInteger)optionsView:(nonnull UXReaderOptionsView *)view getSearchMatch:(nullable id)o;

- (void)optionsView:(nonnull UXReaderOptionsView *)view setDisplayMode:(NSUInteger)displayMode;
- (void)optionsView:(nonnull UXReaderOptionsView *)view setSearchMatch:(NSUInteger)searchMatch;

@end

@interface UXReaderOptionsView : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderOptionsViewDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;

- (void)setCurrentPage:(NSUInteger)page;

- (void)didAppear;

@end

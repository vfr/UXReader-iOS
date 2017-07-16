//
//	UXReaderSearchView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderSearchView;

@protocol UXReaderSearchViewDelegate <NSObject>

@required // Delegate protocols

- (void)searchView:(nonnull UXReaderSearchView *)view searchTextDidChange:(nonnull NSString *)text;
- (void)searchView:(nonnull UXReaderSearchView *)view beginSearching:(nonnull NSString *)text;

@end

@interface UXReaderSearchView : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderSearchViewDelegate> delegate;

- (void)clearSearchText;
- (void)showSearchBusy:(BOOL)show;
- (void)showFound:(NSUInteger)x of:(NSUInteger)n;
- (void)showFound:(NSUInteger)x of:(NSUInteger)n on:(NSUInteger)o;
- (void)showFoundCount:(NSUInteger)count;
- (void)showSearchNotFound;
- (void)dismissKeyboard;

- (void)hideAnimated;
- (void)showAnimated;
- (BOOL)isVisible;

@end

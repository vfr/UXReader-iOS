//
//	UXReaderPageTiledView.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderPageTiledView;
@class UXReaderDocumentPage;
@class UXReaderAction;

@protocol UXReaderPageTiledViewDelegate <NSObject>

@required // Delegate protocols

@end

@interface UXReaderPageTiledView : UIView

@property (nullable, weak, nonatomic, readwrite) id <UXReaderPageTiledViewDelegate> delegate;

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)document page:(NSUInteger)page;

- (nullable UXReaderAction *)processSingleTap:(nonnull UITapGestureRecognizer *)recognizer;

@end

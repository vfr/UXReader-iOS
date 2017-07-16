//
//	UXReaderDocument.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderDocumentPage;
@class UXReaderCanceller;
@class UXReaderSelection;
@class UXReaderOutline;

typedef NS_ENUM(NSUInteger, UXReaderSearchOptions)
{
	UXReaderCaseSensitiveSearchOption = 1,
	UXReaderCaseInsensitiveSearchOption = 0,
	UXReaderMatchWholeWordSearchOption = 2
};

@protocol UXReaderDocumentSearchDelegate <NSObject>

@optional // Delegate protocols

- (void)document:(nonnull UXReaderDocument *)document didBeginDocumentSearch:(NSUInteger)kind;
- (void)document:(nonnull UXReaderDocument *)document didFinishDocumentSearch:(NSUInteger)total;
- (void)document:(nonnull UXReaderDocument *)document didBeginPageSearch:(NSUInteger)page pages:(NSUInteger)pages;
- (void)document:(nonnull UXReaderDocument *)document didFinishPageSearch:(NSUInteger)page total:(NSUInteger)total;

@required // Delegate protocols

- (void)document:(nonnull UXReaderDocument *)document searchDidMatch:(nonnull NSArray<UXReaderSelection *> *)selections page:(NSUInteger)page;

@end

@protocol UXReaderDocumentDataSource <NSObject>

@required // Data source protocols

- (BOOL)document:(nonnull UXReaderDocument *)document dataLength:(nonnull size_t *)length;
- (BOOL)document:(nonnull UXReaderDocument *)document offset:(size_t)offset length:(size_t)length buffer:(nonnull uint8_t *)buffer;
- (BOOL)document:(nonnull UXReaderDocument *)document UUID:(NSUUID * _Nullable * _Nullable)uuid;

@end

@protocol UXReaderRenderTileInContext <NSObject>

@required // Tile render protocol

- (void)documentPage:(nonnull UXReaderDocumentPage *)documentPage renderTileInContext:(nonnull CGContextRef)context;

@end

@interface UXReaderDocument : NSObject <NSObject>

@property (nullable, weak, nonatomic, readwrite) id <UXReaderDocumentSearchDelegate> search;

- (nullable instancetype)initWithURL:(nonnull NSURL *)URL;
- (nullable instancetype)initWithData:(nonnull NSData *)data;
- (nullable instancetype)initWithSource:(nonnull id <UXReaderDocumentDataSource>)source;

- (void)close;

- (nullable NSURL *)URL;
- (nullable NSData *)data;

- (void)setUUID:(nonnull NSUUID *)UUID;
- (nonnull NSUUID *)UUID;

- (void)setTitle:(nonnull NSString *)text;
- (nullable NSString *)title;

- (void)setShowRTL:(BOOL)RTL;
- (BOOL)showRTL;

- (void)setHighlightLinks:(BOOL)RTL;
- (BOOL)highlightLinks;

- (void)setRenderTile:(nullable id <UXReaderRenderTileInContext>)renderTile;
- (nullable id <UXReaderRenderTileInContext>)renderTile;

- (void)setUseNativeRendering;

- (uint32_t)permissions;
- (nullable NSString *)fileVersion;

- (BOOL)isSameDocument:(nonnull UXReaderDocument *)document;

- (void)openWithPassword:(nullable NSString *)password completion:(nonnull void (^)(NSError *_Nullable error))handler;
- (BOOL)isOpen;

- (nullable void *)pdfDocumentCG;
- (nullable void *)pdfDocumentFP;

- (NSUInteger)pageCount;

- (CGSize)pageSize:(NSUInteger)page;

- (nullable UXReaderDocumentPage *)documentPage:(NSUInteger)page;

- (nullable NSString *)pageLabel:(NSUInteger)page;

- (BOOL)isSearching;
- (void)cancelSearch;
- (void)beginSearch:(nonnull NSString *)text options:(UXReaderSearchOptions)options;

- (void)setSearchSelections:(nullable NSDictionary<NSNumber *, NSArray<UXReaderSelection *> *> *)selections;
- (nullable NSDictionary<NSNumber *, NSArray<UXReaderSelection *> *> *)searchSelections;

- (void)thumbForPage:(NSUInteger)page size:(CGSize)size canceller:(nonnull UXReaderCanceller *)canceller completion:(nonnull void (^)(UIImage *_Nonnull thumb))handler;

- (nullable NSDictionary<NSString *, NSString *> *)information;

- (nullable NSArray<UXReaderOutline *> *)outline;

@end

typedef NS_OPTIONS(NSUInteger, UXReaderDocumentPermission)
{
	UXReaderDocumentPermissionCopy = (1 << 5),
	UXReaderDocumentPermissionModify = (1 << 4),
	UXReaderDocumentPermissionPrint = (1 << 3)
};

typedef NS_ENUM(NSUInteger, UXReaderDocumentError)
{
	UXReaderDocumentErrorSuccess = 0,
	UXReaderDocumentErrorUnknown = 1,
	UXReaderDocumentErrorFile = 2,
	UXReaderDocumentErrorFormat = 3,
	UXReaderDocumentErrorPassword = 4,
	UXReaderDocumentErrorSecurity = 5,
	UXReaderDocumentErrorPage = 6
};

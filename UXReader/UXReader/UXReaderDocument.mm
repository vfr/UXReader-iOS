//
//	UXReaderDocument.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderDocumentPage.h"
#import "UXReaderThumbCache.h"
#import "UXReaderCanceller.h"
#import "UXReaderSelection.h"
#import "UXReaderFramework.h"

#import "UXReaderAction.h"
#import "UXReaderDestination.h"
#import "UXReaderOutline.h"

#import "fpdfview.h"
#import "fpdf_text.h"
#import "fpdf_doc.h"

#import <CommonCrypto/CommonDigest.h>

@interface UXReaderDocument () <UXReaderDocumentDataSource>

@end

@implementation UXReaderDocument
{
	NSURL *documentURL; NSData *documentData;

	__weak id <UXReaderDocumentDataSource> dataSource;

	__weak id <UXReaderRenderTileInContext> renderTile;

	NSMapTable<NSNumber *, UXReaderDocumentPage *> *documentPages;

	FPDF_DOCUMENT pdfDocumentFP; uint32_t permissions; int32_t security;

	NSDictionary<NSNumber *, NSArray<UXReaderSelection *> *> *searchSelections;

	CGPDFDocumentRef pdfDocumentCG; CGDataProviderRef dataProviderCG;

	NSMutableDictionary<NSNumber *, NSString *> *pageLabels;

	NSMutableDictionary<NSNumber *, NSValue *> *pageSizes;

	NSUInteger pageCount; NSString *title; NSUUID *UUID;

	NSDictionary<NSString *, NSString *> *information;

	NSArray<UXReaderOutline *> *outline;

	NSString *fileVersion; NSNumber *showRTL;

	BOOL nativeRendering; BOOL highlightLinks;

	UXReaderCanceller *searchCanceller;
}

#pragma mark - Properties

@synthesize search;

#pragma mark - UXReaderDocument functions

static int GetDataBlock(void *object, unsigned long offset, unsigned char *buffer, unsigned long length)
{
	//NSLog(@"%s %p %lu %lu %p", __FUNCTION__, object, offset, length, buffer);

	UXReaderDocument *self = (__bridge UXReaderDocument *)object; // Data source

	return [self->dataSource document:self offset:offset length:length buffer:buffer];
}

#pragma mark - UXReaderDocument instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		documentPages = [NSMapTable strongToWeakObjectsMapTable];
	}

	return self;
}

- (nullable instancetype)initWithURL:(nonnull NSURL *)URL
{
	//NSLog(@"%s %@", __FUNCTION__, URL);

	if ((self = [self init])) // Initialize self
	{
		if (URL != nil) documentURL = [URL copy]; else self = nil;
	}

	return self;
}

- (nullable instancetype)initWithData:(nonnull NSData *)data
{
	//NSLog(@"%s %p", __FUNCTION__, data);

	if ((self = [self init])) // Initialize self
	{
		if (data != nil) documentData = [data copy]; else self = nil;
	}

	return self;
}

- (nullable instancetype)initWithSource:(nonnull id <UXReaderDocumentDataSource>)source
{
	//NSLog(@"%s %@", __FUNCTION__, source);

	if ((self = [self init])) // Initialize self
	{
		if (source != nil) dataSource = source; else self = nil;
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);

	dataSource = nil; documentPages = nil;

	[self closeNative]; // CGPDFDocument

	if (pdfDocumentFP != nil) // FPDF_DOCUMENT
	{
		[UXReaderFramework dispatch_sync_on_work_queue:
		^{
			FPDF_CloseDocument(self->pdfDocumentFP); self->pdfDocumentFP = nil;
		}];
	}

	//NSLog(@"%s", __FUNCTION__);
}

- (void)close
{
	//NSLog(@"%s", __FUNCTION__);
}

- (nullable NSURL *)URL
{
	//NSLog(@"%s", __FUNCTION__);

	return documentURL;
}

- (nullable NSData *)data
{
	//NSLog(@"%s", __FUNCTION__);

	return documentData;
}

- (nullable NSUUID *)fileUUID:(nonnull NSURL *)url
{
	//NSLog(@"%s %@", __FUNCTION__, url);

	NSUUID *uuid = nil; NSData *data = nil; // File URL UUID

	if ([url getResourceValue:&data forKey:NSURLFileResourceIdentifierKey error:nil])
	{
		if ([data isKindOfClass:[NSData class]] && ([data length] == 16)) // Rely on this
		{
			uuid = [[NSUUID alloc] initWithUUIDBytes:(const uint8_t *)[data bytes]];
		}
		else // Log failure of this NSURLFileResourceIdentifierKey hack
		{
			NSLog(@"%s failed ([data length] != 16)", __FUNCTION__);
		}
	}

	if (uuid == nil) // Get UUID of NSData of file
	{
		NSData *data = [NSData dataWithContentsOfURL:documentURL options:NSDataReadingMappedAlways error:nil];

		if (data != nil) uuid = [self dataUUID:data];
	}

	return uuid;
}

- (nullable NSUUID *)dataUUID:(nonnull NSData *)data
{
	//NSLog(@"%s %p", __FUNCTION__, data);

	uint8_t digest[CC_MD5_DIGEST_LENGTH]; // Data UUID

	CC_MD5([data bytes], uint32_t([data length]), digest);

	return [[NSUUID alloc] initWithUUIDBytes:digest];
}

- (nullable NSUUID *)hostUUID:(nonnull NSURL *)url
{
	//NSLog(@"%s %@", __FUNCTION__, url);

	NSString *string = [url absoluteString]; // Host URL UUID

	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

	uint8_t digest[CC_MD5_DIGEST_LENGTH]; // UUID from NSData

	CC_MD5([data bytes], uint32_t([data length]), digest);

	return [[NSUUID alloc] initWithUUIDBytes:digest];
}

- (void)setUUID:(nonnull NSUUID *)uuid
{
	//NSLog(@"%s %@", __FUNCTION__, uuid);

	if (UUID == nil) UUID = [uuid copy];
}

- (nonnull NSUUID *)UUID
{
	//NSLog(@"%s", __FUNCTION__);

	if (UUID == nil) // Create it
	{
		if ([documentURL isFileURL])
		{
			UUID = [self fileUUID:documentURL];
		}
		else if ([documentData length])
		{
			UUID = [self dataUUID:documentData];
		}
		else if ([documentURL host])
		{
			UUID = [self hostUUID:documentURL];
		}

		if (UUID == nil) // Default
		{
			UUID = [[NSUUID alloc] init];
		}
	}

	return UUID;
}

- (void)setTitle:(nonnull NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	title = [text copy];
}

- (nullable NSString *)title
{
	//NSLog(@"%s", __FUNCTION__);

	if (title == nil) // Create title
	{
		if (documentURL != nil) // NSURL file name
		{
			NSString *filename = [documentURL lastPathComponent];

			title = [filename stringByDeletingPathExtension];
		}
		else if (documentData != nil) // NSData object address
		{
			title = [NSString stringWithFormat:@"%p", documentData];
		}
		else if (dataSource != nil) // UXReaderDocumentDataSource
		{
			title = [NSString stringWithFormat:@"%p", dataSource];
		}
	}

	return title;
}

- (void)setShowRTL:(BOOL)RTL
{
	//NSLog(@"%s %i", __FUNCTION__, RTL);

	if (showRTL == nil) showRTL = @(RTL);
}

- (BOOL)showRTL
{
	//NSLog(@"%s", __FUNCTION__);

	return [showRTL boolValue];
}

- (void)setHighlightLinks:(BOOL)highlight
{
	//NSLog(@"%s %i", __FUNCTION__, highlight);

	highlightLinks = highlight;
}

- (BOOL)highlightLinks
{
	//NSLog(@"%s", __FUNCTION__);

	return highlightLinks;
}

- (void)setRenderTile:(nullable id <UXReaderRenderTileInContext>)renderer
{
	//NSLog(@"%s %@", __FUNCTION__, renderer);

	renderTile = renderer;
}

- (nullable id <UXReaderRenderTileInContext>)renderTile
{
	//NSLog(@"%s", __FUNCTION__);

	return renderTile;
}

- (void)setUseNativeRendering
{
	//NSLog(@"%s", __FUNCTION__);

	nativeRendering = YES;
}

- (BOOL)hasEqualURL:(nullable NSURL *)URL
{
	//NSLog(@"%s %@", __FUNCTION__, URL);

	if (documentURL == nil) return NO; // Not equal

	BOOL result = [documentURL isEqual:URL]; // NSURL ==

	if ((result == NO) && [documentURL isFileURL] && [URL isFileURL])
	{
		id value1 = nil; id value2 = nil; // NSURLFileResourceIdentifierKey values

		BOOL v1 = [documentURL getResourceValue:&value1 forKey:NSURLFileResourceIdentifierKey error:nil];

		BOOL v2 = [URL getResourceValue:&value2 forKey:NSURLFileResourceIdentifierKey error:nil];

		if (v1 && v2) result = [value1 isEqual:value2];
	}

	return result;
}

- (BOOL)isSameDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	BOOL result = [self isEqual:documentx]; // NSObject ==

	if (result == NO) result = [self hasEqualURL:[documentx URL]];

	return result;
}

- (void)openWithPassword:(nullable NSString *)password completion:(nonnull void (^)(NSError *_Nullable error))handler
{
	//NSLog(@"%s %@", __FUNCTION__, password);

	assert(pdfDocumentFP == nil); assert(handler != nil);

	void (^block)(NSError *) = [handler copy];

	[UXReaderFramework dispatch_async_on_work_queue:
	^{
		NSError *error = nil; // Open NSError

		const char *phrase = [password UTF8String];

		if ([self->documentURL isFileURL]) // File NSURL
		{
			NSString *path = [self->documentURL path];

			const char *filepath = [path UTF8String];

			self->pdfDocumentFP = FPDF_LoadDocument(filepath, phrase);
		}
		else if ([self->documentData length]) // NSData
		{
			const void *data = [self->documentData bytes];

			const int size = int([self->documentData length]);

			self->pdfDocumentFP = FPDF_LoadMemDocument(data, size, phrase);
		}
		else if (self->dataSource != nil) // UXReaderDocumentDataSource
		{
			__autoreleasing NSUUID *uuid = nil; // Data source UUID

			[self->dataSource document:self UUID:&uuid]; self->UUID = [uuid copy];

			FPDF_FILEACCESS data; memset(&data, 0x00, sizeof(data));

			size_t length = 0; [self->dataSource document:self dataLength:&length];

			data.m_FileLen = length; data.m_GetBlock = &GetDataBlock;

			data.m_Param = (__bridge void *)self; // UXReaderDocument

			self->pdfDocumentFP = FPDF_LoadCustomDocument(&data, phrase);
		}
		else if ([self->documentURL host]) // HTTP NSURL
		{
			self->dataSource = self; // UXReaderDocumentDataSource

			__autoreleasing NSUUID *uuid = nil; // Data source UUID

			[self->dataSource document:self UUID:&uuid]; self->UUID = [uuid copy];
			
			FPDF_FILEACCESS data; memset(&data, 0x00, sizeof(data));

			size_t length = 0; [self->dataSource document:self dataLength:&length];

			data.m_FileLen = length; data.m_GetBlock = &GetDataBlock;

			data.m_Param = (__bridge void *)self; // UXReaderDocument

			self->pdfDocumentFP = FPDF_LoadCustomDocument(&data, phrase);
		}

		if (self->pdfDocumentFP == nil) // Return NSError
		{
			const NSUInteger errorCode = FPDF_GetLastError();

			NSString *name = NSStringFromClass([self class]);

			NSBundle *bundle = [NSBundle bundleForClass:[self class]];

			NSString *key = [NSString stringWithFormat:@"DocumentError%i", int(errorCode)];

			NSString *text = [bundle localizedStringForKey:key value:nil table:nil];

			NSDictionary<NSString *, id> *userInfo = @{NSLocalizedDescriptionKey : text};

			error = [NSError errorWithDomain:name code:errorCode userInfo:userInfo];
		}
		else // Extract document metadata
		{
			[self metadata]; [self openNativeWithPassword:password];

			[UXReaderThumbCache touchDirectoryForUUID:[self UUID]];
		}

		dispatch_async(dispatch_get_main_queue(), ^{ block(error); });
	}];
}

- (void)openNativeWithPassword:(nullable NSString *)password
{
	//NSLog(@"%s %@", __FUNCTION__, password);

	if (nativeRendering) // Use Core Graphics
	{
		if ([documentURL isFileURL]) // File NSURL
		{
			CFURLRef CFURL = (__bridge CFURLRef)documentURL;

			pdfDocumentCG = CGPDFDocumentCreateWithURL(CFURL);
		}
		else if ([documentData length]) // NSData source
		{
			CFDataRef CFData = (__bridge CFDataRef)documentData;

			dataProviderCG = CGDataProviderCreateWithCFData(CFData);

			if (dataProviderCG != nil) // Valid CGDataProvider
			{
				pdfDocumentCG = CGPDFDocumentCreateWithProvider(dataProviderCG);
			}
		}

		if (pdfDocumentCG != nil) // Unlock
		{
			const char *phrase = [password UTF8String];

			const char *text = ((phrase != nil) ? phrase : "");

			if (CGPDFDocumentUnlockWithPassword(pdfDocumentCG, text) == false)
			{
				[self closeNative]; NSLog(@"%s failed", __FUNCTION__);
			}
		}
	}
}

- (void)closeNative
{
	//NSLog(@"%s", __FUNCTION__);

	if (pdfDocumentCG != nil) // CGPDFDocument
	{
		CGPDFDocumentRelease(pdfDocumentCG); pdfDocumentCG = nil;
	}

	if (dataProviderCG != nil) // CGDataProvider
	{
		CGDataProviderRelease(dataProviderCG); dataProviderCG = nil;
	}
}

- (void)metadata
{
	//NSLog(@"%s", __FUNCTION__);

	if (pdfDocumentFP != nil) // Get document metadata
	{
		pageCount = FPDF_GetPageCount(pdfDocumentFP); int version = 0;

		pageSizes = [NSMutableDictionary dictionaryWithCapacity:pageCount];

		pageLabels = [NSMutableDictionary dictionaryWithCapacity:pageCount];

		security = int32_t(FPDF_GetSecurityHandlerRevision(pdfDocumentFP));

		permissions = uint32_t(FPDF_GetDocPermissions(pdfDocumentFP));

		if (FPDF_GetFileVersion(pdfDocumentFP, &version)) // PDF version
		{
			const int major = (version / 10); const int minor = (version % 10);

			fileVersion = [NSString stringWithFormat:@"%i.%i", major, minor];
		}
	}
}

- (BOOL)isOpen
{
	//NSLog(@"%s", __FUNCTION__);

	return (pdfDocumentFP != nil);
}

- (nullable void *)pdfDocumentCG
{
	//NSLog(@"%s", __FUNCTION__);

	return pdfDocumentCG;
}

- (nullable void *)pdfDocumentFP
{
	//NSLog(@"%s", __FUNCTION__);

	return pdfDocumentFP;
}

- (NSUInteger)pageCount
{
	//NSLog(@"%s", __FUNCTION__);

	return pageCount;
}

- (uint32_t)permissions
{
	//NSLog(@"%s", __FUNCTION__);

	return permissions;
}

- (nullable NSString *)fileVersion
{
	//NSLog(@"%s", __FUNCTION__);

	return fileVersion;
}

- (CGSize)pageSize:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	if ([self isOpen] == NO) return CGSizeZero;

	__block CGSize pageSize = CGSizeZero; // Size

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (NSValue *value = self->pageSizes[@(page)])
		{
			pageSize = [value CGSizeValue]; // Cached
		}
		else // Get size for page from document and cache it
		{
			double width = 0.0; double height = 0.0; // Page size in points

			if (FPDF_GetPageSizeByIndex(self->pdfDocumentFP, int(page), &width, &height) != FALSE)
			{
				pageSize = CGSizeMake(floor(width), floor(height)); // No fractional sizes

				self->pageSizes[@(page)] = [NSValue valueWithCGSize:pageSize]; // Cache
			}
		}
	}];

	return pageSize;
}

- (nullable UXReaderDocumentPage *)documentPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	if ([self isOpen] == NO) return nil;

	__block UXReaderDocumentPage *documentPage = nil;

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		documentPage = [self->documentPages objectForKey:@(page)]; // Use existing

		if (documentPage == nil) // Create new UXReaderDocumentPage for requested page
		{
			if ((documentPage = [[UXReaderDocumentPage alloc] initWithDocument:self page:page]))
			{
				[self->documentPages setObject:documentPage forKey:@(page)];
			}
		}
	}];

	return documentPage;
}

- (nullable NSString *)pageLabel:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	if ([self isOpen] == NO) return nil;

	__block NSString *label = nil;

	if (pageLabels != nil) // Get page label
	{
		[UXReaderFramework dispatch_sync_on_work_queue:
		^{
			label = self->pageLabels[@(page)]; // Get cached label

			if (label == nil) // Extract label for page - if one exists
			{
				if (int bytes = int(FPDF_GetPageLabel(self->pdfDocumentFP, int(page), nil, 0)))
				{
					if (NSMutableData *data = [NSMutableData dataWithLength:bytes]) // Buffer
					{
						FPDF_GetPageLabel(self->pdfDocumentFP, int(page), [data mutableBytes], bytes);

						const NSUInteger length = ((bytes / sizeof(unichar)) - 1); // No NUL

						const unichar *unicode = reinterpret_cast<const unichar *>([data bytes]);

						if ((label = [[NSString alloc] initWithCharacters:unicode length:length]))
						{
							self->pageLabels[@(page)] = label;
						}
					}
				}
				else // No page labels
				{
					self->pageLabels = nil;
				}
			}
		}];
	}

	return label;
}

- (nullable NSString *)textForItem:(nonnull NSString *)key
{
	//NSLog(@"%s %@", __FUNCTION__, key);

	NSString *text = nil; const char *tag = [key UTF8String];

	if (int bytes = int(FPDF_GetMetaText(pdfDocumentFP, tag, nil, 0)))
	{
		if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
		{
			FPDF_GetMetaText(pdfDocumentFP, tag, [data mutableBytes], bytes);

			const NSUInteger length = ((bytes / sizeof(unichar)) - 1); // No NUL

			const unichar *unicode = reinterpret_cast<const unichar *>([data bytes]);

			text = [[NSString alloc] initWithCharacters:unicode length:length];
		}
	}

	return text;
}

- (nullable NSDictionary<NSString *, NSString *> *)information
{
	//NSLog(@"%s", __FUNCTION__);

	if ([self isOpen] == NO) return nil;

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (self->information == nil) // Create documentation information dictionary
		{
			NSMutableDictionary<NSString *, NSString *> *entries = [[NSMutableDictionary alloc] init];

			static NSArray<NSString *> *keys = @[@"Title", @"Author", @"Subject", @"Keywords", @"Creator", @"Producer", @"CreationDate", @"ModDate"];

			[keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger index, BOOL *stop)
			{
				if (NSString *text = [self textForItem:key]) // Text for information
				{
					if ([text length] > 0) [entries setObject:text forKey:key];
				}
			}];

			self->information = [entries copy];
		}
	}];

	return information;
}

#pragma mark - UXReaderDocument search methods

- (BOOL)isSearching
{
	//NSLog(@"%s", __FUNCTION__);

	return (searchCanceller != nil);
}

- (void)cancelSearch
{
	//NSLog(@"%s", __FUNCTION__);

	if (UXReaderCanceller *canceller = searchCanceller)
	{
		[canceller cancel]; [[canceller lock] lock]; [[canceller lock] unlock];
	}
}

- (void)beginSearch:(nonnull NSString *)text options:(UXReaderSearchOptions)options
{
	//NSLog(@"%s '%@' %i", __FUNCTION__, text, int(options));

	if ([self isOpen] == NO) return;

	if ((searchCanceller == nil) && [text length])
	{
		searchCanceller = [[UXReaderCanceller alloc] initWithLock];

		NSString *string = [text copy]; // Make copy of the search text

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		^{
			[[self->searchCanceller lock] lock]; NSUInteger total = 0;

			dispatch_async(dispatch_get_main_queue(),
			^{
				if ([self->search respondsToSelector:@selector(document:didBeginDocumentSearch:)])
				{
					[self->search document:self didBeginDocumentSearch:options];
				}
			});

			const NSRange range = NSMakeRange(0, [string length]);

			const NSUInteger bytes = ((range.length + 1) * sizeof(unichar));

			if (NSMutableData *unicode = [[NSMutableData alloc] initWithLength:bytes])
			{
				[string getCharacters:reinterpret_cast<unichar *>([unicode mutableBytes]) range:range];

				for (NSUInteger page = 0; page < self->pageCount; page++)
				{
					if ([self->searchCanceller isCancelled]) break;

					dispatch_async(dispatch_get_main_queue(),
					^{
						if ([self->search respondsToSelector:@selector(document:didBeginPageSearch:pages:)])
						{
							[self->search document:self didBeginPageSearch:page pages:self->pageCount];
						}
					});

					@autoreleasepool // Wrap in an autorelease pool
					{
						total += [self searchPage:page unicode:unicode options:options];
					}

					dispatch_async(dispatch_get_main_queue(),
					^{
						if ([self->search respondsToSelector:@selector(document:didFinishPageSearch:total:)])
						{
							[self->search document:self didFinishPageSearch:page total:total];
						}
					});
				}
			}

			dispatch_async(dispatch_get_main_queue(),
			^{
				if ([self->search respondsToSelector:@selector(document:didFinishDocumentSearch:)])
				{
					[self->search document:self didFinishDocumentSearch:total];
				}
			});

			[[self->searchCanceller lock] unlock];

			self->searchCanceller = nil;
		});
	}
}

- (NSUInteger)searchPage:(NSUInteger)page unicode:(nonnull NSData *)unicode options:(UXReaderSearchOptions)options
{
	//NSLog(@"%s %i %p %i", __FUNCTION__, int(page), unicode, int(options));

	__block NSUInteger found = 0; // On page

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (UXReaderDocumentPage *documentPage = [self documentPage:page])
		{
			const FPDF_TEXTPAGE textPage = [documentPage textPage]; // Handle

			const unichar *term = reinterpret_cast<const unichar *>([unicode bytes]);

			if (const FPDF_SCHHANDLE handle = FPDFText_FindStart(textPage, term, options, 0))
			{
				NSMutableArray<UXReaderSelection *> *selections = [[NSMutableArray alloc] init];

				while (FPDFText_FindNext(handle)) // Loop over any search hits
				{
					const int index = FPDFText_GetSchResultIndex(handle);

					const int count = FPDFText_GetSchCount(handle);

					//const NSUInteger bytes = ((count + 1) * sizeof(unichar));

					//if (NSMutableData *data = [[NSMutableData alloc] initWithLength:bytes])

					//const int cc = FPDFText_GetText(textPage, index, count, reinterpret_cast<unichar *>([data mutableBytes]));

					//NSString *text = [[NSString alloc] initWithCharacters:reinterpret_cast<const unichar *>([data bytes]) length:(cc - 1)];

					const int rc = FPDFText_CountRects(textPage, index, count); found++;

					NSMutableArray<NSValue *> *rects = [[NSMutableArray alloc] initWithCapacity:rc];

					for (int ri = 0; ri < rc; ri++) // Get all rectangles for the search hit
					{
						double x1 = 0.0; double y1 = 0.0; double x2 = 0.0; double y2 = 0.0;

						FPDFText_GetRect(textPage, ri, &x1, &y2, &x2, &y1); // Page co-ordinates

						const double d = 1.0; x1 -= d; y1 -= d; x2 += d; y2 += d; // Outset rectangle

						const CGRect rect = [documentPage convertFromPageX1:x1 Y1:y1 X2:x2 Y2:y2];

						[rects addObject:[NSValue valueWithCGRect:rect]];
					}

					if (UXReaderSelection *selection = [UXReaderSelection document:self page:page index:index count:count rectangles:rects])
					{
						[selections addObject:selection];
					}
				}

				if ([selections count] > 0) // Have hits
				{
					dispatch_async(dispatch_get_main_queue(),
					^{
						if ([self->search respondsToSelector:@selector(document:searchDidMatch:page:)])
						{
							[self->search document:self searchDidMatch:selections page:page];
						}
					});
				}

				FPDFText_FindClose(handle);
			}
		}
	}];

	return found;
}

- (void)setSearchSelections:(nullable NSDictionary<NSNumber *, NSArray<UXReaderSelection *> *> *)selections
{
	//NSLog(@"%s %@", __FUNCTION__, selections);

	if ([self isOpen] == NO) return;

	if (selections != searchSelections) // Update
	{
		searchSelections = [selections copy]; // Keep copy

		for (NSNumber *number in documentPages) // For cached pages
		{
			if (searchSelections != nil) // Update with new search selections
			{
				NSArray<UXReaderSelection *> *pageSelections = searchSelections[number];

				if (UXReaderDocumentPage *documentPage = [documentPages objectForKey:number])
				{
					[documentPage setSearchSelections:pageSelections];
				}
			}
			else // Clear any search selections
			{
				if (UXReaderDocumentPage *documentPage = [documentPages objectForKey:number])
				{
					[documentPage setSearchSelections:nil];
				}
			}
		}
	}
}

- (nullable NSDictionary<NSNumber *, NSArray<UXReaderSelection *> *> *)searchSelections
{
	//NSLog(@"%s", __FUNCTION__);

	return searchSelections;
}

#pragma mark - UXReaderDocument thumb methods

- (void)thumbForPage:(NSUInteger)page size:(CGSize)size canceller:(nonnull UXReaderCanceller *)canceller completion:(nonnull void (^)(UIImage *_Nonnull thumb))handler
{
	//NSLog(@"%s %i %@ %@ %p", __FUNCTION__, int(page), NSStringFromCGSize(size), canceller, handler);

	if ([self isOpen] == NO) return;

	if ((canceller != nil) && (handler != nil) && (page < pageCount))
	{
		void (^block)(UIImage *thumb) = [handler copy]; size = UXSizeFloor(size);

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		^{
			if ([canceller isCancelled] == YES) return; // Is cancelled

			if (UIImage *thumb = [UXReaderThumbCache loadThumbForUUID:self->UUID page:page size:size])
			{
				if ([canceller isCancelled] == NO) // Not cancelled
				{
					dispatch_async(dispatch_get_main_queue(),
					^{
						if ([canceller isCancelled] == NO) block(thumb);
					});
				}
			}
			else // Create and cache thumb
			{
				if (UXReaderDocumentPage *documentPage = [self documentPage:page])
				{
					[documentPage thumbWithSize:size canceller:canceller completion:^(UIImage *thumb)
					{
						block(thumb); [UXReaderThumbCache saveThumb:thumb UUID:self->UUID page:page size:size];
					}];
				}
			}
		});
	}
}

#pragma mark - UXReaderDocument outline methods

- (nullable UXReaderAction *)actionForDest:(FPDF_DEST)dest
{
	//NSLog(@"%s %p", __FUNCTION__, dest);

	UXReaderAction *item = nil; // Action item

	if (dest != nil) // Valid FPDF_DEST - carry on
	{
		NSUInteger index = NSUIntegerMax; UXReaderDestinationTarget target {};

		index = NSUInteger(FPDFDest_GetPageIndex(pdfDocumentFP, dest));

		FS_FLOAT pageX = 0.0f; FS_FLOAT pageY = 0.0f; FS_FLOAT zoom = 0.0f;

		FPDF_BOOL bX = FALSE; FPDF_BOOL bY = FALSE; FPDF_BOOL bZoom = FALSE;

		if (FPDFDest_GetLocationInPage(dest, &bX, &bY, &bZoom, &pageX, &pageY, &zoom))
		{
			target = {BOOL(bX), BOOL(bY), BOOL(bZoom), pageX, pageY, zoom};
		}

		if (UXReaderDestination *destination = [[UXReaderDestination alloc] initWithPage:index target:target])
		{
			item = [[UXReaderAction alloc] initWithGoto:destination rectangle:CGRectZero];
		}
	}

	return item;
}

- (nullable UXReaderAction *)actionForOutline:(FPDF_BOOKMARK)entry
{
	//NSLog(@"%s %p", __FUNCTION__, entry);

	UXReaderAction *item = nil; // Action item

	if (entry != nil) // Valid FPDF_BOOKMARK - carry on
	{
		if (FPDF_ACTION action = FPDFBookmark_GetAction(entry))
		{
			if (FPDFAction_GetType(action) == PDFACTION_GOTO) // Goto
			{
				if (FPDF_DEST dest = FPDFBookmark_GetDest(pdfDocumentFP, entry))
				{
					item = [self actionForDest:dest];
				}
			}
		}
		else if (FPDF_DEST dest = FPDFBookmark_GetDest(pdfDocumentFP, entry))
		{
			item = [self actionForDest:dest];
		}
	}

	return item;
}

- (void)addOutline:(FPDF_BOOKMARK)entry toList:(nonnull NSMutableArray<UXReaderOutline *> *)list atLevel:(NSUInteger)level
{
	//NSLog(@"%s %p %p %i", __FUNCTION__, entry, list, int(level));

	while (entry) // Loop through outline entries
	{
		if (int bytes = int(FPDFBookmark_GetTitle(entry, nil, 0)))
		{
			if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
			{
				FPDFBookmark_GetTitle(entry, [data mutableBytes], bytes);

				const NSUInteger length = ((bytes / sizeof(unichar)) - 1); // No NUL

				const unichar *unicode = reinterpret_cast<const unichar *>([data bytes]);

				NSString *name = [[NSString alloc] initWithCharacters:unicode length:length];

				if (UXReaderAction *item = [self actionForOutline:entry]) // Get UXReaderAction item
				{
					if (UXReaderOutline *derp = [[UXReaderOutline alloc] initWithName:name action:item level:level])
					{
						[list addObject:derp];
					}
				}
			}
		}

		if (FPDF_BOOKMARK child = FPDFBookmark_GetFirstChild(pdfDocumentFP, entry))
		{
			[self addOutline:child toList:list atLevel:(level + 1)];
		}

		entry = FPDFBookmark_GetNextSibling(pdfDocumentFP, entry);
	}
}

- (nullable NSArray<UXReaderOutline *> *)outline
{
	//NSLog(@"%s", __FUNCTION__);

	if ([self isOpen] == NO) return nil;

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (self->outline == nil) // Extract outline from document
		{
			NSMutableArray<UXReaderOutline *> *list = [[NSMutableArray alloc] init];

			const FPDF_BOOKMARK first = FPDFBookmark_GetFirstChild(self->pdfDocumentFP, nil);

			[self addOutline:first toList:list atLevel:0]; self->outline = [list copy];
		}
	}];

	return outline;
}

#pragma mark - UXReaderDocumentDataSource methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (BOOL)document:(UXReaderDocument *)document dataLength:(size_t *)length
{
	//NSLog(@"%s %@ %p", __FUNCTION__, document, length);

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:documentURL];

	[request setHTTPMethod:@"HEAD"]; request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	__autoreleasing NSHTTPURLResponse *response = nil; __autoreleasing NSError *error = nil; BOOL status = NO;

	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

	if ((response.statusCode == 200) && (error == nil) && ([data length] == 0))
	{
		NSDictionary<NSString *, NSString *> *headers = [response allHeaderFields];

		NSString *acceptRanges = headers[@"Accept-Ranges"]; NSString *contentLength = headers[@"Content-Length"];

		if ([acceptRanges isEqualToString:@"bytes"] && (contentLength != nil))
		{
			*length = [contentLength integerValue]; status = YES;
		}
	}

	return status;
}

- (BOOL)document:(UXReaderDocument *)document offset:(size_t)offset length:(size_t)length buffer:(uint8_t *)buffer
{
	//NSLog(@"%s %@ %lu %lu %p", __FUNCTION__, document, offset, length, buffer);

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:documentURL]; [request setHTTPMethod:@"GET"];

	const size_t last = (offset + length - 1); NSString *range = [NSString stringWithFormat:@"bytes=%lu-%lu", offset, last];

	[request setValue:range forHTTPHeaderField:@"Range"]; request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	__autoreleasing NSHTTPURLResponse *response = nil; __autoreleasing NSError *error = nil; BOOL status = NO;

	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

	if ((response.statusCode == 206) && (error == nil) && ([data length] == length))
	{
		memcpy(buffer, [data bytes], length); status = YES;
	}

	return status;
}

- (BOOL)document:(nonnull UXReaderDocument *)document UUID:(NSUUID * _Nullable * _Nullable)uuid;
{
	//NSLog(@"%s %@ %p", __FUNCTION__, document, uuid);

	if (uuid != nil) *uuid = [self hostUUID:documentURL];

	return (uuid != nil);
}

#pragma clang diagnostic pop

@end

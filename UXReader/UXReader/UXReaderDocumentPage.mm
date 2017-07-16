//
//	UXReaderDocumentPage.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderDocumentPage.h"
#import "UXReaderSelection.h"
#import "UXReaderCanceller.h"
#import "UXReaderFramework.h"
#import "UXReaderDestination.h"
#import "UXReaderAction.h"

#import "fpdfview.h"
#import "fpdf_text.h"
#import "fpdf_edit.h"
#import "fpdf_doc.h"

@implementation UXReaderDocumentPage
{
	UXReaderDocument *document;

	FPDF_DOCUMENT pdfDocumentFP; // Assign

	FPDF_PAGE pdfPageFP; FPDF_TEXTPAGE textPageFP;

	CGPDFDocumentRef pdfDocumentCG; CGPDFPageRef pdfPageCG;

	NSArray<UXReaderSelection *> *searchSelections;

	NSArray<UXReaderAction *> *pageLinks;

	NSArray<UXReaderAction *> *pageURLs;

	NSUInteger page; CGSize pageSize;

	NSUInteger rotation;
}

#pragma mark - UXReaderDocumentPage instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		page = NSUIntegerMax;
	}

	return self;
}

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx page:(NSUInteger)pagex
{
	//NSLog(@"%s %@ %i", __FUNCTION__, documentx, int(pagex));

	if ((self = [self init])) // Initialize self
	{
		if ((documentx != nil) && (pagex < [documentx pageCount])) // Carry on
		{
			page = pagex; document = documentx; pdfDocumentFP = [document pdfDocumentFP];

			pdfDocumentCG = CGPDFDocumentRef([document pdfDocumentCG]); // CGPDFDocument

			if ([self loadPage] == YES) [self metadata]; else self = nil;
		}
		else // On error
		{
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	pdfPageCG = nil; pdfDocumentCG = nil;

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (textPageFP != nil) { FPDFText_ClosePage(textPageFP); textPageFP = nil; };

		if (pdfPageFP != nil) { FPDF_ClosePage(pdfPageFP); pdfPageFP = nil; }
	}];
}

- (BOOL)loadPage
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if ((pdfPageFP = FPDF_LoadPage(pdfDocumentFP, int(page))))
		{
			rotation = FPDFPage_GetRotation(pdfPageFP); // Rotation

			if (pdfDocumentCG != nil) // Native rendering mode enabled
			{
				pdfPageCG = CGPDFDocumentGetPage(pdfDocumentCG, (page+1));
			}
		}
	}];

	return (pdfPageFP != nil);
}

- (void)metadata
{
	//NSLog(@"%s", __FUNCTION__);

	searchSelections = [document searchSelections][@(page)];

	pageSize = [document pageSize:page];
}

- (nonnull UXReaderDocument *)document
{
	//NSLog(@"%s", __FUNCTION__);

	return document;
}

- (nullable void *)pdfPageCG
{
	//NSLog(@"%s", __FUNCTION__);

	return pdfPageCG;
}

- (nullable void *)pdfPageFP
{
	//NSLog(@"%s", __FUNCTION__);

	return pdfPageFP;
}

- (nullable void *)textPage
{
	//NSLog(@"%s", __FUNCTION__);

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (textPageFP == nil) // Load text on demand
		{
			textPageFP = FPDFText_LoadPage(pdfPageFP);
		}
	}];

	return textPageFP;
}

- (NSUInteger)page
{
	//NSLog(@"%s", __FUNCTION__);

	return page;
}

- (NSUInteger)rotation
{
	//NSLog(@"%s", __FUNCTION__);

	return rotation;
}

- (CGSize)pageSize
{
	//NSLog(@"%s", __FUNCTION__);

	return pageSize;
}

- (void)setSearchSelections:(nullable NSArray<UXReaderSelection *> *)selections
{
	//NSLog(@"%s %@", __FUNCTION__, selections);

	searchSelections = selections;
}

- (nullable NSArray<UXReaderSelection *> *)searchSelections
{
	//NSLog(@"%s", __FUNCTION__);

	return searchSelections;
}

#pragma mark - UXReaderDocumentPage convert methods

- (CGRect)convertToPageFromViewRect:(CGRect)rect
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(rect));

	const CGFloat pw = pageSize.width; const CGFloat ph = pageSize.height;

	switch (rotation) // Page rotation
	{
		case 0: // 0 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(0.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, ph);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {1.0, 0.0, 0.0, -1.0, 0.0, ph};
			rect = CGRectApplyAffineTransform(rect, m);
			break;
		}

		case 1: // 90 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(90.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, 0.0);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {0.0, 1.0, 1.0, 0.0, 0.0, 0.0};
			rect = CGRectApplyAffineTransform(rect, m);
			break;
		}

		case 2: // 180 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(180.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(pw, 0.0);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {-1.0, 0.0, 0.0, 1.0, pw, 0.0};
			rect = CGRectApplyAffineTransform(rect, m);
			break;
		}

		case 3: // 270 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(270.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(ph, pw);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {0.0, -1.0, -1.0, 0.0, ph, pw};
			rect = CGRectApplyAffineTransform(rect, m);
			break;
		}
	}

	return rect;
}

- (CGPoint)convertToPageFromViewPoint:(CGPoint)point
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));

	const CGFloat pw = pageSize.width; const CGFloat ph = pageSize.height;

	switch (rotation) // Page rotation
	{
		case 0: // 0 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(0.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, ph);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {1.0, 0.0, 0.0, -1.0, 0.0, ph};
			point = CGPointApplyAffineTransform(point, m);
			break;
		}

		case 1: // 90 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(90.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, 0.0);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {0.0, 1.0, 1.0, 0.0, 0.0, 0.0};
			point = CGPointApplyAffineTransform(point, m);
			break;
		}

		case 2: // 180 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(180.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(pw, 0.0);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {-1.0, 0.0, 0.0, 1.0, pw, 0.0};
			point = CGPointApplyAffineTransform(point, m);
			break;
		}

		case 3: // 270 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(270.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(ph, pw);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {0.0, -1.0, -1.0, 0.0, ph, pw};
			point = CGPointApplyAffineTransform(point, m);
			break;
		}
	}

	return point;
}

- (CGRect)convertFromPageX1:(CGFloat)xp1 Y1:(CGFloat)yp1 X2:(CGFloat)xp2 Y2:(CGFloat)yp2
{
	//NSLog(@"%s x1: %g y1: %g x2: %g y2: %g", __FUNCTION__, xp1, yp1, xp2, yp2);

	CGFloat xr1 = xp1; CGFloat yr1 = yp1; CGFloat xr2 = xp2; CGFloat yr2 = yp2;

	const CGFloat pw = pageSize.width; const CGFloat ph = pageSize.height;

	switch (rotation) // Page rotation
	{
		case 0: // 0 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(-0.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, ph);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {1.0, 0.0, 0.0, -1.0, 0.0, ph};
			CGPoint pt1 = CGPointMake(xp1, yp1); pt1 = CGPointApplyAffineTransform(pt1, m);
			CGPoint pt2 = CGPointMake(xp2, yp2); pt2 = CGPointApplyAffineTransform(pt2, m);
			xr1 = pt1.x; yr1 = pt2.y; xr2 = pt2.x; yr2 = pt1.y;
			break;
		}

		case 1: // 90 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(90.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, 0.0);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {0.0, 1.0, 1.0, 0.0, 0.0, 0.0};
			CGPoint pt1 = CGPointMake(xp1, yp1); pt1 = CGPointApplyAffineTransform(pt1, m);
			CGPoint pt2 = CGPointMake(xp2, yp2); pt2 = CGPointApplyAffineTransform(pt2, m);
			xr1 = pt1.x; yr1 = pt1.y; xr2 = pt2.x; yr2 = pt2.y;
			break;
		}

		case 2: // 180 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(180.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(pw, 0.0);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {-1.0, 0.0, 0.0, 1.0, pw, 0.0};
			CGPoint pt1 = CGPointMake(xp1, yp1); pt1 = CGPointApplyAffineTransform(pt1, m);
			CGPoint pt2 = CGPointMake(xp2, yp2); pt2 = CGPointApplyAffineTransform(pt2, m);
			xr1 = pt2.x; yr1 = pt1.y; xr2 = pt1.x; yr2 = pt2.y;
			break;
		}

		case 3: // 270 degrees
		{
			//CGAffineTransform s = CGAffineTransformMakeScale(1.0, -1.0);
			//CGAffineTransform r = CGAffineTransformMakeRotation(270.0 * M_PI / 180.0);
			//CGAffineTransform t = CGAffineTransformMakeTranslation(pw, ph);
			//CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t);
			const CGAffineTransform m = {0.0, -1.0, -1.0, 0.0, pw, ph};
			CGPoint pt1 = CGPointMake(xp1, yp1); pt1 = CGPointApplyAffineTransform(pt1, m);
			CGPoint pt2 = CGPointMake(xp2, yp2); pt2 = CGPointApplyAffineTransform(pt2, m);
			xr1 = pt2.x; yr1 = pt2.y; xr2 = pt1.x; yr2 = pt1.y;
			break;
		}
	}

	//NSLog(@"%s x1: %g y1: %g x2: %g y2: %g", __FUNCTION__, xr1, yr1, xr2, yr2);

	return CGRectMake(xr1, yr1, (xr2 - xr1), (yr2 - yr1));
}

#pragma mark - UXReaderDocumentPage render methods

- (void)renderTileInContext:(nonnull CGContextRef)context
{
	//NSLog(@"%s %p", __FUNCTION__, context);

	if (pdfPageCG == nil) // PDFium tile render
	{
		[UXReaderFramework dispatch_sync_on_work_queue:
		^{
			const CGRect rect = CGContextGetClipBoundingBox(context);

			const CGRect device = CGContextConvertRectToDeviceSpace(context, rect);

			const CGAffineTransform m = {1.0, 0.0, 0.0, -1.0, 0.0, pageSize.height};

			const CGRect flip = CGRectApplyAffineTransform(rect, m); // Flip Y

			const CGFloat ys = (device.size.height / rect.size.height);

			const CGFloat xs = (device.size.width / rect.size.width);

			const CGRect area = UXRectScale(flip, xs, ys); // Zoom + device scale

			const CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

			const CGBitmapInfo bmi = (kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast); // RBGx

			if (CGContextRef bmc = CGBitmapContextCreate(nil, area.size.width, area.size.height, 8, 0, rgb, bmi))
			{
				const size_t bw = CGBitmapContextGetWidth(bmc); const size_t bh = CGBitmapContextGetHeight(bmc);

				CGContextSetRGBFillColor(bmc, 1.0, 1.0, 1.0, 1.0); CGContextFillRect(bmc, CGRectMake(0.0, 0.0, bw, bh));

				const size_t bpr = CGBitmapContextGetBytesPerRow(bmc); void *data = CGBitmapContextGetData(bmc);

				if (FPDF_BITMAP pdfBitmap = FPDFBitmap_CreateEx(int(bw), int(bh), FPDFBitmap_BGRx, data, int(bpr)))
				{
					const int options = (FPDF_REVERSE_BYTE_ORDER | FPDF_NO_CATCH | FPDF_ANNOT); // Tile render options

					const FS_MATRIX matrix = {float(xs), 0.0, 0.0, float(ys), float(-area.origin.x), float(-area.origin.y)};

					const FS_RECTF clip = {0.0, 0.0, float(bw), float(bh)}; // Clip to bitmap dimensions

					FPDF_RenderPageBitmapWithMatrix(pdfBitmap, pdfPageFP, &matrix, &clip, options);

					if (CGImageRef image = CGBitmapContextCreateImage(bmc))
					{
						CGContextDrawImage(context, rect, image);

						CGImageRelease(image);
					}

					FPDFBitmap_Destroy(pdfBitmap);
				}

				CGContextRelease(bmc);
			}

			CGColorSpaceRelease(rgb);
		}];
	}
	else // Native tile render
	{
		CGContextSaveGState(context); CGRect rect = CGRectZero; rect.size = pageSize;

		CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0); // Solid white background

		CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill rectangle

		//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(CGContextGetClipBoundingBox(context)));

		CGContextTranslateCTM(context, 0.0, pageSize.height); CGContextScaleCTM(context, 1.0, -1.0);

		CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pdfPageCG, kCGPDFCropBox, rect, 0, true));

		CGContextDrawPDFPage(context, pdfPageCG); CGContextRestoreGState(context);
	}

	CGContextSaveGState(context);

	if (searchSelections != nil) // Draw selections
	{
		CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 0.32);

		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 0.48);

		const CGRect clip = CGContextGetClipBoundingBox(context);

		for (UXReaderSelection *selection in searchSelections)
		{
			for (NSValue *value in [selection rectangles])
			{
				const CGRect area = [value CGRectValue];

				if (CGRectIntersectsRect(area, clip) == YES)
				{
					CGContextFillRect(context, area); // Fill it

					if ([selection isHighlighted] == YES) // Frame it
					{
						const CGRect rect = CGRectInset(area, -1.0, -1.0);

						CGContextStrokeRectWithWidth(context, rect, 2.0);
					}
				}
			}
		}
	}

	if ([document highlightLinks] == YES)
	{
		CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 0.15);

		const CGRect clip = CGContextGetClipBoundingBox(context);

		if ([pageLinks count] > 0) // Annot links
		{
			for (UXReaderAction *action in pageLinks)
			{
				const CGRect area = [action rectangle];

				if (CGRectIntersectsRect(area, clip) == YES)
				{
					CGContextFillRect(context, area);
				}
			}
		}

		if ([pageURLs count] > 0) // Text URLs
		{
			for (UXReaderAction *action in pageURLs)
			{
				for (NSValue *value in [action rectangles])
				{
					const CGRect area = [value CGRectValue];

					if (CGRectIntersectsRect(area, clip) == YES)
					{
						CGContextFillRect(context, area);
					}
				}
			}
		}
	}

	CGContextRestoreGState(context);
}

- (void)thumbWithSize:(CGSize)size canceller:(nonnull UXReaderCanceller *)canceller completion:(nonnull void (^)(UIImage *_Nonnull thumb))handler
{
	//NSLog(@"%s %@ %@ %p", __FUNCTION__, NSStringFromCGSize(size), canceller, handler);

	if ((canceller == nil) || (handler == nil)) return;

	void (^block)(UIImage *thumb) = [handler copy];

	if (pdfPageCG == nil) // PDFium thumb render
	{
		[UXReaderFramework dispatch_async_on_work_queue:
		^{
			if ([canceller isCancelled] == YES) return; // Is cancelled

			const size_t tw = size.width; const CGFloat xs = (tw / pageSize.width);

			const size_t th = size.height; const CGFloat ys = (th / pageSize.height);

			const CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

			const CGBitmapInfo bmi = (kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast);

			if (CGContextRef bmc = CGBitmapContextCreate(nil, tw, th, 8, 0, rgb, bmi)) // Render thumb
			{
				const size_t bw = CGBitmapContextGetWidth(bmc); const size_t bh = CGBitmapContextGetHeight(bmc);

				CGContextSetRGBFillColor(bmc, 1.0, 1.0, 1.0, 1.0); CGContextFillRect(bmc, CGRectMake(0.0, 0.0, bw, bh));

				const size_t bpr = CGBitmapContextGetBytesPerRow(bmc); void *data = CGBitmapContextGetData(bmc);

				if (FPDF_BITMAP pdfBitmap = FPDFBitmap_CreateEx(int(bw), int(bh), FPDFBitmap_BGRx, data, int(bpr)))
				{
					const int options = (FPDF_REVERSE_BYTE_ORDER | FPDF_NO_CATCH | FPDF_ANNOT);

					FS_MATRIX matrix = {float(xs), 0.0, 0.0, float(-ys), 0.0, float(bh)};

					FS_RECTF clip = {0.0, 0.0, float(bw), float(bh)}; // Clip to bitmap

					FPDF_RenderPageBitmapWithMatrix(pdfBitmap, pdfPageFP, &matrix, &clip, options);

					if (CGImageRef image = CGBitmapContextCreateImage(bmc))
					{
						if (UIImage *thumb = [[UIImage alloc] initWithCGImage:image])
						{
							if ([canceller isCancelled] == NO)
							{
								dispatch_async(dispatch_get_main_queue(),
								^{
									if ([canceller isCancelled] == NO) block(thumb);
								});
							}
						}

						CGImageRelease(image);
					}

					FPDFBitmap_Destroy(pdfBitmap);
				}

				CGContextRelease(bmc);
			}

			CGColorSpaceRelease(rgb);
		}];
	}
	else // Native thumb render
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		^{
			if ([canceller isCancelled] == YES) return; // Is cancelled

			const size_t tw = size.width; const size_t th = size.height;

			const CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB(); // Device RGB

			const CGBitmapInfo bmi = (kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);

			if (CGContextRef bmc = CGBitmapContextCreate(nil, tw, th, 8, 0, rgb, bmi)) // Render thumb
			{
				const size_t bw = CGBitmapContextGetWidth(bmc); const size_t bh = CGBitmapContextGetHeight(bmc);

				const CGRect rect = CGRectMake(0.0, 0.0, bw, bh); // Thumb rectangle

				CGContextSetRGBFillColor(bmc, 1.0, 1.0, 1.0, 1.0); CGContextFillRect(bmc, rect);

				CGContextConcatCTM(bmc, CGPDFPageGetDrawingTransform(pdfPageCG, kCGPDFCropBox, rect, 0, true));

				CGContextDrawPDFPage(bmc, pdfPageCG);

				if (CGImageRef image = CGBitmapContextCreateImage(bmc))
				{
					if (UIImage *thumb = [[UIImage alloc] initWithCGImage:image])
					{
						if ([canceller isCancelled] == NO)
						{
							dispatch_async(dispatch_get_main_queue(),
							^{
								if ([canceller isCancelled] == NO) block(thumb);
							});
						}
					}

					CGImageRelease(image);
				}

				CGContextRelease(bmc);
			}

			CGColorSpaceRelease(rgb);
		});
	}
}

#pragma mark - UXReaderDocumentPage link methods

- (nullable UXReaderAction *)actionForLink:(FPDF_LINK)link
{
	//NSLog(@"%s %p", __FUNCTION__, link);

	UXReaderAction *item = nil; // Action item

	if (FPDF_ACTION action = FPDFLink_GetAction(link))
	{
		switch (FPDFAction_GetType(action))
		{
			case PDFACTION_URI: // URI
			{
				if (int bytes = int(FPDFAction_GetURIPath(pdfDocumentFP, action, nil, 0)))
				{
					if (NSMutableData *data = [NSMutableData dataWithLength:bytes]) // Buffer
					{
						FPDFAction_GetURIPath(pdfDocumentFP, action, [data mutableBytes], bytes);

						if ([data length] > 0) [data setLength:([data length] - 1)]; // No NUL

						NSString *URI = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

						CGRect rect = CGRectZero; FS_RECTF rectf = {0.0f, 0.0f, 0.0f, 0.0f};

						if (FPDFLink_GetAnnotRect(link, &rectf)) // Convert from page coordinates
						{
							rect = [self convertFromPageX1:rectf.left Y1:rectf.bottom X2:rectf.right Y2:rectf.top];
						}

						item = [[UXReaderAction alloc] initWithURI:URI rectangle:rect];
					}
				}
				break;
			}

			case PDFACTION_GOTO: // Goto
			{
				NSUInteger index = NSUIntegerMax; UXReaderDestinationTarget target {};

				if (FPDF_DEST dest = FPDFLink_GetDest(pdfDocumentFP, link)) // Destination
				{
					index = NSUInteger(FPDFDest_GetPageIndex(pdfDocumentFP, dest));

					FS_FLOAT pageX = 0.0f; FS_FLOAT pageY = 0.0f; FS_FLOAT zoom = 0.0f;

					FPDF_BOOL bX = FALSE; FPDF_BOOL bY = FALSE; FPDF_BOOL bZoom = FALSE;

					if (FPDFDest_GetLocationInPage(dest, &bX, &bY, &bZoom, &pageX, &pageY, &zoom))
					{
						target = {BOOL(bX), BOOL(bY), BOOL(bZoom), pageX, pageY, zoom};
					}
				}

				CGRect rect = CGRectZero; FS_RECTF rectf = {0.0f, 0.0f, 0.0f, 0.0f};

				if (FPDFLink_GetAnnotRect(link, &rectf)) // Convert from page coordinates
				{
					rect = [self convertFromPageX1:rectf.left Y1:rectf.bottom X2:rectf.right Y2:rectf.top];
				}

				if (UXReaderDestination *destination = [[UXReaderDestination alloc] initWithPage:index target:target])
				{
					item = [[UXReaderAction alloc] initWithGoto:destination rectangle:rect];
				}
				break;
			}

			case PDFACTION_REMOTEGOTO: // Remote goto
			{
				if (int bytes = int(FPDFAction_GetFilePath(action, nil, 0)))
				{
					if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
					{
						FPDFAction_GetFilePath(action, [data mutableBytes], bytes);

						const NSUInteger length = ((bytes / sizeof(unichar)) - 1); // No NUL

						const unichar *unicode = reinterpret_cast<const unichar *>([data bytes]);

						NSString *path = [[NSString alloc] initWithCharacters:unicode length:length];

						NSUInteger index = NSUIntegerMax; UXReaderDestinationTarget target {};

						if (FPDF_DEST dest = FPDFLink_GetDest(pdfDocumentFP, link)) // Destination
						{
							index = NSUInteger(FPDFDest_GetPageIndex(pdfDocumentFP, dest));

							FS_FLOAT pageX = 0.0f; FS_FLOAT pageY = 0.0f; FS_FLOAT zoom = 0.0f;

							FPDF_BOOL bX = FALSE; FPDF_BOOL bY = FALSE; FPDF_BOOL bZoom = FALSE;

							if (FPDFDest_GetLocationInPage(dest, &bX, &bY, &bZoom, &pageX, &pageY, &zoom))
							{
								target = {BOOL(bX), BOOL(bY), BOOL(bZoom), pageX, pageY, zoom};
							}
						}

						CGRect rect = CGRectZero; FS_RECTF rectf = {0.0f, 0.0f, 0.0f, 0.0f};

						if (FPDFLink_GetAnnotRect(link, &rectf)) // Convert from page coordinates
						{
							rect = [self convertFromPageX1:rectf.left Y1:rectf.bottom X2:rectf.right Y2:rectf.top];
						}

						if (UXReaderDestination *destination = [[UXReaderDestination alloc] initWithPage:index target:target])
						{
							item = [[UXReaderAction alloc] initWithRemoteGoto:destination path:path rectangle:rect];
						}
					}
				}
				break;
			}

			case PDFACTION_LAUNCH: // Launch
			{
				if (int bytes = int(FPDFAction_GetFilePath(action, nil, 0)))
				{
					if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
					{
						FPDFAction_GetFilePath(action, [data mutableBytes], bytes);

						const NSUInteger length = ((bytes / sizeof(unichar)) - 1); // No NUL

						const unichar *unicode = reinterpret_cast<const unichar *>([data bytes]);

						NSString *path = [[NSString alloc] initWithCharacters:unicode length:length];

						CGRect rect = CGRectZero; FS_RECTF rectf = {0.0f, 0.0f, 0.0f, 0.0f};

						if (FPDFLink_GetAnnotRect(link, &rectf)) // Convert from page coordinates
						{
							rect = [self convertFromPageX1:rectf.left Y1:rectf.bottom X2:rectf.right Y2:rectf.top];
						}

						item = [[UXReaderAction alloc] initWithLaunch:path rectangle:rect];
					}
				}
				break;
			}

			default: // Unknown type
			{
				NSLog(@"%s FPDFAction_GetType() not known", __FUNCTION__);
				break;
			}
		}
	}
	else // Try FPDF_DEST for FPDF_LINK
	{
		NSUInteger index = NSUIntegerMax; UXReaderDestinationTarget target {};

		if (FPDF_DEST dest = FPDFLink_GetDest(pdfDocumentFP, link)) // Destination
		{
			index = NSUInteger(FPDFDest_GetPageIndex(pdfDocumentFP, dest));

			FS_FLOAT pageX = 0.0f; FS_FLOAT pageY = 0.0f; FS_FLOAT zoom = 0.0f;

			FPDF_BOOL bX = FALSE; FPDF_BOOL bY = FALSE; FPDF_BOOL bZoom = FALSE;

			if (FPDFDest_GetLocationInPage(dest, &bX, &bY, &bZoom, &pageX, &pageY, &zoom))
			{
				target = {BOOL(bX), BOOL(bY), BOOL(bZoom), pageX, pageY, zoom};
			}
		}

		CGRect rect = CGRectZero; FS_RECTF rectf = {0.0f, 0.0f, 0.0f, 0.0f};

		if (FPDFLink_GetAnnotRect(link, &rectf)) // Convert from page coordinates
		{
			rect = [self convertFromPageX1:rectf.left Y1:rectf.bottom X2:rectf.right Y2:rectf.top];
		}

		if (UXReaderDestination *destination = [[UXReaderDestination alloc] initWithPage:index target:target])
		{
			item = [[UXReaderAction alloc] initWithGoto:destination rectangle:rect];
		}
	}

	return item;
}

- (BOOL)extractPageLinks
{
	//NSLog(@"%s", __FUNCTION__);

	__block BOOL extracted = NO; // Status

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (pageLinks == nil) // Extract
		{
			int entry = 0; FPDF_LINK link = nil;

			NSMutableArray<UXReaderAction *> *links = [[NSMutableArray alloc] init];

			while (FPDFLink_Enumerate(pdfPageFP, &entry, &link)) // Enumerate
			{
				if (UXReaderAction *item = [self actionForLink:link])
				{
					[links addObject:item];
				}
			}

			extracted = ([links count] > 0);

			pageLinks = [links copy];
		}
	}];

	return extracted;
}

- (nullable UXReaderAction *)linkAction:(CGPoint)point
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));

	__block UXReaderAction *action = nil;

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (pageLinks == nil) // Get action for point
		{
			const CGPoint pt = [self convertToPageFromViewPoint:point];

			if (FPDF_LINK link = FPDFLink_GetLinkAtPoint(pdfPageFP, pt.x, pt.y))
			{
				action = [self actionForLink:link];
			}
		}
		else // Enumerate through links list
		{
			for (UXReaderAction *pageLink in pageLinks)
			{
				if ([pageLink containsPoint:point] == YES)
				{
					action = pageLink; break;
				}
			}
		}
	}];

	return action;
}

- (BOOL)extractPageURLs
{
	//NSLog(@"%s", __FUNCTION__);

	__block BOOL extracted = NO; // Status

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (pageURLs == nil) // Extract any text-based URLs
		{
			NSMutableArray<UXReaderAction *> *links = [[NSMutableArray alloc] init];

			if (FPDF_TEXTPAGE textPage = [self textPage]) // FPDF_TEXTPAGE
			{
				if (FPDF_PAGELINK pageLink = FPDFLink_LoadWebLinks(textPage))
				{
					if (int linkCount = FPDFLink_CountWebLinks(pageLink))
					{
						for (int linkIndex = 0; linkIndex < linkCount; linkIndex++)
						{
							if (int unichars = FPDFLink_GetURL(pageLink, linkIndex, nil, 0))
							{
								const NSUInteger bytes = (unichars * sizeof(unichar));

								if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
								{
									unichar *unicode = reinterpret_cast<unichar *>([data mutableBytes]);

									const int length = (FPDFLink_GetURL(pageLink, linkIndex, unicode, unichars) - 1);

									NSString *URI = [[NSString alloc] initWithCharacters:unicode length:length];

									NSMutableArray<NSValue *> *rectangles = [[NSMutableArray alloc] init];

									if (int rectCount = FPDFLink_CountRects(pageLink, linkIndex))
									{
										for (int rectIndex = 0; rectIndex < rectCount; rectIndex++)
										{
											double x1 = 0.0; double y1 = 0.0; double x2 = 0.0; double y2 = 0.0;

											FPDFLink_GetRect(pageLink, linkIndex, rectIndex, &x1, &y2, &x2, &y1);

											const CGRect rect = [self convertFromPageX1:x1 Y1:y1 X2:x2 Y2:y2];

											[rectangles addObject:[NSValue valueWithCGRect:rect]];
										}
									}

									if (UXReaderAction *item = [[UXReaderAction alloc] initWithLink:URI rectangles:rectangles])
									{
										[links addObject:item];
									}
								}
							}
						}
					}

					FPDFLink_CloseWebLinks(pageLink);
				}
			}

			extracted = ([links count] > 0);

			pageURLs = [links copy];
		}
	}];

	return extracted;
}

- (nullable UXReaderAction *)textAction:(CGPoint)point
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));

	__block UXReaderAction *action = nil;

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (pageURLs == nil) // Extract
		{
			[self extractPageURLs];
		}

		if ([pageURLs count] > 0) // Test point
		{
			for (UXReaderAction *pageURL in pageURLs)
			{
				if ([pageURL containsPoint:point] == YES)
				{
					action = pageURL; break;
				}
			}
		}
	}];

	return action;
}

#pragma mark - UXReaderDocumentPage text methods

- (NSUInteger)unicharCount
{
	//NSLog(@"%s", __FUNCTION__);

	__block NSUInteger count = 0; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			count = FPDFText_CountChars(textPage);
		}
	}];

	return count;
}

- (nullable NSString *)text
{
	//NSLog(@"%s", __FUNCTION__);

	__block NSString *text = nil; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			if (int unichars = FPDFText_CountChars(textPage))
			{
				const NSUInteger bytes = ((unichars + 1) * sizeof(unichar));

				if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
				{
					unichar *unicode = reinterpret_cast<unichar *>([data mutableBytes]);

					const int length = (FPDFText_GetText(textPage, int(0), int(unichars), unicode));

					text = [[NSString alloc] initWithCharacters:unicode length:(length - 1)];
				}
			}
		}
	}];

	return text;
}

- (nullable NSString *)textAtIndex:(NSUInteger)index count:(NSUInteger)count
{
	//NSLog(@"%s %i %i", __FUNCTION__, int(index), int(count));

	__block NSString *text = nil; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			if (int unichars = FPDFText_CountChars(textPage))
			{
				if ((index < unichars) && ((index + count) <= unichars))
				{
					const NSUInteger bytes = ((count + 1) * sizeof(unichar));

					if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
					{
						unichar *unicode = reinterpret_cast<unichar *>([data mutableBytes]);

						const int length = (FPDFText_GetText(textPage, int(index), int(count), unicode));

						text = [[NSString alloc] initWithCharacters:unicode length:(length - 1)];
					}
				}
			}
		}
	}];

	return text;
}

- (unichar)unicharAtIndex:(NSUInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	__block unichar character = 0x0000; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			const int unichars = FPDFText_CountChars(textPage);

			if ((unichars > 0) && (index < unichars)) // Get unichar
			{
				character = unichar(FPDFText_GetUnicode(textPage, int(index)));
			}
		}
	}];

	return character;
}

- (CGFloat)unicharFontSizeAtIndex:(NSUInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	__block CGFloat fontSize = 0.0; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			const int unichars = FPDFText_CountChars(textPage);

			if ((unichars > 0) && (index < unichars)) // Get font size
			{
				fontSize = FPDFText_GetFontSize(textPage, int(index));
			}
		}
	}];

	return fontSize;
}

- (CGRect)unicharRectangleAtIndex:(NSUInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	__block CGRect rect = CGRectZero; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			const int unichars = FPDFText_CountChars(textPage);

			if ((unichars > 0) && (index < unichars)) // Get character rect
			{
				double x1 = 0.0; double y1 = 0.0; double x2 = 0.0; double y2 = 0.0;

				FPDFText_GetCharBox(textPage, int(index), &x1, &x2, &y1, &y2);

				rect = [self convertFromPageX1:x1 Y1:y1 X2:x2 Y2:y2];
			}
		}
	}];

	return rect;
}

- (NSUInteger)unicharIndexAtPoint:(CGPoint)point tolerance:(CGSize)size
{
	//NSLog(@"%s %@ %@", __FUNCTION__, NSStringFromCGPoint(point), NSStringFromCGSize(size));

	__block NSUInteger index = NSUIntegerMax; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			if (FPDFText_CountChars(textPage) > 0) // Look for unichar
			{
				const CGPoint near = [self convertToPageFromViewPoint:point];

				index = FPDFText_GetCharIndexAtPos(textPage, near.x, near.y, size.width, size.height);
			}
		}
	}];

	return index;
}

- (nonnull NSArray<NSValue *> *)rectanglesForTextAtIndex:(NSUInteger)index count:(NSUInteger)count
{
	//NSLog(@"%s %i %i", __FUNCTION__, int(index), int(count));

	NSMutableArray<NSValue *> *rectangles = [[NSMutableArray alloc] init];

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			if (int unichars = FPDFText_CountChars(textPage))
			{
				if ((index < unichars) && ((index + count) <= unichars))
				{
					if (int rectCount = FPDFText_CountRects(textPage, int(index), int(count)))
					{
						for (int rectIndex = 0; rectIndex < rectCount; rectIndex++)
						{
							double x1 = 0.0; double y1 = 0.0; double x2 = 0.0; double y2 = 0.0;

							FPDFText_GetRect(textPage, rectIndex, &x1, &y2, &x2, &y1);

							const CGRect rect = [self convertFromPageX1:x1 Y1:y1 X2:x2 Y2:y2];

							[rectangles addObject:[NSValue valueWithCGRect:rect]];
						}
					}
				}
			}
		}
	}];

	return [rectangles copy];
}

- (nullable NSString *)textInRectangle:(CGRect)rectangle
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(rectangle));

	__block NSString *text = nil; // Default

	[UXReaderFramework dispatch_sync_on_work_queue:
	^{
		if (FPDF_TEXTPAGE textPage = [self textPage])
		{
			if (FPDFText_CountChars(textPage) > 0) // Get text
			{
//				const CGPoint vp1 = rectangle.origin; CGPoint vp2 = vp1;
//				vp2.x += rectangle.size.width; vp2.y += rectangle.size.height;
//
//				const CGPoint pt1 = [self convertToPageFromViewPoint:vp1];
//				const CGPoint pt2 = [self convertToPageFromViewPoint:vp2];
//
//				const double x1 = pt1.x; const double y1 = pt1.y;
//				const double x2 = pt2.x; const double y2 = pt2.y;

				const CGRect area = [self convertToPageFromViewRect:rectangle];

				const double x1 = area.origin.x; const double x2 = (x1 + area.size.width);
				const double y1 = area.origin.y; const double y2 = (y1 + area.size.height);
				
				if (int count = FPDFText_GetBoundedText(textPage, x1, y2, x2, y1, nil, 0))
				{
					const NSUInteger bytes = ((count + 1) * sizeof(unichar));

					if (NSMutableData *data = [NSMutableData dataWithLength:bytes])
					{
						unichar *unicode = reinterpret_cast<unichar *>([data mutableBytes]);

						const int length = FPDFText_GetBoundedText(textPage, x1, y2, x2, y1, unicode, count);

						text = [[NSString alloc] initWithCharacters:unicode length:(length - 1)];
					}
				}
			}
		}
	}];

	return text;
}

@end

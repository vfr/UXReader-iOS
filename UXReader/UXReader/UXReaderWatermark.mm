//
//	UXReaderWatermark.h
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderWatermark.h"
#import "UXReaderDocumentPage.h"

#import <CoreText/CoreText.h>

@implementation UXReaderWatermark
{
	NSMutableArray<NSValue *> *lineSizes;

	NSMutableArray<NSAttributedString *> *textLines;

	CGSize totalSize; CGFloat fudge;
}

#pragma mark - UXReaderWatermark instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	return [self initWithText:@[@"Watermark", @"Demo"]];
}

- (nullable instancetype)initWithText:(nonnull NSArray<NSString *> *)lines
{
	//NSLog(@"%s %@", __FUNCTION__, lines);

	if ((self = [super init])) // Initialize superclass
	{
		if ([lines count] > 0) [self prepareWatermark:lines]; else self = nil;
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (void)prepareWatermark:(nonnull NSArray<NSString *> *)lines
{
	//NSLog(@"%s %@", __FUNCTION__, lines);

	UIFont *font = [UIFont fontWithName:@"Helvetica" size:36.0];

	UIColor *color = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1];

	NSDictionary<NSString *, id> *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : color};

	lineSizes = [[NSMutableArray alloc] init]; textLines = [[NSMutableArray alloc] init]; fudge = 0.7;

	for (NSString *line in lines) // Enumerate watermark text lines
	{
		NSString *trim = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

		NSAttributedString *text = [[NSAttributedString alloc] initWithString:trim attributes:attributes];

		CGSize textSize = [text size]; textSize.width = ceil(textSize.width); textSize.height = ceil(textSize.height);

		totalSize.height += textSize.height; if (totalSize.width < textSize.width) totalSize.width = textSize.width;

		[textLines addObject:text]; [lineSizes addObject:[NSValue valueWithCGSize:textSize]];
	}
}

//
//	The -documentPage:renderTileInContext: method is called by the UXReader framework on a non-main
//	queue from within CATiledLayer's -drawLayer:inContext: method after a PDF tile and any highlights
//	have been rendered. The implementation needs to be thread safe and as quick as possible.
//

- (void)documentPage:(nonnull UXReaderDocumentPage *)documentPage renderTileInContext:(nonnull CGContextRef)context
{
	//NSLog(@"%s %@ %p", __FUNCTION__, documentPage, context);

	//
	//	Get the rect being requested for draw:
	//
	//const CGRect rect = CGContextGetClipBoundingBox(context);
	//
	//	Use as clip rect for best performance.
	//

	const NSUInteger lines = [textLines count];

	if (documentPage && context && lines) // Ok
	{
		CGContextSaveGState(context); // Save context

		const CGSize pageSize = [documentPage pageSize]; // In points

		const CGFloat bw = pageSize.width; const CGFloat bh = pageSize.height; // Bounds

		const CGFloat ar = ((bw > bh) ? (bh / bw) : (bw / bh)); const CGFloat sf = (sqrt(sqrt(ar)) * fudge);

		CGContextTranslateCTM(context, (bw * 0.5), (bh * 0.5)); CGContextRotateCTM(context, -atan2(bh, bw));

		const CGFloat ts = ((sqrt((bw * bw) + (bh * bh)) / totalSize.width) * sf); CGContextScaleCTM(context, ts, -ts);

		const CGFloat xt = -floor(totalSize.width * 0.5); CGFloat yp = -floor(totalSize.height * 0.5); // Center

		//CGRect fillRect = CGRectZero; fillRect.size = totalSize; fillRect.origin = CGPointMake(xt, yp);

		//CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.1); CGContextFillRect(context, fillRect);

		for (NSUInteger l = 0; l < lines; l++) // Iterate watermark text lines
		{
			const NSUInteger i = ((lines - 1) - l); // Reverse the order

			NSValue *value = lineSizes[i]; const CGSize lineSize = [value CGSizeValue];

			const CGFloat xp = (((totalSize.width - lineSize.width) * 0.5) + xt); // Line X

			const CTLineRef ctLine = CTLineCreateWithAttributedString((CFAttributedStringRef)textLines[i]);

			CGContextSetTextPosition(context, xp, yp); CTLineDraw(ctLine, context); CFRelease(ctLine);

			yp += lineSize.height; // Next line Y
		}

		CGContextRestoreGState(context); // Restore context
	}
}

@end

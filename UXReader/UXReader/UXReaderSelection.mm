//
//	UXReaderSelection.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderSelection.h"

@implementation UXReaderSelection
{
	__weak UXReaderDocument *document;

	NSUInteger unicharIndex, unicharCount;

	NSArray<NSValue *> *rectangles;

	NSValue *rectangle;

	NSUInteger page;

	BOOL highlight;
}

#pragma mark - UXReaderSelection class methods

+ (nullable instancetype)document:(nonnull UXReaderDocument *)document page:(NSUInteger)page index:(NSUInteger)index count:(NSUInteger)count rectangles:(nonnull NSArray<NSValue *> *)rectangles
{
	//NSLog(@"%s %@ %i %i %i %@", __FUNCTION__, document, int(page), int(index), int(count), rectangles);

	return [[UXReaderSelection alloc] initWithDocument:document page:page index:index count:count rectangles:rectangles];
}

#pragma mark - UXReaderSelection instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		page = NSUIntegerMax; unicharIndex = NSUIntegerMax;
	}

	return self;
}

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx page:(NSUInteger)pagex index:(NSUInteger)index count:(NSUInteger)count rectangles:(nonnull NSArray<NSValue *> *)rects
{
	//NSLog(@"%s %@ %i %i %i %@", __FUNCTION__, documentx, int(pagex), int(index), int(count), rects);

	if ((self = [self init])) // Initialize self
	{
		if ((documentx != nil) && ([rects count] > 0) && (count > 0))
		{
			document = documentx; page = pagex; rectangles = [rects copy];

			unicharIndex = index; unicharCount = count;
		}
		else // On failure
		{
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (NSUInteger)page
{
	//NSLog(@"%s", __FUNCTION__);

	return page;
}

- (nullable NSArray<NSValue *> *)rectangles
{
	//NSLog(@"%s", __FUNCTION__);

	return rectangles;
}

- (CGRect)rectangle
{
	//NSLog(@"%s", __FUNCTION__);

	if (rectangle == nil) // Calculate
	{
		CGFloat x1 = CGFLOAT_MAX; CGFloat y1 = CGFLOAT_MAX;
		CGFloat x2 = CGFLOAT_MIN; CGFloat y2 = CGFLOAT_MIN;

		for (NSValue *value in rectangles)
		{
			const CGRect rect = [value CGRectValue];

			const CGFloat rx1 = rect.origin.x; const CGFloat rx2 = (rx1 + rect.size.width);
			const CGFloat ry1 = rect.origin.y; const CGFloat ry2 = (ry1 + rect.size.height);

			if (rx1 < x1) x1 = rx1; if (rx2 > x2) x2 = rx2; if (ry1 < y1) y1 = ry1; if (ry2 > y2) y2 = ry2;
		}

		if ((x1 != CGFLOAT_MAX) && (y1 != CGFLOAT_MAX) && (x2 != CGFLOAT_MIN) && (y2 != CGFLOAT_MIN))
			rectangle = [NSValue valueWithCGRect:CGRectMake(x1, y1, (x2 - x1), (y2 - y1))];
		else
			rectangle = [NSValue valueWithCGRect:CGRectZero];
	}

	return [rectangle CGRectValue];
}

- (void)setHighlight:(BOOL)state
{
	//NSLog(@"%s %i", __FUNCTION__, state);

	highlight = state;
}

- (BOOL)isHighlighted
{
	//NSLog(@"%s", __FUNCTION__);

	return highlight;
}

- (NSString *)description
{
	//NSLog(@"%s", __FUNCTION__);

	return [NSString stringWithFormat:@"Page: %i %@", int(page), rectangles];
}

@end

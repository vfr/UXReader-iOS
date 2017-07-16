//
//	UXReaderAction.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderAction.h"

@implementation UXReaderAction
{
	UXReaderActionType type;

	NSString *URI; NSString *path;

	UXReaderDestination *destination;

	NSArray<NSValue *> *rectangles;

	CGRect rectangle;
}

#pragma mark - UXReaderAction instance methods

- (nullable instancetype)initWithURI:(nonnull NSString *)URIx rectangle:(CGRect)rect
{
	//NSLog(@"%s %@ %@", __FUNCTION__, URIx, NSStringFromCGRect(rect));

	if ((self = [super init])) // Initialize superclass
	{
		type = UXReaderActionTypeURI; URI = [URIx copy]; rectangle = rect;
	}

	return self;
}

- (nullable instancetype)initWithGoto:(nonnull UXReaderDestination *)destinationx rectangle:(CGRect)rect
{
	//NSLog(@"%s %@ %@", __FUNCTION__, destinationx, NSStringFromCGRect(rect));

	if ((self = [super init])) // Initialize superclass
	{
		type = UXReaderActionTypeGoto; destination = destinationx; rectangle = rect;
	}

	return self;
}

- (nullable instancetype)initWithRemoteGoto:(nonnull UXReaderDestination *)destinationx path:(nonnull NSString *)pathx rectangle:(CGRect)rect
{
	//NSLog(@"%s %@ %@ %@", __FUNCTION__, destinationx, pathx, NSStringFromCGRect(rect));

	if ((self = [super init])) // Initialize superclass
	{
		type = UXReaderActionTypeRemoteGoto; destination = destinationx; path = [pathx copy]; rectangle = rect;
	}

	return self;
}

- (nullable instancetype)initWithLaunch:(nonnull NSString *)pathx rectangle:(CGRect)rect
{
	//NSLog(@"%s %@ %@", __FUNCTION__, pathx, NSStringFromCGRect(rect));

	if ((self = [super init])) // Initialize superclass
	{
		type = UXReaderActionTypeLaunch; path = [pathx copy]; rectangle = rect;
	}

	return self;
}

- (nullable instancetype)initWithLink:(nonnull NSString *)URIx rectangles:(nonnull NSArray<NSValue *> *)list
{
	//NSLog(@"%s %@ %@", __FUNCTION__, URIx, list);

	if ((self = [super init])) // Initialize superclass
	{
		type = UXReaderActionTypeLink; URI = [URIx copy]; rectangles = [list copy];
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (BOOL)containsPoint:(CGPoint)point
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));

	BOOL contains = NO; // Status

	switch (type) // UXReaderActionType
	{
		case UXReaderActionTypeURI:
		case UXReaderActionTypeGoto:
		case UXReaderActionTypeRemoteGoto:
		case UXReaderActionTypeLaunch:
		{
			contains = CGRectContainsPoint(rectangle, point);
			break;
		}

		case UXReaderActionTypeLink:
		{
			for (NSValue *value in rectangles)
			{
				const CGRect area = [value CGRectValue];

				if ((contains = CGRectContainsPoint(area, point))) break;
			}
			break;
		}

		case UXReaderActionTypeNone:
		{
			break;
		}
	}

	return contains;
}

- (UXReaderActionType)type
{
	//NSLog(@"%s", __FUNCTION__);

	return type;
}

- (nullable NSString *)URI
{
	//NSLog(@"%s", __FUNCTION__);

	return URI;
}

- (nullable NSString *)path
{
	//NSLog(@"%s", __FUNCTION__);

	return path;
}

- (nullable UXReaderDestination *)destination;
{
	//NSLog(@"%s", __FUNCTION__);

	return destination;
}

- (nullable NSArray<NSValue *> *)rectangles
{
	//NSLog(@"%s", __FUNCTION__);

	return rectangles;
}

- (CGRect)rectangle
{
	//NSLog(@"%s", __FUNCTION__);

	return rectangle;
}

- (NSString *)description
{
	//NSLog(@"%s", __FUNCTION__);

	return [NSString stringWithFormat:@"Type = %i", int(type)];
}

@end

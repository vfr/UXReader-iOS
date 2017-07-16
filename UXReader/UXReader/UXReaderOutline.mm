//
//	UXReaderOutline.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderOutline.h"

@implementation UXReaderOutline
{
	NSString *name;

	UXReaderAction *action;

	NSUInteger level;
}

#pragma mark - UXReaderOutline instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		level = NSUIntegerMax;
	}

	return self;
}

- (nullable instancetype)initWithName:(nonnull NSString *)namex action:(nonnull UXReaderAction *)actionx level:(NSUInteger)levelx
{
	//NSLog(@"%s %@ %@ %i", __FUNCTION__, namex, actionx, int(levelx));

	if ((self = [self init])) // Initialize self
	{
		name = namex; action = actionx; level = levelx;
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (nonnull NSString *)name
{
	//NSLog(@"%s", __FUNCTION__);

	return name;
}

- (nonnull UXReaderAction *)action
{
	//NSLog(@"%s", __FUNCTION__);

	return action;
}

- (NSUInteger)level
{
	//NSLog(@"%s", __FUNCTION__);

	return level;
}

- (NSString *)description
{
	//NSLog(@"%s", __FUNCTION__);

	return [NSString stringWithFormat:@"Name = %@, Level = %i", name, int(level)];
}

@end

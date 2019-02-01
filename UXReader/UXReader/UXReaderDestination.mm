//
//	UXReaderDestination.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDestination.h"

@implementation UXReaderDestination
{
	NSUInteger page;

	UXReaderDestinationTarget target;
}

#pragma mark - UXReaderDestination instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		page = NSUIntegerMax;
	}

	return self;
}

- (nullable instancetype)initWithPage:(NSUInteger)pagex target:(UXReaderDestinationTarget)targetx
{
	//NSLog(@"%s %i", __FUNCTION__, int(pagex));

	if ((self = [self init])) // Initialize self
	{
		page = pagex; target = targetx;
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

- (UXReaderDestinationTarget)target
{
	//NSLog(@"%s", __FUNCTION__);

	return target;
}

- (NSString *)description
{
	//NSLog(@"%s", __FUNCTION__);

	return [NSString stringWithFormat:@"Page = %i", int(page)];
}

@end

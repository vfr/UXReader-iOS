//
//	UXReaderCanceller.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderCanceller.h"

@implementation UXReaderCanceller
{
	NSLock *lock;

	NSUUID *UUID;

	BOOL cancel;
}

#pragma mark - UXReaderCanceller instance methods

- (nullable instancetype)initWithLock
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		UUID = [[NSUUID alloc] init]; lock = [[NSLock alloc] init];

		//NSLog(@"%s %@", __FUNCTION__, UUID);
	}

	return self;
}

- (nullable instancetype)initWithUUID
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		UUID = [[NSUUID alloc] init]; //lock = [[NSLock alloc] init];

		//NSLog(@"%s %@", __FUNCTION__, UUID);
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s %@", __FUNCTION__, UUID);

//	if (cancel == YES) // Log when cancelled
//	{
//		NSLog(@"%s Cancelled %@", __FUNCTION__, UUID);
//	}
}

- (NSString *)description
{
	//NSLog(@"%s", __FUNCTION__);

	return [NSString stringWithFormat:@"UXReaderCanceller %@", UUID];
}

- (void)cancel
{
	//NSLog(@"%s %@", __FUNCTION__, UUID);

	cancel = YES;
}

- (BOOL)isCancelled
{
	//NSLog(@"%s", __FUNCTION__);

	return cancel;
}

- (nonnull NSLock *)lock
{
	//NSLog(@"%s", __FUNCTION__);

	return lock;
}

- (nonnull NSUUID *)UUID
{
	//NSLog(@"%s", __FUNCTION__);

	return UUID;
}

@end

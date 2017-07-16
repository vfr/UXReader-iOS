//
//	UXReaderFramework.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderFramework.h"
#import "UXReaderThumbCache.h"

#import "fpdfview.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

#include <sys/sysctl.h>
#include <sys/utsname.h>

@implementation UXReaderFramework
{
	NSMutableDictionary<NSString *, id> *defaults;

	dispatch_queue_t workQueue;
}

#pragma mark - Constants

static NSString *const kUXReaderFrameworkDefaults = @"UXReaderFrameworkDefaults";

static const char *const UXReaderFrameworkWorkQueue = "UXReaderFramework-WorkQueue";

#pragma mark - UXReaderFramework class methods

+ (nullable instancetype)sharedInstance
{
	//NSLog(@"%s", __FUNCTION__);

	static dispatch_once_t predicate = 0;

	static UXReaderFramework *singleton = nil;

	dispatch_once(&predicate, ^{ singleton = [[UXReaderFramework alloc] init]; });

	return singleton; // UXReaderFramework
}

+ (BOOL)isSmallDevice
{
	//NSLog(@"%s", __FUNCTION__);

	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

+ (CGFloat)statusBarHeight
{
	//NSLog(@"%s", __FUNCTION__);

	const CGRect frame = [[UIApplication sharedApplication] statusBarFrame];

	const CGFloat w = frame.size.width; const CGFloat h = frame.size.height;

	return ((h < w) ? h : w); // Should be 0.0 or 20.0
}

+ (CGFloat)mainToolbarHeight
{
	//NSLog(@"%s", __FUNCTION__);

	return 44.0; // Points
}

+ (CGFloat)pageToolbarHeight
{
	//NSLog(@"%s", __FUNCTION__);

	return 47.0; // Points
}

+ (CGFloat)searchControlHeight
{
	//NSLog(@"%s", __FUNCTION__);

	return 64.0; // Points
}

+ (NSTimeInterval)searchBeginTimer
{
	//NSLog(@"%s", __FUNCTION__);

	return 1.25; // Seconds
}

+ (NSTimeInterval)animationDuration
{
	//NSLog(@"%s", __FUNCTION__);

	return 0.25; // Seconds
}

+ (nonnull UIColor *)toolbarTitleTextColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.24 alpha:1.00];
}

+ (nonnull UIColor *)toolbarBackgroundColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:1.00 alpha:0.48];
}

+ (nonnull UIColor *)toolbarSeparatorLineColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.64 alpha:0.92];
}

+ (nonnull UIColor *)scrollViewBackgroundColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.32 alpha:1.00];
}

+ (nonnull UIColor *)lightTextColor
{
	//NSLog(@"%s", __FUNCTION__);

	return [UIColor colorWithWhite:0.64 alpha:1.00];
}

+ (void)dispatch_sync_on_work_queue:(nonnull dispatch_block_t)block
{
	//NSLog(@"%s %p", __FUNCTION__, block);

	[[UXReaderFramework sharedInstance] dispatch_sync_on_work_queue:block];
}

+ (void)dispatch_async_on_work_queue:(nonnull dispatch_block_t)block
{
	//NSLog(@"%s %p", __FUNCTION__, block);

	[[UXReaderFramework sharedInstance] dispatch_async_on_work_queue:block];
}

+ (nonnull NSMutableDictionary<NSString *, id> *)defaults
{
	//NSLog(@"%s", __FUNCTION__);

	return [[UXReaderFramework sharedInstance] defaults];
}

+ (void)saveDefaults
{
	//NSLog(@"%s", __FUNCTION__);

	[[UXReaderFramework sharedInstance] saveDefaults];
}

+ (size_t)deviceMemory
{
	//NSLog(@"%s", __FUNCTION__);

	static int mib[2] = {CTL_HW, HW_PHYSMEM};

	size_t memory = 0; size_t size = sizeof(memory);

	sysctl(mib, 2, &memory, &size, nil, 0);

	return memory;
}

+ (nonnull NSString *)deviceModel
{
	//NSLog(@"%s", __FUNCTION__);

	struct utsname systemInfo; memset(&systemInfo, 0x00, sizeof(systemInfo)); uname(&systemInfo);

	return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (uint64_t)time:(uint64_t)from
{
	//NSLog(@"%s", __FUNCTION__);

	const uint64_t elapsed = (mach_absolute_time() - from);

	mach_timebase_info_data_t sTimebaseInfo; mach_timebase_info(&sTimebaseInfo);

	const uint64_t nanoseconds = ((elapsed * sTimebaseInfo.numer) / sTimebaseInfo.denom);

	return (nanoseconds / 1000ull); // Microseconds
}

+ (uint64_t)time
{
	//NSLog(@"%s", __FUNCTION__);

	return mach_absolute_time();
}

#pragma mark - UXReaderFramework instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		defaults = [[NSMutableDictionary alloc] init]; [self loadDefaults];

		workQueue = dispatch_queue_create(UXReaderFrameworkWorkQueue, DISPATCH_QUEUE_SERIAL);

		//const uint64_t time = [UXReaderFramework time]; // Time execution

		FPDF_LIBRARY_CONFIG config; memset(&config, 0x00, sizeof(config));

		config.version = 2; FPDF_InitLibraryWithConfig(&config); // Setup

		//NSLog(@"%s %llu μs", __FUNCTION__, [UXReaderFramework time:time]);

		[UXReaderThumbCache purgeDiskThumbCache:(86400.0 * 1.0)]; // 24h
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);

	FPDF_DestroyLibrary();
}

- (void)dispatch_sync_on_work_queue:(nonnull dispatch_block_t)block
{
	//NSLog(@"%s %p", __FUNCTION__, block);

	const char *label = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);

	if (strcmp(label, UXReaderFrameworkWorkQueue) != 0)
		dispatch_sync(workQueue, block);
	else
		block();
}

- (void)dispatch_async_on_work_queue:(nonnull dispatch_block_t)block
{
	//NSLog(@"%s %p", __FUNCTION__, block);

	dispatch_async(workQueue, block);
}

- (void)loadDefaults
{
	//NSLog(@"%s", __FUNCTION__);

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	if (NSDictionary<NSString *, id> *temp = [userDefaults dictionaryForKey:kUXReaderFrameworkDefaults])
	{
		defaults = [temp mutableCopy];
	}
}

- (void)saveDefaults
{
	//NSLog(@"%s", __FUNCTION__);

	if (defaults != nil) // Save defaults dictionary
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

		[userDefaults setObject:defaults forKey:kUXReaderFrameworkDefaults];
	}
}

- (nonnull NSMutableDictionary<NSString *, id> *)defaults
{
	//NSLog(@"%s", __FUNCTION__);

	return defaults;
}

@end

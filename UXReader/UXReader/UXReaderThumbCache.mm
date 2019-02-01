//
//	UXReaderThumbCache.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderThumbCache.h"
#import "UXReaderFramework.h"

#import <ImageIO/ImageIO.h>

@implementation UXReaderThumbCache
{
	NSCache *thumbCache;

	NSFileManager *fileManager;

	NSURL *thumbCacheURL;
}

#pragma mark - UXReaderThumbCache class methods

+ (nullable instancetype)sharedInstance
{
	//NSLog(@"%s", __FUNCTION__);

	static dispatch_once_t predicate = 0;

	static UXReaderThumbCache *singleton = nil;

	dispatch_once(&predicate, ^{ singleton = [[UXReaderThumbCache alloc] init]; });

	return singleton; // UXReaderThumbCache
}

+ (nullable UIImage *)loadThumbForUUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size
{
	//NSLog(@"%s %@ %i %@", __FUNCTION__, UUID, int(page), NSStringFromCGSize(size));

	return [[UXReaderThumbCache sharedInstance] loadThumbForUUID:UUID page:page size:size];
}

+ (void)saveThumb:(nonnull UIImage *)thumb UUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size
{
	//NSLog(@"%s %@ %@ %i %@", __FUNCTION__, thumb, UUID, int(page), NSStringFromCGSize(size));

	[[UXReaderThumbCache sharedInstance] saveThumb:thumb UUID:UUID page:page size:size];
}

+ (void)touchDirectoryForUUID:(nonnull NSUUID *)UUID
{
	//NSLog(@"%s %@", __FUNCTION__, UUID);

	[[UXReaderThumbCache sharedInstance] touchDirectoryForUUID:UUID];
}

+ (void)purgeDiskThumbCache:(NSTimeInterval)age
{
	//NSLog(@"%s %g", __FUNCTION__, age);

	[[UXReaderThumbCache sharedInstance] purgeDiskThumbCache:age];
}

+ (void)purgeMemoryThumbCache
{
	//NSLog(@"%s", __FUNCTION__);

	[[UXReaderThumbCache sharedInstance] purgeMemoryThumbCache];
}

#pragma mark - UXReaderThumbCache instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		fileManager = [NSFileManager defaultManager]; // NSFileManager

		NSArray<NSURL *> *URLs = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];

		thumbCacheURL = [[URLs firstObject] URLByAppendingPathComponent:@"UXReaderThumbCache"]; // Cache directory

		[fileManager createDirectoryAtURL:thumbCacheURL withIntermediateDirectories:YES attributes:nil error:nil];

		[thumbCacheURL setResourceValue:@(YES) forKey: NSURLIsExcludedFromBackupKey error:nil]; // No backups

		size_t total = ([UXReaderFramework deviceMemory] / 128); if (total < 4194304) total = 4194304;

		thumbCache = [[NSCache alloc] init]; [thumbCache setTotalCostLimit:total];

		[thumbCache setName:@"UXReaderThumbCache"];
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (void)touchDirectoryForUUID:(nonnull NSUUID *)UUID
{
	//NSLog(@"%s %@", __FUNCTION__, UUID);

	NSURL *url = [thumbCacheURL URLByAppendingPathComponent:[UUID UUIDString] isDirectory:YES];

	[url setResourceValue:[NSDate date] forKey:NSURLCreationDateKey error:nil];
}

- (void)createDirectoryForUUID:(nonnull NSUUID *)UUID
{
	//NSLog(@"%s %@", __FUNCTION__, UUID);

	NSURL *url = [thumbCacheURL URLByAppendingPathComponent:[UUID UUIDString] isDirectory:YES];

	[fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
}

- (nonnull NSURL *)urlForUUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size
{
	//NSLog(@"%s %@ %i %@", __FUNCTION__, UUID, int(page), NSStringFromCGSize(size));

	const size_t w = size.width; const size_t h = size.height; // No fractional sizes

	NSString *name = [NSString stringWithFormat:@"%07lu-%05lu-%05lu.png", size_t(page), w, h];

	NSURL *url = [thumbCacheURL URLByAppendingPathComponent:[UUID UUIDString] isDirectory:YES];

	return [url URLByAppendingPathComponent:name isDirectory:NO];
}

- (nonnull NSString *)keyForUUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size
{
	//NSLog(@"%s %@ %i %@", __FUNCTION__, UUID, int(page), NSStringFromCGSize(size));

	const size_t w = size.width; const size_t h = size.height; NSString *it = [UUID UUIDString];

	return [NSString stringWithFormat:@"%@:%07lu-%05lu-%05lu", it, size_t(page), w, h];
}

- (nullable UIImage *)loadThumbForUUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size
{
	//NSLog(@"%s %@ %i %@", __FUNCTION__, UUID, int(page), NSStringFromCGSize(size));

	NSString *key = [self keyForUUID:UUID page:page size:size];

	UIImage *thumb = [thumbCache objectForKey:key];

	if (thumb == nil) // Try to load thumb from storage
	{
		NSURL *url = [self urlForUUID:UUID page:page size:size];

		if (CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil))
		{
			if (CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, nil))
			{
				UIImage *png = [UIImage imageWithCGImage:image]; CGImageRelease(image);

				UIGraphicsBeginImageContextWithOptions([png size], YES, 1.0); [png drawAtPoint:CGPointZero];

				thumb = UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext();

				const NSUInteger cost = (size.width * size.height * thumb.scale * 4.0);

				if (thumb != nil) [thumbCache setObject:thumb forKey:key cost:cost];
			}

			CFRelease(source);
		}
	}

	return thumb;
}

- (void)saveThumb:(nonnull UIImage *)thumb UUID:(nonnull NSUUID *)UUID page:(NSUInteger)page size:(CGSize)size
{
	//NSLog(@"%s %@ %@ %i %@", __FUNCTION__, thumb, UUID, int(page), NSStringFromCGSize(size));

	const NSUInteger cost = (size.width * size.height * thumb.scale * 4.0);

	[thumbCache setObject:thumb forKey:[self keyForUUID:UUID page:page size:size] cost:cost];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
	^{
		[self createDirectoryForUUID:UUID]; NSURL *url = [self urlForUUID:UUID page:page size:size];

		if (CGImageDestinationRef target = CGImageDestinationCreateWithURL((__bridge CFURLRef)url, CFStringRef(@"public.png"), 1, nil))
		{
			CGImageDestinationAddImage(target, [thumb CGImage], nil); CGImageDestinationFinalize(target); CFRelease(target);
		}
	});
}

- (void)purgeDiskThumbCache:(NSTimeInterval)age
{
	//NSLog(@"%s %g", __FUNCTION__, age);

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
	^{
		NSDate *now = [NSDate date]; NSArray<NSURLResourceKey> *keys = @[NSURLCreationDateKey];

		NSArray<NSURL *> *URLs = [self->fileManager contentsOfDirectoryAtURL:self->thumbCacheURL includingPropertiesForKeys:keys options:0 error:nil];

		[URLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger index, BOOL *stop)
		{
			__autoreleasing NSDate *date = nil; __autoreleasing NSError *error = nil;

			if ([URL getResourceValue:&date forKey:NSURLCreationDateKey error:&error])
			{
				const NSTimeInterval seconds = [now timeIntervalSinceDate:date];

				if (seconds > age) [self->fileManager removeItemAtURL:URL error:&error];
			}
		}];
	});
}

- (void)purgeMemoryThumbCache
{
	//NSLog(@"%s", __FUNCTION__);

	[thumbCache removeAllObjects];
}

@end

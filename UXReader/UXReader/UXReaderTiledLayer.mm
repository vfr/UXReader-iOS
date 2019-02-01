//
//	UXReaderTiledLayer.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderTiledLayer.h"

@implementation UXReaderTiledLayer

#pragma mark - Constants

constexpr size_t levelsOfDetail = 4;

#pragma mark - UXReaderTiledLayer class methods

+ (CGFloat)minimumZoom
{
	//NSLog(@"%s", __FUNCTION__);

	return 0.5;
}

+ (CGFloat)maximumZoom
{
	//NSLog(@"%s", __FUNCTION__);

	return levelsOfDetail;
}

+ (CFTimeInterval)fadeDuration
{
	//NSLog(@"%s", __FUNCTION__);

	return 0.001; // iOS bug (blank tiles) workaround
}

#pragma mark - UXReaderTiledLayer instance methods

- (instancetype)init
{
	//NSLog(@"%s", __FUNCTION__);

	if ((self = [super init])) // Initialize superclass
	{
		self.levelsOfDetail = levelsOfDetail; // See below

		self.levelsOfDetailBias = (levelsOfDetail - 1);

		self.tileSize = CGSizeMake(1024.0, 1024.0);
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

@end

//
//	CATiledLayer levelsOfDetail
//
//	To provide multiple levels of content, you need to set the levelsOfDetail property.
//	For this sample, we have 5 levels of detail (1/4x - 4x).
//	By setting the value to 5, we establish that we have levels of 1/16x - 1x (2^-4 - 2^0)
//	we use the levelsOfDetailBias property we shift this up by 2 raised to the power
//	of the bias, changing the range to 1/4-4x (2^-2 - 2^2).
//
//	exampleCATiledLayer.levelsOfDetail = 5;
//	exampleCATiledLayer.levelsOfDetailBias = 2;
//
//	The base level of detail is a zoom level of 2^0 (1 level of detail
//	only allows for a single representation like that). Each additional
//	level of detail is a zoom level half that size smaller (thus a 2nd
//	level if 2^-1x or 1/2x, then 2^-2x or 1/4x, etc). The bias adds to the
//	base level's exponent, thus a bias of 2 means the base level if 2^2x
//	(4x) zoom instead of 2^0x zoom.
//
//	There are no powers of 4, (or 5 or any other except for 2). The level
//	of detail is range of the exponent, not the base.
//

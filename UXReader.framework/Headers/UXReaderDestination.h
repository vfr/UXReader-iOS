//
//	UXReaderDestination.h
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct UXReaderDestinationTarget
{
	BOOL hasX, hasY, hasZoom; CGFloat pageX, pageY, zoom;

}	UXReaderDestinationTarget;

@interface UXReaderDestination : NSObject <NSObject>

- (nullable instancetype)initWithPage:(NSUInteger)page target:(UXReaderDestinationTarget)target;

- (NSUInteger)page;

- (UXReaderDestinationTarget)target;

@end

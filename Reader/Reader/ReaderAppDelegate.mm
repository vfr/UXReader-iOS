//
//	ReaderAppDelegate.mm
//	Reader v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "ReaderAppDelegate.h"
#import "ReaderViewController.h"
#import "ReaderSplitController.h"

@implementation ReaderAppDelegate
{
	UIWindow *mainWindow;
}

#pragma mark - ReaderAppDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//NSLog(@"%s %@", __FUNCTION__, launchOptions);

	const CGRect bounds = [[UIScreen mainScreen] bounds];

	mainWindow = [[UIWindow alloc] initWithFrame:bounds];

	mainWindow.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];

	mainWindow.rootViewController = [[ReaderViewController alloc] init];

	[mainWindow makeKeyAndVisible];

	return YES;
}

/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//NSLog(@"%s %@", __FUNCTION__, launchOptions);

	const CGRect bounds = [[UIScreen mainScreen] bounds];

	mainWindow = [[UIWindow alloc] initWithFrame:bounds];

	mainWindow.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];

	mainWindow.rootViewController = [[ReaderSplitController alloc] init];

	[mainWindow makeKeyAndVisible];

	return YES;
}
*/

/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//NSLog(@"%s %@", __FUNCTION__, launchOptions);

	const CGRect bounds = [[UIScreen mainScreen] bounds];

	mainWindow = [[UIWindow alloc] initWithFrame:bounds];

	mainWindow.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];

	ReaderViewController *readerViewController = [[ReaderViewController alloc] init];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:readerViewController];

	mainWindow.rootViewController = navigationController;

	[mainWindow makeKeyAndVisible];

	return YES;
}
*/

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	//NSLog(@"%s '%@'", __FUNCTION__, url);

	return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	//NSLog(@"%s", __FUNCTION__);

	// Sent when the application is about to move from active to inactive state. This can occur for certain types of
	// temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
	// and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers,
	// and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	//NSLog(@"%s", __FUNCTION__);

	// Use this method to release shared resources, save user data, invalidate timers, and store enough application
	// state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate:
	// when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	//NSLog(@"%s", __FUNCTION__);

	// Called as part of the transition from the background to the active state; here you can
	// undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	//NSLog(@"%s", __FUNCTION__);

	// Restart any tasks that were paused (or not yet started) while the application was inactive.
	// If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	//NSLog(@"%s", __FUNCTION__);

	// Called when the application is about to terminate. Save data if appropriate.
	// See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	//NSLog(@"%s", __FUNCTION__);

	// Free up as much memory as possible by purging cached data objects that can be
	// recreated (or reloaded from disk) later.
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
	//NSLog(@"%s", __FUNCTION__);
}

@end

//
//	ReaderSplitController.mm
//	Reader v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "ReaderSplitController.h"
#import "ReaderViewController.h"

#import <UXReader/UXReader.h>

@interface ReaderSplitController () <UISplitViewControllerDelegate, ReaderViewControllerDelegate, UXReaderViewControllerDelegate>

@end

@implementation ReaderSplitController
{
	ReaderViewController *readerViewController;

	UXReaderViewController *documentViewController;
}

#pragma mark - UIViewController instance methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	//NSLog(@"%s %@ %@", __FUNCTION__, nibNameOrNil, nibBundleOrNil);

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) // Initialize superclass
	{
		readerViewController = [[ReaderViewController alloc] init]; [readerViewController setDelegate:self];

		documentViewController = [[UXReaderViewController alloc] init]; [documentViewController setDelegate:self];

		[self setViewControllers:@[readerViewController, documentViewController]]; // View controllers

		[self setPreferredDisplayMode:UISplitViewControllerDisplayModePrimaryOverlay];
	}

	return self;
}

/*
- (void)loadView
{
	NSLog(@"%s", __FUNCTION__);

	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}
*/

- (void)viewDidLoad
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	//NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	//NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	//NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	//NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));

	[super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));

	[super viewDidLayoutSubviews];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
	//NSLog(@"%s %@", __FUNCTION__, parent);

	[super willMoveToParentViewController:parent];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
	//NSLog(@"%s %@", __FUNCTION__, parent);

	[super didMoveToParentViewController:parent];
}

- (BOOL)prefersStatusBarHidden
{
	//NSLog(@"%s", __FUNCTION__);

	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	//NSLog(@"%s", __FUNCTION__);

	return UIStatusBarStyleDefault;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	//NSLog(@"%s", __FUNCTION__);

	return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
	//NSLog(@"%s", __FUNCTION__);

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

#pragma mark - ReaderViewControllerDelegate methods

- (void)readerViewController:(nonnull ReaderViewController *)viewController showDocument:(nonnull UXReaderDocument *)document
{
	//NSLog(@"%s %@ %@", __FUNCTION__, viewController, document);

	[self setPreferredDisplayMode:UISplitViewControllerDisplayModePrimaryOverlay];

	[documentViewController setDocument:document];
}

#pragma mark - UXReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(UXReaderViewController *)viewController
{
	//NSLog(@"%s %@", __FUNCTION__, viewController);

	[self setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
}

#pragma mark - UISplitViewControllerDelegate methods

@end

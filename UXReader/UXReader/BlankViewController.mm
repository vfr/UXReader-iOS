//
//	BlankViewController.mm
//	UXReader Framework v1.0
//
//	Created by Julius Oklamcak on 2017-01-01.
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "BlankViewController.h"

@interface BlankViewController ()

@end

@implementation BlankViewController
{
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIViewController instance methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"%s %@ %@", __FUNCTION__, nibNameOrNil, nibBundleOrNil);

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) // Initialize superclass
	{
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
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));

	[super viewDidLoad];

	self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	NSLog(@"%s %@ %i", __FUNCTION__, NSStringFromCGRect(self.view.bounds), animated);

	[super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));

	[super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));

	[super viewDidLayoutSubviews];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
	NSLog(@"%s %@", __FUNCTION__, parent);

	[super willMoveToParentViewController:parent];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
	NSLog(@"%s %@", __FUNCTION__, parent);

	[super didMoveToParentViewController:parent];
}

- (BOOL)prefersStatusBarHidden
{
	NSLog(@"%s", __FUNCTION__);

	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	NSLog(@"%s", __FUNCTION__);

	return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	NSLog(@"%s", __FUNCTION__);

	return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"%s", __FUNCTION__);

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	NSLog(@"%s", __FUNCTION__);
}

#pragma mark - BlankViewController instance methods

@end

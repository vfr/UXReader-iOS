//
//	UXReaderViewController.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderDocumentPage.h"
#import "UXReaderViewController.h"
#import "UXReaderStuffController.h"
#import "UXReaderMainScrollView.h"
#import "UXReaderPageScrollView.h"
#import "UXReaderSearchControl.h"
#import "UXReaderMainToolbar.h"
#import "UXReaderPageToolbar.h"
#import "UXReaderThumbCache.h"
#import "UXReaderFramework.h"
#import "UXReaderSelection.h"
#import "UXReaderDestination.h"
#import "UXReaderAction.h"

@interface UXReaderViewController () <UXReaderMainToolbarDelegate, UXReaderPageToolbarDelegate, UXReaderPageScrollViewDelegate,
									UXReaderDocumentSearchDelegate, UXReaderSearchControlDelegate, UXReaderStuffControllerDelegate,
									UIScrollViewDelegate, UIGestureRecognizerDelegate>
@end

@implementation UXReaderViewController
{
	UXReaderDocument *document;

	UXReaderMainToolbar *mainToolbar;

	UXReaderPageToolbar *pageToolbar;

	UXReaderMainScrollView *mainScrollView;

	NSUInteger pageCount, maximumPage, maximumKey;

	NSMutableDictionary<NSNumber *, UXReaderPageScrollView *> *contentViews;

	NSUInteger defaultPage, currentPage, currentKey, currentWhat;

	CGFloat scrollViewOutset, sideTapAreaSize;

	UIActivityIndicatorView *busyIndicator;

	UXReaderDisplayMode displayMode;

	UXReaderPermissions permissions;

	NSDate *lastToolbarHideTime;

	UXReaderSearchControl *searchControl;

	NSMutableArray<UXReaderSelection *> *allSearchSelections;

	NSMutableDictionary<NSNumber *, NSArray<UXReaderSelection *> *> *pageSearchSelections;

	__weak UXReaderSelection *currentSearchHighlight;

	__weak UXReaderSelection *currentActiveHighlight;

	NSString *searchText; NSString *lastSearch;

	UXReaderSearchOptions searchMatch;

	NSTimer *searchTimer;

	BOOL initialStatusBarState;
	BOOL currentStatusBarState;

	BOOL showRTL;
}

#pragma mark - Constants

constexpr NSInteger minimumKey = 0;

constexpr NSUInteger minimumPage = 0;

constexpr CGFloat minimumContentOffset = 0.0;

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIViewController instance methods

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	//NSLog(@"%s %@", __FUNCTION__, decoder);

	if ((self = [super initWithCoder:decoder])) // Decode superclass
	{
		[self setAutomaticallyAdjustsScrollViewInsets:NO]; [self prepare];
	}

	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	//NSLog(@"%s %@ %@", __FUNCTION__, nibNameOrNil, nibBundleOrNil);

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		[self setAutomaticallyAdjustsScrollViewInsets:NO]; [self prepare];
	}

	return self;
}

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if ((self = [self initWithNibName:nil bundle:nil])) // Initialize self
	{
		if (documentx != nil) document = documentx; else self = nil;
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

	[super viewDidLoad]; UIView *view = [self view];

	[view setBackgroundColor:[UXReaderFramework scrollViewBackgroundColor]];

	[self addMainToolbar:view]; //[self addBusyIndicator:view];
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

	[self presentDocument:nil];
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

	[self handleSizeChange];
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

	return currentStatusBarState;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	//NSLog(@"%s", __FUNCTION__);

	return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	//NSLog(@"%s", __FUNCTION__);

	return UIStatusBarAnimationSlide;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	//NSLog(@"%s", __FUNCTION__);

	return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"%s", __FUNCTION__);

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

#pragma mark - UXReaderViewController instance methods

- (nonnull UXReaderDocument *)document
{
	//NSLog(@"%s", __FUNCTION__);

	return document;
}

- (void)setDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if (documentx != document) // Show new UXReaderDocument
	{
		if (document != nil) [self teardown]; [self presentNew:documentx];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangeDocument:)])
		{
			[delegate readerViewController:self didChangeDocument:document];
		}
	}
}

- (BOOL)hasDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	return [document isSameDocument:documentx];
}

- (void)setPermissions:(UXReaderPermissions)permissionsx
{
	//NSLog(@"%s %i", __FUNCTION__, int(permissionsx));

	permissions = permissionsx;
}

- (UXReaderPermissions)permissions
{
	//NSLog(@"%s", __FUNCTION__);

	return permissions;
}

- (void)setDisplayMode:(UXReaderDisplayMode)mode
{
	//NSLog(@"%s %i", __FUNCTION__, int(mode));

	if (pageCount == 1) mode = UXReaderDisplayModeSinglePageScrollH;

	if (mode != displayMode)
	{
		displayMode = mode; // Update mode

		if (([document isOpen] == YES) && (mainScrollView != nil))
		{
			switch (displayMode) // UXReaderDisplayMode
			{
				case UXReaderDisplayModeSinglePageScrollH: { [self changeModeSinglePageScrollH]; break; }
				case UXReaderDisplayModeSinglePageScrollV: { [self changeModeSinglePageScrollV]; break; }
				case UXReaderDisplayModeDoublePageScrollH: { [self changeModeDoublePageScrollH]; break; }
				case UXReaderDisplayModeDoublePageScrollV: { [self changeModeDoublePageScrollV]; break; }
			}
		}

		if ([delegate respondsToSelector:@selector(readerViewController:didChangeMode:)])
		{
			[delegate readerViewController:self didChangeMode:displayMode];
		}
	}
}

- (UXReaderDisplayMode)displayMode
{
	//NSLog(@"%s", __FUNCTION__);

	return displayMode;
}

- (void)setDefaultPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	defaultPage = page;
}

- (void)presentDocument:(nullable NSString *)password
{
	//NSLog(@"%s", __FUNCTION__);

	if ((document != nil) && ([document isOpen] == NO))
	{
		[document openWithPassword:password completion:^(NSError *error)
		{
			if (error == nil)
				[self populateViewController:[self view]];
			else
				[self handleDocumentError:error];
		}];
	}
}

- (void)populateViewController:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	[busyIndicator removeFromSuperview]; busyIndicator = nil;

	[self addMainPagebar:view]; [mainToolbar setEnabled:YES]; // Enable

	if ((searchControl = [[UXReaderSearchControl alloc] initWithView:view]))
	{
		[searchControl setDelegate:self]; // UXReaderSearchControlDelegate
	}

	UITapGestureRecognizer *singleTapOneTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOneTouch.numberOfTapsRequired = 1; singleTapOneTouch.numberOfTouchesRequired = 1; singleTapOneTouch.delegate = self;
	[view addGestureRecognizer:singleTapOneTouch];

	UITapGestureRecognizer *singleTapTwoTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapTwoTouch.numberOfTapsRequired = 1; singleTapTwoTouch.numberOfTouchesRequired = 2; singleTapTwoTouch.delegate = self;
	[view addGestureRecognizer:singleTapTwoTouch];

	UITapGestureRecognizer *doubleTapOneTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOneTouch.numberOfTapsRequired = 2; doubleTapOneTouch.numberOfTouchesRequired = 1; doubleTapOneTouch.delegate = self;
	[view addGestureRecognizer:doubleTapOneTouch];

	UITapGestureRecognizer *doubleTapTwoTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwoTouch.numberOfTapsRequired = 2; doubleTapTwoTouch.numberOfTouchesRequired = 2; doubleTapTwoTouch.delegate = self;
	[view addGestureRecognizer:doubleTapTwoTouch];

	[singleTapOneTouch requireGestureRecognizerToFail:doubleTapOneTouch];
	[singleTapTwoTouch requireGestureRecognizerToFail:doubleTapTwoTouch];

	contentViews = [[NSMutableDictionary alloc] init]; lastToolbarHideTime = [NSDate date];

	showRTL = [document showRTL]; pageCount = [document pageCount]; maximumPage = (pageCount - 1);

	if (pageCount == 1) displayMode = UXReaderDisplayModeSinglePageScrollH; [self setupDisplayMode];

	if (defaultPage > maximumPage) defaultPage = maximumPage; [self gotoPage:defaultPage];
}

- (void)addMainToolbar:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (mainToolbar == nil) // Create UXReaderMainToolbar
	{
		if ((mainToolbar = [[UXReaderMainToolbar alloc] initWithDocument:document]))
		{
			[view addSubview:mainToolbar]; [mainToolbar setDelegate:self]; // UXReaderMainToolbarDelegate

            [mainToolbar setAllowShare:(permissions & UXReaderPermissionAllowShare)]; // Set share button state
			[mainToolbar setAllowClose:(permissions & UXReaderPermissionAllowClose)]; // Set close button state

			[view addConstraint:[NSLayoutConstraint constraintWithItem:mainToolbar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:mainToolbar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

			NSLayoutConstraint *y = [NSLayoutConstraint constraintWithItem:mainToolbar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
																	toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];

			[view addConstraint:y]; [mainToolbar setLayoutConstraintY:y];
		}
	}
}

- (void)addMainPagebar:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (pageToolbar == nil) // Create UXReaderPageToolbar
	{
		if ((pageToolbar = [[UXReaderPageToolbar alloc] initWithDocument:document]))
		{
			[view addSubview:pageToolbar]; [pageToolbar setDelegate:self]; // UXReaderPageToolbarDelegate

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageToolbar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageToolbar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

			NSLayoutConstraint *y = [NSLayoutConstraint constraintWithItem:pageToolbar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
																	toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];

			[view addConstraint:y]; [pageToolbar setLayoutConstraintY:y];
		}
	}
}

- (void)addBusyIndicator:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (busyIndicator == nil) // Create UIActivityIndicatorView
	{
		if ((busyIndicator = [[UIActivityIndicatorView alloc] init]))
		{
			[busyIndicator setTranslatesAutoresizingMaskIntoConstraints:NO]; [busyIndicator startAnimating];
			[view addSubview:busyIndicator]; //[busyControl setBackgroundColor:[UIColor lightGrayColor]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:busyIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:busyIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
		}
	}
}

- (void)handleDocumentError:(nonnull NSError *)error
{
	//NSLog(@"%s %@", __FUNCTION__, error);

	__weak UXReaderViewController *weakSelf = self;

	NSBundle *bundle = [NSBundle bundleForClass:[self class]];

	if (error.code == UXReaderDocumentErrorPassword) // Password alert
	{
		NSString *close = [bundle localizedStringForKey:@"Close" value:nil table:nil];
		NSString *retry = [bundle localizedStringForKey:@"Retry" value:nil table:nil];

		NSString *title = [bundle localizedStringForKey:@"Document Password" value:nil table:nil];
		NSString *place = [bundle localizedStringForKey:@"Enter document password" value:nil table:nil];

		UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *retryAction = [UIAlertAction actionWithTitle:retry style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
		{
			UITextField *textField = [[alert textFields] firstObject]; [weakSelf presentDocument:[textField text]];
		}];

		UIAlertAction *closeAction = [UIAlertAction actionWithTitle:close style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
		{
			[weakSelf closeDocument];
		}];

		[alert addAction:closeAction]; [alert addAction:retryAction]; [alert setPreferredAction:retryAction];

		[alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
		{
			textField.secureTextEntry = YES; textField.textAlignment = NSTextAlignmentCenter; textField.placeholder = place;
		}];

		[self presentViewController:alert animated:YES completion:nil];
	}
	else // Document error alert
	{
		NSString *text = [error localizedDescription];

		NSString *close = [bundle localizedStringForKey:@"Close" value:nil table:nil];

		NSString *title = [bundle localizedStringForKey:@"Document Open Error" value:nil table:nil];

		UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *closeAction = [UIAlertAction actionWithTitle:close style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
		{
			[weakSelf closeDocument];
		}];

		[alert addAction:closeAction]; [alert setPreferredAction:closeAction];

		[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)closeDocument
{
	//NSLog(@"%s", __FUNCTION__);

	[self teardown];

	[UXReaderFramework saveDefaults];

	[UXReaderThumbCache purgeMemoryThumbCache];

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)])
	{
		[delegate dismissReaderViewController:self];
	}
	else // Log not implemented error
	{
		NSLog(@"-dismissReaderViewController: not implemented");
	}
}

- (void)handleTapAction:(nonnull UXReaderAction *)action
{
	//NSLog(@"%s %@", __FUNCTION__, action);

	if ([action type] == UXReaderActionTypeURI)
	{
		if (NSURL *URL = [NSURL URLWithString:[action URI]])
		{
			UIApplication *application = [UIApplication sharedApplication];

			if ([application canOpenURL:URL]) [application openURL:URL];
		}
		else // Log URI error
		{
			NSLog(@"%s Invalid URI: '%@'", __FUNCTION__, [action URI]);
		}
	}
	else if ([action type] == UXReaderActionTypeLink)
	{
		if (NSURL *URL = [NSURL URLWithString:[action URI]])
		{
			UIApplication *application = [UIApplication sharedApplication];

			if ([application canOpenURL:URL]) [application openURL:URL];
		}
		else // Log URI error
		{
			NSLog(@"%s Invalid URI: '%@'", __FUNCTION__, [action URI]);
		}
	}
	else if ([action type] == UXReaderActionTypeGoto)
	{
		[self gotoPage:[[action destination] page]];
	}
	else // Log not handled error
	{
		NSLog(@"%s Not handled: %@ '%@'", __FUNCTION__, action, [action path]);
	}
}

- (void)presentStuffUserInterface:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (UXReaderStuffController *stuffController = [[UXReaderStuffController alloc] init])
	{
		[stuffController setDelegate:self]; [stuffController setDocument:document];

		[self addChildViewController:stuffController];

		stuffController.view.frame = self.view.bounds;

		[self.view addSubview:[stuffController view]];

		[stuffController didMoveToParentViewController:self];
	}
}

- (void)presentShareUserInterface:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if ((permissions & UXReaderPermissionAllowShare) == NO) return;

	id item = nil; NSURL *URL = [document URL]; NSData *data = [document data];

	if (URL != nil) item = URL; else if (data != nil) item = data; else return; // Only NSURL or NSData

	if (UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:nil])
	{
		activityController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *error) { };

		activityController.excludedActivityTypes = [self excludedActivities]; activityController.modalPresentationStyle = UIModalPresentationPopover;

		[self presentViewController:activityController animated:YES completion:nil];

		UIPopoverPresentationController *presentationController = [activityController popoverPresentationController];

		presentationController.sourceView = view; presentationController.sourceRect = CGRectInset(view.bounds, 10.0, 10.0);

		presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
	}
}

- (nullable NSArray<UIActivityType> *)excludedActivities
{
	//NSLog(@"%s", __FUNCTION__);

	static NSArray<UIActivityType> *at1 = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo,
											UIActivityTypePostToTencentWeibo, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo,
											UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];

	static NSArray<UIActivityType> *at2 = @[UIActivityTypeMessage, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks];

	NSMutableArray<UIActivityType> *exclude = [[NSMutableArray alloc] initWithArray:at1];

	if (!(permissions & UXReaderPermissionAllowPrint)) [exclude addObject:UIActivityTypePrint];

	if (!(permissions & UXReaderPermissionAllowEmail)) [exclude addObject:UIActivityTypeMail];

	if (!(permissions & UXReaderPermissionAllowSave)) [exclude addObjectsFromArray:at2];

	return [exclude copy];
}

- (void)setStatusBarHidden:(BOOL)hidden
{
	//NSLog(@"%s %i", __FUNCTION__, hidden);

	if (!initialStatusBarState) // Update status bar state
	{
		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void)
		{
			currentStatusBarState = hidden; [self setNeedsStatusBarAppearanceUpdate];
		}
		completion:^(BOOL finished)
		{
		}];
	}
}

- (void)presentNew:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if ((document = documentx) && ([self viewIfLoaded] != nil))
	{
		[self addMainToolbar:[self view]]; [self presentDocument:nil];
	}
}

- (void)prepare
{
	//NSLog(@"%s", __FUNCTION__);

	NSMutableDictionary<NSString *, id> *defaults = [UXReaderFramework defaults];

	currentWhat = NSUInteger([[defaults objectForKey:@"CurrentWhat"] unsignedIntegerValue]);

	searchMatch = UXReaderSearchOptions([[defaults objectForKey:@"SearchMatch"] unsignedIntegerValue]);

	initialStatusBarState = ([UXReaderFramework statusBarHeight] == 0.0); currentStatusBarState = initialStatusBarState;

	currentPage = NSUIntegerMax; currentKey = NSUIntegerMax; maximumKey = NSUIntegerMax; maximumPage = minimumPage;

	permissions = UXReaderPermissionAllowAll; displayMode = UXReaderDisplayModeSinglePageScrollH;

	scrollViewOutset = 8.0; sideTapAreaSize = ([UXReaderFramework isSmallDevice] ? 56.0 : 64.0);
}

- (void)teardown
{
	//NSLog(@"%s", __FUNCTION__);

	[self clearSearch]; [self removeAllContentViews];

	[searchControl removeControls]; searchControl = nil;

	[pageToolbar removeFromSuperview]; pageToolbar = nil;

	[mainToolbar removeFromSuperview]; mainToolbar = nil;

	[mainScrollView removeFromSuperview]; mainScrollView = nil;

	lastToolbarHideTime = nil; pageCount = 0; defaultPage = 0;

	currentPage = NSUIntegerMax; currentKey = NSUIntegerMax;

	maximumKey = NSUIntegerMax; maximumPage = minimumPage;

	[[self view] setGestureRecognizers:nil];

	[document close]; document = nil;
}

#pragma mark - UXReaderMainToolbarDelegate

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar closeButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, button);

	[self closeDocument];
}

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar shareButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, button);

	[self stopActiveSearch]; [self presentShareUserInterface:button];
}

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar stuffButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, button);

	[self stopActiveSearch]; [self presentStuffUserInterface:button];
}

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar searchButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, button);

	[self stopActiveSearch];
}

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar searchTextDidChange:(nonnull NSString *)text
{
	//NSLog(@"%s %@ '%@'", __FUNCTION__, toolbar, text);

	[self newSearchText:text];
}

- (void)mainToolbar:(nonnull UXReaderMainToolbar *)toolbar beginSearching:(nonnull NSString *)text
{
	//NSLog(@"%s %@ '%@'", __FUNCTION__, toolbar, text);

	[self beginTextSearch:text];
}

#pragma mark - UXReaderPageToolbarDelegate

- (void)pageToolbar:(nonnull UXReaderPageToolbar *)toolbar gotoPage:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, toolbar, int(page));

	[self gotoPage:page];
}

#pragma mark - UXReaderPageScrollViewDelegate methods

- (void)pageScrollView:(UXReaderPageScrollView *)view touchesBegan:(NSSet *)touches
{
	//NSLog(@"%s %@ %@", __FUNCTION__, view, touches);

	if ([mainToolbar isVisible] || [pageToolbar isVisible])
	{
		if (touches.count == 1) // Single finger touches only
		{
			UITouch *touch = [touches anyObject]; // Touch object

			const CGPoint point = [touch locationInView:[self view]];

			const CGRect areaRect = CGRectInset(self.view.bounds, sideTapAreaSize, 0.0);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		lastToolbarHideTime = [NSDate date]; [self setStatusBarHidden:YES];

		[mainToolbar hideAnimated]; [pageToolbar hideAnimated];
	}
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//NSLog(@"%s %@", __FUNCTION__, scrollView);

	[self layoutContentViews];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	//NSLog(@"%s %@", __FUNCTION__, scrollView);

	[self handleScrollViewDidEnd];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	//NSLog(@"%s %@", __FUNCTION__, scrollView);

	[self handleScrollViewDidEnd];
}

#pragma mark - UIGestureRecognizer methods

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	//NSLog(@"%s %@", __FUNCTION__, recognizer);

	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		if (recognizer.numberOfTouches == 1) // Handle one touch
		{
			CGRect viewRect = recognizer.view.bounds; // View bounds

			const CGPoint point = [recognizer locationInView:recognizer.view];

			const CGRect areaRect = CGRectInset(viewRect, sideTapAreaSize, 0.0);

			if (CGRectContainsPoint(areaRect, point) == true) // Single tap in area
			{
				UXReaderPageScrollView *targetView = contentViews[@(currentKey)];

				UXReaderAction *action = [targetView processSingleTap:recognizer];

				if (action == nil) // Nothing active tapped in the target content view
				{
					if ([lastToolbarHideTime timeIntervalSinceNow] < -1.0) // Delay
					{
						if (![mainToolbar isVisible] || ![pageToolbar isVisible])
						{
							[mainToolbar showAnimated]; [pageToolbar showAnimated];

							[self setStatusBarHidden:NO];
						}
					}
				}
				else // Handle returned action
				{
					[self handleTapAction:action];
				}

				return;
			}

			CGRect nextPageRect = viewRect;
			nextPageRect.size.width = sideTapAreaSize;
			nextPageRect.origin.x = (viewRect.size.width - sideTapAreaSize);

			if (CGRectContainsPoint(nextPageRect, point) == true) // page++
			{
				[self incrementPage]; return;
			}

			CGRect prevPageRect = viewRect;
			prevPageRect.size.width = sideTapAreaSize;

			if (CGRectContainsPoint(prevPageRect, point) == true) // page--
			{
				[self decrementPage]; return;
			}
		}
		else if (recognizer.numberOfTouches == 2) // Handle two touches
		{
			UXReaderPageScrollView *targetView = contentViews[@(currentKey)];

			[targetView resetZoom];
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	//NSLog(@"%s %@", __FUNCTION__, recognizer);

	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		const CGRect viewRect = recognizer.view.bounds; // View bounds

		const CGPoint point = [recognizer locationInView:recognizer.view];

		const CGRect zoomArea = CGRectInset(viewRect, sideTapAreaSize, 0.0);

		if (CGRectContainsPoint(zoomArea, point) == true) // Double tap in area
		{
			UXReaderPageScrollView *targetView = contentViews[@(currentKey)];

			switch (recognizer.numberOfTouches) // Touches count
			{
				case 1: // One finger double tap: zoom++
				{
					[targetView zoomIncrement:recognizer]; break;
				}

				case 2: // Two finger double tap: zoom--
				{
					[targetView zoomDecrement:recognizer]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = sideTapAreaSize;
		nextPageRect.origin.x = (viewRect.size.width - sideTapAreaSize);

		if (CGRectContainsPoint(nextPageRect, point) == true) // page++
		{
			[self incrementPage]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = sideTapAreaSize;

		if (CGRectContainsPoint(prevPageRect, point) == true) // page--
		{
			[self decrementPage]; return;
		}
	}
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	//NSLog(@"%s %@ %@", __FUNCTION__, recognizer, touch);

	return [[touch view] isKindOfClass:[UXReaderPageScrollView class]];
}

#pragma mark - UXReaderDisplayMode methods

- (void)setupDisplayMode
{
	//NSLog(@"%s", __FUNCTION__);

	switch (displayMode) // UXReaderDisplayMode
	{
		case UXReaderDisplayModeSinglePageScrollH: { [self setupDisplayModeSinglePageScrollH]; break; }
		case UXReaderDisplayModeSinglePageScrollV: { [self setupDisplayModeSinglePageScrollV]; break; }
		case UXReaderDisplayModeDoublePageScrollH: { [self setupDisplayModeDoublePageScrollH]; break; }
		case UXReaderDisplayModeDoublePageScrollV: { [self setupDisplayModeDoublePageScrollV]; break; }
	}
}

- (void)handleSizeChange
{
	//NSLog(@"%s", __FUNCTION__);

	switch (displayMode) // UXReaderDisplayMode
	{
		case UXReaderDisplayModeSinglePageScrollH: { [self handleSizeChangeSinglePageScrollH]; break; }
		case UXReaderDisplayModeSinglePageScrollV: { [self handleSizeChangeSinglePageScrollV]; break; }
		case UXReaderDisplayModeDoublePageScrollH: { [self handleSizeChangeDoublePageScrollH]; break; }
		case UXReaderDisplayModeDoublePageScrollV: { [self handleSizeChangeDoublePageScrollV]; break; }
	}
}

- (void)layoutContentViews
{
	//NSLog(@"%s", __FUNCTION__);

	switch (displayMode) // UXReaderDisplayMode
	{
		case UXReaderDisplayModeSinglePageScrollH: { [self layoutContentViewsSinglePageScrollH]; break; }
		case UXReaderDisplayModeSinglePageScrollV: { [self layoutContentViewsSinglePageScrollV]; break; }
		case UXReaderDisplayModeDoublePageScrollH: { [self layoutContentViewsDoublePageScrollH]; break; }
		case UXReaderDisplayModeDoublePageScrollV: { [self layoutContentViewsDoublePageScrollV]; break; }
	}
}

- (void)handleScrollViewDidEnd
{
	//NSLog(@"%s", __FUNCTION__);

	switch (displayMode) // UXReaderDisplayMode
	{
		case UXReaderDisplayModeSinglePageScrollH: { [self handleScrollViewDidEndSinglePageScrollH]; break; }
		case UXReaderDisplayModeSinglePageScrollV: { [self handleScrollViewDidEndSinglePageScrollV]; break; }
		case UXReaderDisplayModeDoublePageScrollH: { [self handleScrollViewDidEndDoublePageScrollH]; break; }
		case UXReaderDisplayModeDoublePageScrollV: { [self handleScrollViewDidEndDoublePageScrollV]; break; }
	}
}

- (void)decrementPage
{
	//NSLog(@"%s", __FUNCTION__);

	switch (displayMode) // UXReaderDisplayMode
	{
		case UXReaderDisplayModeSinglePageScrollH: { [self decrementPageSinglePageScrollH]; break; }
		case UXReaderDisplayModeSinglePageScrollV: { [self decrementPageSinglePageScrollV]; break; }
		case UXReaderDisplayModeDoublePageScrollH: { [self decrementPageDoublePageScrollH]; break; }
		case UXReaderDisplayModeDoublePageScrollV: { [self decrementPageDoublePageScrollV]; break; }
	}
}

- (void)incrementPage
{
	//NSLog(@"%s", __FUNCTION__);

	switch (displayMode) // UXReaderDisplayMode
	{
		case UXReaderDisplayModeSinglePageScrollH: { [self incrementPageSinglePageScrollH]; break; }
		case UXReaderDisplayModeSinglePageScrollV: { [self incrementPageSinglePageScrollV]; break; }
		case UXReaderDisplayModeDoublePageScrollH: { [self incrementPageDoublePageScrollH]; break; }
		case UXReaderDisplayModeDoublePageScrollV: { [self incrementPageDoublePageScrollV]; break; }
	}
}

- (void)gotoPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	switch (displayMode) // UXReaderDisplayMode
	{
		case UXReaderDisplayModeSinglePageScrollH: { [self gotoPageSinglePageScrollH:page]; break; }
		case UXReaderDisplayModeSinglePageScrollV: { [self gotoPageSinglePageScrollV:page]; break; }
		case UXReaderDisplayModeDoublePageScrollH: { [self gotoPageDoublePageScrollH:page]; break; }
		case UXReaderDisplayModeDoublePageScrollV: { [self gotoPageDoublePageScrollV:page]; break; }
	}
}

- (void)removeAllContentViews
{
	//NSLog(@"%s", __FUNCTION__);

	NSArray<UXReaderPageScrollView *> *views = [contentViews allValues];

	[views makeObjectsPerformSelector:@selector(removeFromSuperview)];

	[contentViews removeAllObjects];
}

#pragma mark - UXReaderDisplayModeSinglePageScrollH methods

- (void)changeModeSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	[self removeAllContentViews]; // Brute mode change

	maximumKey = (maximumPage / 1); currentKey = NSUIntegerMax;

	[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

	[self updateContentSizeSinglePageScrollH]; [mainScrollView setContentOffset:CGPointZero];

	[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate

	[self gotoPageSinglePageScrollH:currentPage];
}

- (void)setupDisplayModeSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView == nil) // Create UXReaderMainScrollView
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, -scrollViewOutset, 0.0);

		if ((mainScrollView = [[UXReaderMainScrollView alloc] initWithFrame:scrollViewRect]))
		{
			[self.view insertSubview:mainScrollView atIndex:0]; [mainScrollView setDelegate:self];

			[self updateContentSizeSinglePageScrollH]; maximumKey = (maximumPage / 1);
		}
	}
}

- (void)handleSizeChangeSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView != nil) // Handle UIViewController size changes
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, -scrollViewOutset, 0.0);

		if (CGRectEqualToRect(mainScrollView.frame, scrollViewRect) == false)
		{
			[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

			mainScrollView.frame = scrollViewRect; // Update scroll view frame

			if (CGSizeEqualToSize(mainScrollView.contentSize, CGSizeZero) == false)
			{
				[self updateContentViewsSinglePageScrollH]; // Update view frames
			}

			[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate
		}
	}
}

- (void)updateContentViewsSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	[self updateContentSizeSinglePageScrollH]; // First update size

	[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
	{
		const NSUInteger page = [key unsignedIntegerValue]; // Page number

		CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

		const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

		viewRect.origin.x = (viewRect.size.width * flip); // Update X

		contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.0);
	}];

	const NSUInteger flip = (showRTL ? (maximumPage - currentPage) : currentPage);

	const CGPoint contentOffset = CGPointMake((mainScrollView.bounds.size.width * flip), 0.0);

	if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
	{
		mainScrollView.contentOffset = contentOffset;
	}
}

- (void)updateContentSizeSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat ch = mainScrollView.bounds.size.height; // Fixed height

	const CGFloat cw = (mainScrollView.bounds.size.width * pageCount); // Width

	const CGSize contentSize = CGSizeMake(cw, ch); // Possible new content size

	if (CGSizeEqualToSize(mainScrollView.contentSize, contentSize) == false)
	{
		mainScrollView.contentSize = contentSize;
	}
}

- (void)handleScrollViewDidEndSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewWidth = mainScrollView.bounds.size.width;

	const CGFloat contentOffsetX = mainScrollView.contentOffset.x;

	NSUInteger page = (contentOffsetX / viewWidth);

	if (showRTL == YES) page = (maximumPage - page);

	if ((page != currentPage) && (page <= maximumPage)) // Page changed
	{
		currentPage = page; currentKey = page; [pageToolbar showPageNumber:page ofPages:pageCount];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != page) [contentView wentOffScreen];
		}];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

- (void)addContentViewSinglePageScrollH:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

	CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

	viewRect.origin.x = (viewRect.size.width * flip); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0);

	if (UXReaderPageScrollView *contentView = [[UXReaderPageScrollView alloc] initWithFrame:viewRect document:document page:page])
	{
		[contentView setMessage:self]; [mainScrollView addSubview:contentView]; contentViews[@(page)] = contentView;
	}
}

- (void)layoutContentViewsSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewWidth = mainScrollView.bounds.size.width;

	const CGFloat contentOffsetX = mainScrollView.contentOffset.x;

	NSInteger pageA = (contentOffsetX / viewWidth);

	if (showRTL == YES) pageA = (maximumPage - pageA);

	NSInteger pageB = (pageA + 1); pageA -= 1; // Range

	if (pageA < NSInteger(minimumPage)) pageA = minimumPage;

	if (pageB > NSInteger(maximumPage)) pageB = maximumPage;

	const NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1));

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];

	for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
	{
		const NSUInteger page = [key unsignedIntegerValue]; // Page number

		if ([pageSet containsIndex:page] == NO) // Remove content view
		{
			UXReaderPageScrollView *contentView = contentViews[key];

			[contentView removeFromSuperview]; contentViews[key] = nil;
		}
		else // Visible content view - remove it from page set
		{
			[pageSet removeIndex:page];
		}
	}

	if ([pageSet count] > 0) // Add content views
	{
		const NSUInteger target = currentPage;

		if ([pageSet containsIndex:target] == YES)
		{
			[self addContentViewSinglePageScrollH:target];

			[pageSet removeIndex:target];
		}

		[pageSet enumerateIndexesUsingBlock:^(NSUInteger page, BOOL *stop)
		{
			[self addContentViewSinglePageScrollH:page];
		}];
	}
}

- (void)decrementPageSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.x -= mainScrollView.bounds.size.width;

	if (contentOffset.x >= minimumContentOffset) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)incrementPageSinglePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.x += mainScrollView.bounds.size.width;

	if (contentOffset.x < mainScrollView.contentSize.width) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)gotoPageSinglePageScrollH:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	BOOL visible = NO; if (page > maximumPage) return;

	if (UXReaderPageScrollView *contentView = contentViews[@(currentKey)])
	{
		visible = [contentView containsPage:page];
	}

	if (visible == NO) // Handle page is not visible
	{
		currentPage = currentKey = page; const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

		const CGPoint contentOffset = CGPointMake((mainScrollView.bounds.size.width * flip), 0.0);

		if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
			[mainScrollView setContentOffset:contentOffset];
		else
			[self layoutContentViewsSinglePageScrollH];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != page) [contentView wentOffScreen];
		}];

		[pageToolbar showPageNumber:page ofPages:pageCount];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

#pragma mark - UXReaderDisplayModeSinglePageScrollV methods

- (void)changeModeSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	[self removeAllContentViews]; // Brute mode change

	maximumKey = (maximumPage / 1); currentKey = NSUIntegerMax;

	[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

	[self updateContentSizeSinglePageScrollV]; [mainScrollView setContentOffset:CGPointZero];

	[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate

	[self gotoPageSinglePageScrollV:currentPage];
}

- (void)setupDisplayModeSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView == nil) // Create UXReaderMainScrollView
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, 0.0, -scrollViewOutset);

		if ((mainScrollView = [[UXReaderMainScrollView alloc] initWithFrame:scrollViewRect]))
		{
			[self.view insertSubview:mainScrollView atIndex:0]; [mainScrollView setDelegate:self];

			[self updateContentSizeSinglePageScrollV]; maximumKey = (maximumPage / 1);
		}
	}
}

- (void)handleSizeChangeSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView != nil) // Handle UIViewController size changes
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, 0.0, -scrollViewOutset);

		if (CGRectEqualToRect(mainScrollView.frame, scrollViewRect) == false)
		{
			[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

			mainScrollView.frame = scrollViewRect; // Update scroll view frame

			if (CGSizeEqualToSize(mainScrollView.contentSize, CGSizeZero) == false)
			{
				[self updateContentViewsSinglePageScrollV]; // Update view frames
			}

			[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate
		}
	}
}

- (void)updateContentViewsSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	[self updateContentSizeSinglePageScrollV]; // First update size

	[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
	{
		const NSUInteger page = [key unsignedIntegerValue]; // Page number

		CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

		const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

		viewRect.origin.y = (viewRect.size.height * flip); // Update Y

		contentView.frame = CGRectInset(viewRect, 0.0, scrollViewOutset);
	}];

	const NSUInteger flip = (showRTL ? (maximumPage - currentPage) : currentPage);

	const CGPoint contentOffset = CGPointMake(0.0, (mainScrollView.bounds.size.height * flip));

	if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
	{
		mainScrollView.contentOffset = contentOffset;
	}
}

- (void)updateContentSizeSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat cw = (mainScrollView.bounds.size.width); // Fixed width

	const CGFloat ch = (mainScrollView.bounds.size.height * pageCount); // Height

	const CGSize contentSize = CGSizeMake(cw, ch); // Possible new content size

	if (CGSizeEqualToSize(mainScrollView.contentSize, contentSize) == false)
	{
		mainScrollView.contentSize = contentSize;
	}
}

- (void)handleScrollViewDidEndSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewHeight = mainScrollView.bounds.size.height;

	const CGFloat contentOffsetY = mainScrollView.contentOffset.y;

	NSUInteger page = (contentOffsetY / viewHeight);

	if (showRTL == YES) page = (maximumPage - page);

	if ((page != currentPage) && (page <= maximumPage)) // Page changed
	{
		currentPage = page; currentKey = page; [pageToolbar showPageNumber:page ofPages:pageCount];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != page) [contentView wentOffScreen];
		}];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

- (void)addContentViewSinglePageScrollV:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

	CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

	viewRect.origin.y = (viewRect.size.height * flip); viewRect = CGRectInset(viewRect, 0.0, scrollViewOutset);

	if (UXReaderPageScrollView *contentView = [[UXReaderPageScrollView alloc] initWithFrame:viewRect document:document page:page])
	{
		[contentView setMessage:self]; [mainScrollView addSubview:contentView]; contentViews[@(page)] = contentView;
	}
}

- (void)layoutContentViewsSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewHeight = mainScrollView.bounds.size.height;

	const CGFloat contentOffsetY = mainScrollView.contentOffset.y;

	NSInteger pageA = (contentOffsetY / viewHeight);

	if (showRTL == YES) pageA = (maximumPage - pageA);

	NSInteger pageB = (pageA + 1); pageA -= 1; // Range

	if (pageA < NSInteger(minimumPage)) pageA = minimumPage;

	if (pageB > NSInteger(maximumPage)) pageB = maximumPage;

	const NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1));

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];

	for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
	{
		const NSUInteger page = [key unsignedIntegerValue]; // Page number

		if ([pageSet containsIndex:page] == NO) // Remove content view
		{
			UXReaderPageScrollView *contentView = contentViews[key];

			[contentView removeFromSuperview]; contentViews[key] = nil;
		}
		else // Visible content view - remove it from page set
		{
			[pageSet removeIndex:page];
		}
	}

	if ([pageSet count] > 0) // Add content views
	{
		const NSUInteger target = currentPage;

		if ([pageSet containsIndex:target] == YES)
		{
			[self addContentViewSinglePageScrollV:target];

			[pageSet removeIndex:target];
		}

		[pageSet enumerateIndexesUsingBlock:^(NSUInteger page, BOOL *stop)
		{
			[self addContentViewSinglePageScrollV:page];
		}];
	}
}

- (void)decrementPageSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.y -= mainScrollView.bounds.size.height;

	if (contentOffset.y >= minimumContentOffset) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)incrementPageSinglePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.y += mainScrollView.bounds.size.height;

	if (contentOffset.y < mainScrollView.contentSize.height) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)gotoPageSinglePageScrollV:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	BOOL visible = NO; if (page > maximumPage) return;

	if (UXReaderPageScrollView *contentView = contentViews[@(currentKey)])
	{
		visible = [contentView containsPage:page];
	}

	if (visible == NO) // Handle page is not visible
	{
		currentPage = currentKey = page; const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

		const CGPoint contentOffset = CGPointMake(0.0, (mainScrollView.bounds.size.height * flip));

		if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
			[mainScrollView setContentOffset:contentOffset];
		else
			[self layoutContentViewsSinglePageScrollV];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != page) [contentView wentOffScreen];
		}];

		[pageToolbar showPageNumber:page ofPages:pageCount];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

#pragma mark - UXReaderDisplayModeDoublePageScrollH methods

- (void)changeModeDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	[self removeAllContentViews]; // Brute mode change

	maximumKey = (maximumPage / 2); currentKey = NSUIntegerMax;

	[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

	[self updateContentSizeDoublePageScrollH]; [mainScrollView setContentOffset:CGPointZero];

	[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate

	[self gotoPageDoublePageScrollH:currentPage];
}

- (void)setupDisplayModeDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView == nil) // Create UXReaderMainScrollView
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, -scrollViewOutset, 0.0);

		if ((mainScrollView = [[UXReaderMainScrollView alloc] initWithFrame:scrollViewRect]))
		{
			[self.view insertSubview:mainScrollView atIndex:0]; [mainScrollView setDelegate:self];

			[self updateContentSizeDoublePageScrollH]; maximumKey = (maximumPage / 2);
		}
	}
}

- (void)handleSizeChangeDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView != nil) // Handle UIViewController size changes
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, -scrollViewOutset, 0.0);

		if (CGRectEqualToRect(mainScrollView.frame, scrollViewRect) == false)
		{
			[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

			mainScrollView.frame = scrollViewRect; // Update scroll view frame

			if (CGSizeEqualToSize(mainScrollView.contentSize, CGSizeZero) == false)
			{
				[self updateContentViewsDoublePageScrollH]; // Update view frames
			}

			[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate
		}
	}
}

- (void)updateContentViewsDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	[self updateContentSizeDoublePageScrollH]; // First update size

	[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
	{
		const NSUInteger pair = [key unsignedIntegerValue]; // Page pair

		CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

		const NSUInteger flip = (showRTL ? (maximumKey - pair) : pair);

		viewRect.origin.x = (viewRect.size.width * flip); // Update X

		contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.0);
	}];

	const NSUInteger flip = (showRTL ? (maximumKey - currentKey) : currentKey);

	const CGPoint contentOffset = CGPointMake((mainScrollView.bounds.size.width * flip), 0.0);

	if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
	{
		mainScrollView.contentOffset = contentOffset;
	}
}

- (void)updateContentSizeDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	const NSUInteger pairs = ((pageCount / 2) + (pageCount % 2));

	const CGFloat ch = mainScrollView.bounds.size.height; // Fixed height

	const CGFloat cw = (mainScrollView.bounds.size.width * pairs); // Width

	const CGSize contentSize = CGSizeMake(cw, ch); // Possible new content size

	if (CGSizeEqualToSize(mainScrollView.contentSize, contentSize) == false)
	{
		mainScrollView.contentSize = contentSize;
	}
}

- (void)handleScrollViewDidEndDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewWidth = mainScrollView.bounds.size.width;

	const CGFloat contentOffsetX = mainScrollView.contentOffset.x;

	NSUInteger pair = (contentOffsetX / viewWidth);

	if (showRTL == YES) pair = (maximumKey - pair);

	const NSUInteger page = (pair * 2); // Pair page number

	if ((page != currentPage) && (page <= maximumPage)) // Page changed
	{
		currentPage = page; currentKey = pair; [pageToolbar showPageNumber:page ofPages:pageCount];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != pair) [contentView wentOffScreen];
		}];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

- (void)addContentViewDoublePageScrollH:(NSUInteger)pair
{
	//NSLog(@"%s %i", __FUNCTION__, int(pair));

	const NSUInteger flip = (showRTL ? (maximumKey - pair) : pair);

	CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

	viewRect.origin.x = (viewRect.size.width * flip); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0);

	const NSUInteger pageA = (pair * 2); const NSUInteger pageB = (pageA + 1); // Page pair to show in content view

	NSMutableIndexSet *pages = [NSMutableIndexSet indexSetWithIndex:pageA]; if (pageA < maximumPage) [pages addIndex:pageB];

	if (UXReaderPageScrollView *contentView = [[UXReaderPageScrollView alloc] initWithFrame:viewRect document:document pages:pages])
	{
		[contentView setMessage:self]; [mainScrollView addSubview:contentView]; contentViews[@(pair)] = contentView;
	}
}

- (void)layoutContentViewsDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewWidth = mainScrollView.bounds.size.width;

	const CGFloat contentOffsetX = mainScrollView.contentOffset.x;

	NSInteger pairA = (contentOffsetX / viewWidth);

	if (showRTL == YES) pairA = (maximumKey - pairA);

	NSInteger pairB = (pairA + 1); pairA -= 1; // Range

	if (pairA < NSInteger(minimumKey)) pairA = minimumKey;

	if (pairB > NSInteger(maximumKey)) pairB = maximumKey;

	const NSRange pairRange = NSMakeRange(pairA, (pairB - pairA + 1));

	NSMutableIndexSet *pairSet = [NSMutableIndexSet indexSetWithIndexesInRange:pairRange];

	for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
	{
		const NSUInteger pair = [key unsignedIntegerValue]; // Page pair

		if ([pairSet containsIndex:pair] == NO) // Remove content view
		{
			UXReaderPageScrollView *contentView = contentViews[key];

			[contentView removeFromSuperview]; contentViews[key] = nil;
		}
		else // Visible content view - remove it from pair set
		{
			[pairSet removeIndex:pair];
		}
	}

	if ([pairSet count] > 0) // Add content views
	{
		const NSUInteger target = currentKey;

		if ([pairSet containsIndex:target] == YES)
		{
			[self addContentViewDoublePageScrollH:target];

			[pairSet removeIndex:target];
		}

		[pairSet enumerateIndexesUsingBlock:^(NSUInteger pair, BOOL *stop)
		{
			[self addContentViewDoublePageScrollH:pair];
		}];
	}
}

- (void)decrementPageDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.x -= mainScrollView.bounds.size.width;

	if (contentOffset.x >= minimumContentOffset) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)incrementPageDoublePageScrollH
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.x += mainScrollView.bounds.size.width;

	if (contentOffset.x < mainScrollView.contentSize.width) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)gotoPageDoublePageScrollH:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	BOOL visible = NO; if (page > maximumPage) return;

	if (UXReaderPageScrollView *contentView = contentViews[@(currentKey)])
	{
		visible = [contentView containsPage:page];
	}

	if (visible == NO) // Handle page is not visible
	{
		currentPage = page; const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

		const NSUInteger pair = (flip / 2); currentKey = pair; // Pair from page number

		const CGPoint contentOffset = CGPointMake((mainScrollView.bounds.size.width * pair), 0.0);

		if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
			[mainScrollView setContentOffset:contentOffset];
		else
			[self layoutContentViewsDoublePageScrollH];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != pair) [contentView wentOffScreen];
		}];

		[pageToolbar showPageNumber:page ofPages:pageCount];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
	else if (page != currentPage) // Handle page is visible
	{
		currentPage = page; [pageToolbar showPageNumber:page ofPages:pageCount];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

#pragma mark - UXReaderDisplayModeDoublePageScrollV methods

- (void)changeModeDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	[self removeAllContentViews]; // Brute mode change

	maximumKey = (maximumPage / 2); currentKey = NSUIntegerMax;

	[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

	[self updateContentSizeDoublePageScrollV]; [mainScrollView setContentOffset:CGPointZero];

	[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate

	[self gotoPageDoublePageScrollV:currentPage];
}

- (void)setupDisplayModeDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView == nil) // Create UXReaderMainScrollView
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, 0.0, -scrollViewOutset);

		if ((mainScrollView = [[UXReaderMainScrollView alloc] initWithFrame:scrollViewRect]))
		{
			[self.view insertSubview:mainScrollView atIndex:0]; [mainScrollView setDelegate:self];

			[self updateContentSizeDoublePageScrollV]; maximumKey = (maximumPage / 2);
		}
	}
}

- (void)handleSizeChangeDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	if (mainScrollView != nil) // Handle UIViewController size changes
	{
		const CGRect scrollViewRect = CGRectInset(self.view.bounds, 0.0, -scrollViewOutset);

		if (CGRectEqualToRect(mainScrollView.frame, scrollViewRect) == false)
		{
			[mainScrollView setDelegate:nil]; // Disable UIScrollViewDelegate

			mainScrollView.frame = scrollViewRect; // Update scroll view frame

			if (CGSizeEqualToSize(mainScrollView.contentSize, CGSizeZero) == false)
			{
				[self updateContentViewsDoublePageScrollV]; // Update view frames
			}

			[mainScrollView setDelegate:self]; // Enable UIScrollViewDelegate
		}
	}
}

- (void)updateContentViewsDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	[self updateContentSizeDoublePageScrollV]; // First update size

	[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
	{
		const NSUInteger pair = [key unsignedIntegerValue]; // Page pair

		CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

		const NSUInteger flip = (showRTL ? (maximumKey - pair) : pair);

		viewRect.origin.y = (viewRect.size.height * flip); // Update Y

		contentView.frame = CGRectInset(viewRect, 0.0, scrollViewOutset);
	}];

	const NSUInteger flip = (showRTL ? (maximumKey - currentKey) : currentKey);

	const CGPoint contentOffset = CGPointMake(0.0, (mainScrollView.bounds.size.height * flip));

	if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
	{
		mainScrollView.contentOffset = contentOffset;
	}
}

- (void)updateContentSizeDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	const NSUInteger pairs = ((pageCount / 2) + (pageCount % 2));

	const CGFloat cw = mainScrollView.bounds.size.width; // Fixed width

	const CGFloat ch = (mainScrollView.bounds.size.height * pairs); // Height

	const CGSize contentSize = CGSizeMake(cw, ch); // Possible new content size

	if (CGSizeEqualToSize(mainScrollView.contentSize, contentSize) == false)
	{
		mainScrollView.contentSize = contentSize;
	}
}

- (void)handleScrollViewDidEndDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewHeight = mainScrollView.bounds.size.height;

	const CGFloat contentOffsetY = mainScrollView.contentOffset.y;

	NSUInteger pair = (contentOffsetY / viewHeight);

	if (showRTL == YES) pair = (maximumKey - pair);

	const NSUInteger page = (pair * 2); // Pair page number

	if ((page != currentPage) && (page <= maximumPage)) // Page changed
	{
		currentPage = page; currentKey = pair; [pageToolbar showPageNumber:page ofPages:pageCount];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != pair) [contentView wentOffScreen];
		}];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

- (void)addContentViewDoublePageScrollV:(NSUInteger)pair
{
	//NSLog(@"%s %i", __FUNCTION__, int(pair));

	const NSUInteger flip = (showRTL ? (maximumKey - pair) : pair);

	CGRect viewRect = CGRectZero; viewRect.size = mainScrollView.bounds.size;

	viewRect.origin.y = (viewRect.size.height * flip); viewRect = CGRectInset(viewRect, 0.0, scrollViewOutset);

	const NSUInteger pageA = (pair * 2); const NSUInteger pageB = (pageA + 1); // Page pair to show in content view

	NSMutableIndexSet *pages = [NSMutableIndexSet indexSetWithIndex:pageA]; if (pageA < maximumPage) [pages addIndex:pageB];

	if (UXReaderPageScrollView *contentView = [[UXReaderPageScrollView alloc] initWithFrame:viewRect document:document pages:pages])
	{
		[contentView setMessage:self]; [mainScrollView addSubview:contentView]; contentViews[@(pair)] = contentView;
	}
}

- (void)layoutContentViewsDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	const CGFloat viewHeight = mainScrollView.bounds.size.height;

	const CGFloat contentOffsetY = mainScrollView.contentOffset.y;

	NSInteger pairA = (contentOffsetY / viewHeight);

	if (showRTL == YES) pairA = (maximumKey - pairA);

	NSInteger pairB = (pairA + 1); pairA -= 1; // Range

	if (pairA < NSInteger(minimumKey)) pairA = minimumKey;

	if (pairB > NSInteger(maximumKey)) pairB = maximumKey;

	const NSRange pairRange = NSMakeRange(pairA, (pairB - pairA + 1));

	NSMutableIndexSet *pairSet = [NSMutableIndexSet indexSetWithIndexesInRange:pairRange];

	for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
	{
		const NSUInteger pair = [key unsignedIntegerValue]; // Page pair

		if ([pairSet containsIndex:pair] == NO) // Remove content view
		{
			UXReaderPageScrollView *contentView = contentViews[key];

			[contentView removeFromSuperview]; contentViews[key] = nil;
		}
		else // Visible content view - remove it from pair set
		{
			[pairSet removeIndex:pair];
		}
	}

	if ([pairSet count] > 0) // Add content views
	{
		const NSUInteger target = currentKey;

		if ([pairSet containsIndex:target] == YES)
		{
			[self addContentViewDoublePageScrollV:target];

			[pairSet removeIndex:target];
		}

		[pairSet enumerateIndexesUsingBlock:^(NSUInteger pair, BOOL *stop)
		{
			[self addContentViewDoublePageScrollV:pair];
		}];
	}
}

- (void)decrementPageDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.y -= mainScrollView.bounds.size.height;

	if (contentOffset.y >= minimumContentOffset) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)incrementPageDoublePageScrollV
{
	//NSLog(@"%s", __FUNCTION__);

	CGPoint contentOffset = mainScrollView.contentOffset; contentOffset.y += mainScrollView.bounds.size.height;

	if (contentOffset.y < mainScrollView.contentSize.height) [mainScrollView setContentOffset:contentOffset animated:YES];
}

- (void)gotoPageDoublePageScrollV:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	BOOL visible = NO; if (page > maximumPage) return;

	if (UXReaderPageScrollView *contentView = contentViews[@(currentKey)])
	{
		visible = [contentView containsPage:page];
	}

	if (visible == NO) // Handle page is not visible
	{
		currentPage = page; const NSUInteger flip = (showRTL ? (maximumPage - page) : page);

		const NSUInteger pair = (flip / 2); currentKey = pair; // Pair from page number

		const CGPoint contentOffset = CGPointMake(0.0, (mainScrollView.bounds.size.height * pair));

		if (CGPointEqualToPoint(mainScrollView.contentOffset, contentOffset) == false)
			[mainScrollView setContentOffset:contentOffset];
		else
			[self layoutContentViewsDoublePageScrollV];

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			if ([key unsignedIntegerValue] != pair) [contentView wentOffScreen];
		}];

		[pageToolbar showPageNumber:page ofPages:pageCount];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
	else if (page != currentPage) // Handle page is visible
	{
		currentPage = page; [pageToolbar showPageNumber:page ofPages:pageCount];

		if ([delegate respondsToSelector:@selector(readerViewController:didChangePage:)])
		{
			[delegate readerViewController:self didChangePage:page];
		}
	}
}

#pragma mark - UXReaderViewController search methods

- (void)newSearchText:(nonnull NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	if ([text length] > 0) // Search text
	{
		if ([text isEqualToString:searchText] == NO)
		{
			searchText = text; [self cancelSearch];

			[self startSearchTimer];
		}
	}
	else // Clear search
	{
		[self clearSearch];
	}
}

- (void)beginTextSearch:(nonnull NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	if ([text length] > 0) // Begin search
	{
		if ([text isEqualToString:lastSearch] == NO)
		{
			searchText = text; [self cancelSearch];

			[self startSearch:text];
		}
	}
	else // Clear search
	{
		[self clearSearch];
	}
}

- (void)startSearch:(nonnull NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	lastSearch = text; [document setSearch:self];

	[document beginSearch:text options:searchMatch];
}

- (void)cancelSearch
{
	//NSLog(@"%s", __FUNCTION__);

	[self stopSearchTimer]; allSearchSelections = nil; pageSearchSelections = nil;

	[document cancelSearch]; [self setSearchSelections:nil]; [mainToolbar clearSearchText];

	[searchControl showControls:NO];
}

- (void)clearSearch
{
	//NSLog(@"%s", __FUNCTION__);

	[self cancelSearch]; lastSearch = nil; searchText = nil;
}

- (void)stopActiveSearch
{
	//NSLog(@"%s", __FUNCTION__);

	if ([document isSearching] == YES) [self clearSearch];
}

- (void)stopSearchTimer
{
	//NSLog(@"%s", __FUNCTION__);

	if (searchTimer != nil) { [searchTimer invalidate]; searchTimer = nil; }
}

- (void)startSearchTimer
{
	//NSLog(@"%s", __FUNCTION__);

	[self stopSearchTimer]; const NSTimeInterval ti = [UXReaderFramework searchBeginTimer];

	searchTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(searchTimerFired:) userInfo:nil repeats:NO];
}

- (void)searchTimerFired:(nonnull NSTimer *)timer
{
	//NSLog(@"%s %@", __FUNCTION__, timer);

	[self cancelSearch]; [self startSearch:searchText];
}

- (void)searchHitDecrementPage:(BOOL)decrement
{
	//NSLog(@"%s %i", __FUNCTION__, decrement);

	NSUInteger page = currentPage; // Start with current page

	if (decrement == YES) { if (page == minimumPage) page = maximumPage; else page--; }

	while (YES) // Loop - wrapping around - until a page with selections is found
	{
		NSArray<UXReaderSelection *> *selections = pageSearchSelections[@(page)];

		if (selections == nil) // None on this page - decrement page
		{
			if (page == minimumPage) page = maximumPage; else page--;
		}
		else // Found a page with some selections - goto it
		{
			[self presentSelection:[selections lastObject]]; break;
		}
	}
}

- (void)searchHitIncrementPage:(BOOL)increment
{
	//NSLog(@"%s %i", __FUNCTION__, increment);

	NSUInteger page = currentPage; // Start with current page

	if (increment == YES) { if (page == maximumPage) page = minimumPage; else page++; }

	while (YES) // Loop - wrapping around - until a page with selections is found
	{
		NSArray<UXReaderSelection *> *selections = pageSearchSelections[@(page)];

		if (selections == nil) // None on this page - increment page
		{
			if (page == maximumPage) page = minimumPage; else page++;
		}
		else // Found a page with some selections - goto it
		{
			[self presentSelection:[selections firstObject]]; break;
		}
	}
}

- (void)searchHitDecrement
{
	//NSLog(@"%s", __FUNCTION__);

	if (currentSearchHighlight != nil) // Carry on
	{
		const NSUInteger page = [currentSearchHighlight page];

		if (currentPage != page) { [self searchHitDecrementPage:NO]; return; }

		if (NSArray<UXReaderSelection *> *selections = pageSearchSelections[@(page)])
		{
			const NSUInteger lowerIndex = 0; const NSUInteger upperIndex = ([selections count] - 1);

			const NSUInteger index = [selections indexOfObject:currentSearchHighlight];

			if (index != NSNotFound) // Found current selection in array
			{
				if ((index == lowerIndex) || (upperIndex == lowerIndex))
				{
					[self searchHitDecrementPage:YES];
				}
				else // Highlight new selection on same page
				{
					[self presentSelection:[selections objectAtIndex:(index - 1)]];
				}
			}
		}
	}
}

- (void)searchHitIncrement
{
	//NSLog(@"%s", __FUNCTION__);

	if (currentSearchHighlight != nil) // Carry on
	{
		const NSUInteger page = [currentSearchHighlight page];

		if (currentPage != page) { [self searchHitIncrementPage:NO]; return; }

		if (NSArray<UXReaderSelection *> *selections = pageSearchSelections[@(page)])
		{
			const NSUInteger lowerIndex = 0; const NSUInteger upperIndex = ([selections count] - 1);

			const NSUInteger index = [selections indexOfObject:currentSearchHighlight];

			if (index != NSNotFound) // Found current selection in array
			{
				if ((index == upperIndex) || (lowerIndex == upperIndex))
				{
					[self searchHitIncrementPage:YES];
				}
				else // Highlight new selection on same page
				{
					[self presentSelection:[selections objectAtIndex:(index + 1)]];
				}
			}
		}
	}
}

- (void)presentSelection:(nonnull UXReaderSelection *)selection
{
	//NSLog(@"%s %@", __FUNCTION__, selection);

	currentSearchHighlight = selection;

	[self gotoPage:[selection page]];

	[self setCurrentActiveHighlight:selection];

	const NSUInteger index = [allSearchSelections indexOfObject:selection];

	if (index != NSNotFound) // Found current selection
	{
		const NSUInteger total = [allSearchSelections count];

		const NSUInteger pages = [pageSearchSelections count];

		[mainToolbar showFound:(index + 1) of:total on:pages];
	}
}

- (void)setCurrentActiveHighlight:(nonnull UXReaderSelection *)selection
{
	//NSLog(@"%s %@", __FUNCTION__, selection);

	if (currentActiveHighlight != nil) // Clear old
	{
		[currentActiveHighlight setHighlight:NO];

		[self redrawPage:[currentActiveHighlight page]];

		currentActiveHighlight = nil;
	}

	if (selection != nil) // Highlight new
	{
		currentActiveHighlight = selection;

		[currentActiveHighlight setHighlight:YES];

		[self redrawPage:[currentActiveHighlight page]];

		if (UXReaderPageScrollView *contentView = contentViews[@(currentKey)])
		{
			[contentView ensureVisibleSelection:currentActiveHighlight];
		}
	}
}

- (void)setSearchSelections:(nullable NSDictionary<NSNumber *, NSArray<UXReaderSelection *> *> *)selections
{
	//NSLog(@"%s %@", __FUNCTION__, selections);

	if (selections != [document searchSelections])
	{
		[document setSearchSelections:selections]; // New selections

		[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
		{
			[contentView pageNeedsDisplay];
		}];
	}
}

- (void)redrawPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	[contentViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UXReaderPageScrollView *contentView, BOOL *stop)
	{
		if ([contentView containsPage:page] == YES) [contentView pageNeedsDisplay];
	}];
}

#pragma mark - UXReaderDocumentSearchDelegate methods

- (void)document:(nonnull UXReaderDocument *)documentx didBeginDocumentSearch:(NSUInteger)kind
{
	//NSLog(@"%s %@ %lu", __FUNCTION__, documentx, kind);

	allSearchSelections = [[NSMutableArray alloc] init];

	pageSearchSelections = [[NSMutableDictionary alloc] init];

	[mainToolbar showSearchBusy:YES];
}

- (void)document:(nonnull UXReaderDocument *)documentx didFinishDocumentSearch:(NSUInteger)total
{
	//NSLog(@"%s %@ %lu", __FUNCTION__, documentx, total);

	[mainToolbar showSearchBusy:NO];

	if (pageSearchSelections != nil)
	{
		if (total > 0) // Text was found
		{
			[mainToolbar dismissKeyboard];

			[searchControl showControls:(total > 1)];

			[self setSearchSelections:pageSearchSelections];

			[self searchHitIncrementPage:NO]; // Go
		}
		else // Text was not found
		{
			[mainToolbar showSearchNotFound];

			[self setSearchSelections:nil];
		}
	}
	else // Was cancelled
	{
		[self setSearchSelections:nil];
	}
}

- (void)document:(nonnull UXReaderDocument *)documentx didBeginPageSearch:(NSUInteger)page pages:(NSUInteger)pages
{
	//NSLog(@"%s %@ %lu %lu", __FUNCTION__, documentx, page, pages);

	if (pageSearchSelections != nil) // Still searching
	{
		//[mainToolbar showFound:(page + 1) of:pages]; //[mainToolbar showFoundCount:(page + 1)];
	}
}

- (void)document:(nonnull UXReaderDocument *)documentx didFinishPageSearch:(NSUInteger)page total:(NSUInteger)total
{
	//NSLog(@"%s %@ %lu %lu", __FUNCTION__, documentx, page, total);

	if (pageSearchSelections != nil) // Still searching
	{
		if (total > 0) [mainToolbar showFoundCount:total];
	}
}

- (void)document:(nonnull UXReaderDocument *)documentx searchDidMatch:(nonnull NSArray<UXReaderSelection *> *)selections page:(NSUInteger)page
{
	//NSLog(@"%s %@ %lu %@", __FUNCTION__, documentx, page, selections);

	if (pageSearchSelections != nil) // Still searching
	{
		[allSearchSelections addObjectsFromArray:selections];

		pageSearchSelections[@(page)] = selections;
	}
}

#pragma mark - UXReaderSearchControlDelegate methods

- (void)searchControl:(nonnull UXReaderSearchControl *)control forwardButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, control, button);

	[self searchHitIncrement];
}

- (void)searchControl:(nonnull UXReaderSearchControl *)control reverseButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, control, button);

	[self searchHitDecrement];
}

- (void)searchControl:(nonnull UXReaderSearchControl *)control closeButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, control, button);

	[self clearSearch];
}

#pragma mark - UXReaderStuffControllerDelegate methods

- (void)stuffController:(nonnull UXReaderStuffController *)controller gotoPage:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, controller, int(page));

	[self gotoPage:page];
}

- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getCurrentPage:(nullable id)o
{
	//NSLog(@"%s %@ %@", __FUNCTION__, controller, o);

	return currentPage;
}

- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getCurrentWhat:(nullable id)o
{
	//NSLog(@"%s %@ %@", __FUNCTION__, controller, o);

	return currentWhat;
}

- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getDisplayMode:(nullable id)o
{
	//NSLog(@"%s %@ %@", __FUNCTION__, controller, o);

	return NSUInteger(displayMode);
}

- (NSUInteger)stuffController:(nonnull UXReaderStuffController *)controller getSearchMatch:(nullable id)o
{
	//NSLog(@"%s %@ %@", __FUNCTION__, controller, o);

	return NSUInteger(searchMatch);
}

- (void)stuffController:(nonnull UXReaderStuffController *)controller setDisplayMode:(NSUInteger)displayModex
{
	//NSLog(@"%s %@ %i", __FUNCTION__, controller, int(displayModex));

	[self setDisplayMode:UXReaderDisplayMode(displayModex)];
}

- (void)stuffController:(nonnull UXReaderStuffController *)controller setSearchMatch:(NSUInteger)searchMatchx
{
	//NSLog(@"%s %@ %i", __FUNCTION__, controller, int(searchMatchx));

	searchMatch = UXReaderSearchOptions(searchMatchx);
}

- (CGRect)stuffController:(nonnull UXReaderStuffController *)controller frameForPage:(NSUInteger)page inView:(nonnull UIView *)inView
{
	//NSLog(@"%s %@ %i %@", __FUNCTION__, controller, int(page), inView);

	CGRect frame = CGRectZero; // Default frame - none

	if (UXReaderPageScrollView *contentView = contentViews[@(currentKey)])
	{
		frame = [contentView frameForPage:page inView:inView];
	}

	return frame;
}

- (void)dismissStuffController:(nonnull UXReaderStuffController *)controller currentWhat:(NSUInteger)index
{
	//NSLog(@"%s %@ %i", __FUNCTION__, controller, int(index));

	currentWhat = index; [mainToolbar stuffButtonWhat:currentWhat];

	NSMutableDictionary<NSString *, id> *defaults = [UXReaderFramework defaults];

	[defaults setObject:@(currentWhat) forKey:@"CurrentWhat"];

	[defaults setObject:@(searchMatch) forKey:@"SearchMatch"];

	[controller willMoveToParentViewController:nil];

	[[controller view] removeFromSuperview];

	[controller removeFromParentViewController];
}

@end

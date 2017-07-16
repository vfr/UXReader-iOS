//
//	UXReaderStuffController.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderStuffController.h"
#import "UXReaderStuffToolbar.h"
#import "UXReaderFramework.h"

#import "UXReaderOptionsView.h"
#import "UXReaderOutlineView.h"
#import "UXReaderThumbsView.h"

@interface UXReaderStuffController () <UXReaderStuffToolbarDelegate, UXReaderOutlineViewDelegate, UXReaderThumbsViewDelegate, UXReaderOptionsViewDelegate>

@end

@implementation UXReaderStuffController
{
	UXReaderDocument *document;

	UIView *contentView;

	__weak UIView *currentView;

	UXReaderStuffToolbar *mainToolbar;

	UXReaderOptionsView *optionsView;

	UXReaderOutlineView *outlineView;

	UXReaderThumbsView *thumbsView;

	NSUInteger currentPage;

	NSUInteger currentWhat;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIViewController instance methods

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if ((self = [self initWithNibName:nil bundle:nil])) // Initialize self
	{
		if (documentx != nil) document = documentx; else self = nil;
	}

	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	//NSLog(@"%s %@ %@", __FUNCTION__, nibNameOrNil, nibBundleOrNil);

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) // Initialize superclass
	{
		[self setAutomaticallyAdjustsScrollViewInsets:NO]; currentPage = NSUIntegerMax;
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

	[super viewDidLoad]; [self populateViewController:[self view]];
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

#pragma mark - UXReaderStuffController instance methods

- (nonnull UXReaderDocument *)document
{
	//NSLog(@"%s", __FUNCTION__);

	return document;
}

- (void)setDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if (document != nil) return;

	if ((documentx != nil) && (documentx != document))
	{
		document = documentx;
	}
}

- (void)populateViewController:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	[view setBackgroundColor:[UIColor clearColor]];

	UIView *here = [self addEffectsView:view]; [self addMainToolbar:here];

	if ([delegate respondsToSelector:@selector(stuffController:getCurrentPage:)])
	{
		currentPage = [delegate stuffController:self getCurrentPage:nil];
	}

	if ([delegate respondsToSelector:@selector(stuffController:getCurrentWhat:)])
	{
		currentWhat = [delegate stuffController:self getCurrentWhat:nil];
	}

	[mainToolbar selectSegmentIndex:currentWhat]; [self showUserInterfaceWithIndex:currentWhat];
}

- (nonnull UIView *)addEffectsView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	//[blurEffectView setBackgroundColor:[UIColor colorWithWhite:0.50 alpha:0.50]];
	[blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[view addSubview:blurEffectView];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
														toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

	contentView = [blurEffectView contentView]; return contentView;
}

- (void)addMainToolbar:(nonnull UIView *)here
{
	//NSLog(@"%s %@", __FUNCTION__, here);

	if (mainToolbar == nil) // Create UXReaderStuffToolbar
	{
		if ((mainToolbar = [[UXReaderStuffToolbar alloc] initWithDocument:document]))
		{
			[here addSubview:mainToolbar]; [mainToolbar setDelegate:self]; // UXReaderStuffToolbarDelegate

			[here addConstraint:[NSLayoutConstraint constraintWithItem:mainToolbar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
																toItem:here attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

			[here addConstraint:[NSLayoutConstraint constraintWithItem:mainToolbar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
																toItem:here attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

			[here addConstraint:[NSLayoutConstraint constraintWithItem:mainToolbar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
																toItem:here attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
		}
	}
}

- (void)addUserInterfaceView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if ((view != nil) && (contentView != nil)) // Add user interface view
	{
		UIView *here = contentView; [here insertSubview:view belowSubview:mainToolbar];

		[here addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
															toItem:here attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

		[here addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:here attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

		[here addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:here attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

		[here addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
															toItem:here attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
	}
}

- (void)showUserInterfaceView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	[currentView setHidden:YES]; [view setHidden:NO]; currentView = view;
}

- (void)showUserInterfaceWithIndex:(NSUInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	currentWhat = index;

	switch (index)
	{
		case 2: // Options
		{
			if (optionsView == nil)
			{
				if ((optionsView = [[UXReaderOptionsView alloc] initWithDocument:document]))
				{
					[self addUserInterfaceView:optionsView]; [optionsView setDelegate:self];

					[optionsView setCurrentPage:currentPage];
				}
			}

			[self showUserInterfaceView:optionsView]; [optionsView didAppear];
			break;
		}

		case 0: // Outline
		{
			if (outlineView == nil)
			{
				if ((outlineView = [[UXReaderOutlineView alloc] initWithDocument:document]))
				{
					[self addUserInterfaceView:outlineView]; [outlineView setDelegate:self];

					[outlineView setCurrentPage:currentPage];
				}
			}

			[self showUserInterfaceView:outlineView]; [outlineView didAppear];
			break;
		}

		case 1: // Thumbs
		{
			if (thumbsView == nil)
			{
				if ((thumbsView = [[UXReaderThumbsView alloc] initWithDocument:document]))
				{
					[self addUserInterfaceView:thumbsView]; [thumbsView setDelegate:self];

					[thumbsView setCurrentPage:currentPage];
				}
			}

			[self showUserInterfaceView:thumbsView]; [thumbsView didAppear];
			break;
		}
	}
}

#pragma mark - UXReaderStuffToolbarDelegate instance methods

- (void)mainToolbar:(nonnull UXReaderStuffToolbar *)toolbar showControl:(nonnull UISegmentedControl *)control
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, control);

	[self showUserInterfaceWithIndex:[control selectedSegmentIndex]];
}

- (void)mainToolbar:(nonnull UXReaderStuffToolbar *)toolbar closeButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, button);

	if ([delegate respondsToSelector:@selector(dismissStuffController:currentWhat:)])
	{
		[delegate dismissStuffController:self currentWhat:currentWhat];
	}
}

#pragma mark - UXReaderOutlineViewDelegate instance methods

- (void)outlineView:(nonnull UXReaderOutlineView *)view gotoPage:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, view, int(page));

	if ([delegate respondsToSelector:@selector(stuffController:gotoPage:)])
	{
		[delegate stuffController:self gotoPage:page];
	}
}

- (void)outlineView:(nonnull UXReaderOutlineView *)view dismiss:(nullable id)that
{
	//NSLog(@"%s %@ %@", __FUNCTION__, view, that);

	if ([delegate respondsToSelector:@selector(dismissStuffController:currentWhat:)])
	{
		[delegate dismissStuffController:self currentWhat:currentWhat];
	}
}

#pragma mark - UXReaderThumbsViewDelegate instance methods

- (void)thumbsView:(nonnull UXReaderThumbsView *)view gotoPage:(NSUInteger)page
{
	//NSLog(@"%s %@ %i", __FUNCTION__, view, int(page));

	if ([delegate respondsToSelector:@selector(stuffController:gotoPage:)])
	{
		[delegate stuffController:self gotoPage:page];
	}
}

- (CGRect)thumbsView:(nonnull UXReaderThumbsView *)view frameForPage:(NSUInteger)page inView:(nonnull UIView *)inView
{
	//NSLog(@"%s %@ %i %@", __FUNCTION__, view, int(page), inView);

	CGRect frame = CGRectZero; // Default frame - none

	if ([delegate respondsToSelector:@selector(stuffController:frameForPage:inView:)])
	{
		frame = [delegate stuffController:self frameForPage:page inView:inView];
	}

	return frame;
}

- (void)thumbsView:(nonnull UXReaderThumbsView *)view dismiss:(nullable id)that
{
	//NSLog(@"%s %@ %@", __FUNCTION__, view, that);

	if ([delegate respondsToSelector:@selector(dismissStuffController:currentWhat:)])
	{
		[delegate dismissStuffController:self currentWhat:currentWhat];
	}
}

#pragma mark - UXReaderOptionsViewDelegate instance methods

- (NSUInteger)optionsView:(nonnull UXReaderOptionsView *)view getDisplayMode:(nullable id)o
{
	//NSLog(@"%s %@ %@", __FUNCTION__, view, o);

	NSUInteger displayMode = -1; // Default

	if ([delegate respondsToSelector:@selector(stuffController:getDisplayMode:)])
	{
		displayMode = [delegate stuffController:self getDisplayMode:nil];
	}

	return displayMode;
}

- (NSUInteger)optionsView:(nonnull UXReaderOptionsView *)view getSearchMatch:(nullable id)o
{
	//NSLog(@"%s %@ %@", __FUNCTION__, view, o);

	NSUInteger searchMatch = -1; // Default

	if ([delegate respondsToSelector:@selector(stuffController:getSearchMatch:)])
	{
		searchMatch = [delegate stuffController:self getSearchMatch:nil];
	}

	return searchMatch;
}

- (void)optionsView:(nonnull UXReaderOptionsView *)view setDisplayMode:(NSUInteger)displayMode
{
	//NSLog(@"%s %@ %i", __FUNCTION__, view, int(displayMode));

	if ([delegate respondsToSelector:@selector(stuffController:setDisplayMode:)])
	{
		[delegate stuffController:self setDisplayMode:displayMode];
	}
}

- (void)optionsView:(nonnull UXReaderOptionsView *)view setSearchMatch:(NSUInteger)searchMatch
{
	//NSLog(@"%s %@ %i", __FUNCTION__, view, int(searchMatch));

	if ([delegate respondsToSelector:@selector(stuffController:setSearchMatch:)])
	{
		[delegate stuffController:self setSearchMatch:searchMatch];
	}
}

@end

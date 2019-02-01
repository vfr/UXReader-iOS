//
//	ReaderViewController.mm
//	Reader v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "ReaderViewController.h"
#import "ReaderUpperToolbar.h"
#import "ReaderLowerToolbar.h"
#import "ReaderAppearance.h"

#import <UXReader/UXReader.h>

@interface ReaderViewController () <UITableViewDataSource, UITableViewDelegate, UXReaderViewControllerDelegate,
									ReaderUpperToolbarDelegate, ReaderLowerToolbarDelegate>
@end

@implementation ReaderViewController
{
	NSBundle *bundle;

	UITableView *pdfTableView;

	ReaderUpperToolbar *upperToolbar;

	//ReaderLowerToolbar *lowerToolbar;

	NSMutableArray<NSURL *> *documentURLs;

	NSMutableArray<NSURL *> *filteredURLs;

	UIFont *nameFont; UIFont *infoFont;

	NSDateFormatter *dateFormatter;

	NSNumberFormatter *numberFormatter;

	NSTimer *updateTimer, *searchTimer;

	NSString *searchText, *lastSearch;

	dispatch_source_t monitorVN;

	UILabel *noneLabel;

	BOOL useViewControllerModal;

	UXReaderViewController *anReaderViewController;

	UXReaderWatermark *watermark;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIViewController instance methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	//NSLog(@"%s %@ %@", __FUNCTION__, nibNameOrNil, nibBundleOrNil);

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) // Initialize superclass
	{
		bundle = [NSBundle bundleForClass:[self class]]; UIColor *tintColor = [ReaderAppearance controlTintColor];

		[[UIButton appearance] setTintColor:tintColor]; [[UISegmentedControl appearance] setTintColor:tintColor];

		self.automaticallyAdjustsScrollViewInsets = NO; useViewControllerModal = NO;
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

	[[self navigationController] setNavigationBarHidden:YES animated:animated];
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

- (UIViewController *)childViewControllerForStatusBarHidden
{
	//NSLog(@"%s", __FUNCTION__);

	return anReaderViewController;
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

	if (monitorVN != nil) // Cancel
	{
		dispatch_source_cancel(monitorVN);
	}
}

#pragma mark - ReaderViewController instance methods

- (void)populateViewController:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0]; [self prepareDocumentsList];

	nameFont = [UIFont systemFontOfSize:15.0]; infoFont = [UIFont systemFontOfSize:12.0]; // Cell fonts

// --------------------------------------------------------------------------------------------------------------------------------

	if ((noneLabel = [[UILabel alloc] initWithFrame:CGRectZero])) // UILabel
	{
		noneLabel.translatesAutoresizingMaskIntoConstraints = NO; noneLabel.textAlignment = NSTextAlignmentCenter;
		noneLabel.textColor = [ReaderAppearance lightTextColor]; noneLabel.backgroundColor = [UIColor clearColor];
		noneLabel.text = [bundle localizedStringForKey:@"No Documents" value:nil table:nil];
		noneLabel.font = [UIFont systemFontOfSize:17.0];
		[view addSubview:noneLabel];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:noneLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:noneLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
	}

// --------------------------------------------------------------------------------------------------------------------------------

	if ((pdfTableView = [[UITableView alloc] initWithFrame:CGRectZero])) // UITableView
	{
		pdfTableView.translatesAutoresizingMaskIntoConstraints = NO; [view addSubview:pdfTableView];

		const CGFloat ti = ([ReaderAppearance mainToolbarHeight] + [ReaderAppearance statusBarHeight]);

		pdfTableView.contentInset = UIEdgeInsetsMake(ti, 0.0, 0.0, 0.0); pdfTableView.rowHeight = 48.0;

		pdfTableView.exclusiveTouch = YES; pdfTableView.scrollsToTop = NO; pdfTableView.dataSource = self; pdfTableView.delegate = self;

		[view addConstraint:[NSLayoutConstraint constraintWithItem:pdfTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:pdfTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:pdfTableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:pdfTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
	}

// --------------------------------------------------------------------------------------------------------------------------------

	if ((upperToolbar = [[ReaderUpperToolbar alloc] initWithFrame:CGRectZero]))
	{
		[view addSubview:upperToolbar]; upperToolbar.delegate = self; // ReaderUpperToolbarDelegate

		[view addConstraint:[NSLayoutConstraint constraintWithItem:upperToolbar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:upperToolbar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:upperToolbar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
	}

// --------------------------------------------------------------------------------------------------------------------------------

//	if ((lowerToolbar = [[ReaderLowerToolbar alloc] initWithFrame:CGRectZero]))
//	{
//		[view addSubview:lowerToolbar]; lowerToolbar.delegate = self; // ReaderLowerToolbarDelegate
//
//		[view addConstraint:[NSLayoutConstraint constraintWithItem:lowerToolbar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
//															toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
//
//		[view addConstraint:[NSLayoutConstraint constraintWithItem:lowerToolbar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
//															toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
//
//		[view addConstraint:[NSLayoutConstraint constraintWithItem:lowerToolbar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
//															toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
//	}

// --------------------------------------------------------------------------------------------------------------------------------

	[self enableUserInterface];

	if (pdfTableView.hidden == NO)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

		[pdfTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
}

- (void)prepareDocumentsList
{
	//NSLog(@"%s", __FUNCTION__);

	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	dateFormatter.timeStyle = NSDateFormatterShortStyle;

	numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

	NSFileManager *fileManager = [NSFileManager defaultManager]; // NSFileManager

	NSArray<NSURL *> *documents = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];

	NSURL *pathURL = [documents firstObject]; [self monitorFileURL:pathURL]; [self updateDocumentsList];
}

- (void)enableUserInterface
{
	//NSLog(@"%s", __FUNCTION__);

	const BOOL state = ([documentURLs count] > 0);

	[upperToolbar setEnabled:state]; //[lowerToolbar setEnabled:state];

	noneLabel.hidden = state; pdfTableView.hidden = !state;
}

- (void)updateDocumentsList
{
	//NSLog(@"%s", __FUNCTION__);

	NSFileManager *fileManager = [NSFileManager defaultManager]; // NSFileManager

	NSArray<NSURLResourceKey> *keys = @[NSURLNameKey, NSURLCreationDateKey, NSURLFileSizeKey];

	NSArray<NSURL *> *documents = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];

	NSArray<NSURL *> *URLs = [fileManager contentsOfDirectoryAtURL:[documents firstObject] includingPropertiesForKeys:keys options:0 error:nil];

	documentURLs = [[bundle URLsForResourcesWithExtension:@"pdf" subdirectory:nil] mutableCopy];

	for (NSURL *URL in URLs) // Add only PDF file URLs from NSDocumentDirectory folder
	{
		NSString *filename = [URL lastPathComponent]; NSString *extension = [filename pathExtension];

		if ([extension caseInsensitiveCompare:@"pdf"] == NSOrderedSame) [documentURLs addObject:URL];
	}

	//[documentURLs addObject:[NSURL URLWithString:@"http://www.vfr.org/iOS-Security-Guide.pdf"]];

	[documentURLs sortUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2)
	{
		return [[url1 lastPathComponent] localizedStandardCompare:[url2 lastPathComponent]];
	}];

	NSMutableArray<NSURL *> *searchedURLs = [self filterDocumentURLs:lastSearch];

	NSCountedSet *set1 = [[NSCountedSet alloc] initWithArray:searchedURLs];

	NSCountedSet *set2 = [[NSCountedSet alloc] initWithArray:filteredURLs];

	if ([set1 isEqualToSet:set2] == NO) // URL sets differ - so update
	{
		filteredURLs = searchedURLs; [pdfTableView reloadData];
	}

	[self enableUserInterface];
}

- (NSMutableArray<NSURL *> *)filterDocumentURLs:(nullable NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	if ((text == nil) || (text.length < 1)) return documentURLs;

	NSMutableArray<NSURL *> *filtered = [[NSMutableArray alloc] init];

	for (NSURL *URL in documentURLs) // Enumerate document URLs
	{
		NSString *name = [[URL lastPathComponent] stringByDeletingPathExtension];

		if ([name localizedCaseInsensitiveContainsString:text] == YES)
		{
			[filtered addObject:URL];
		}
	}

	return filtered;
}

- (void)monitorFileURL:(nonnull NSURL *)URL
{
	//NSLog(@"%s %@", __FUNCTION__, URL);

	if ((monitorVN == nil) && ([URL isFileURL] == YES))
	{
		if (const char *path = [URL fileSystemRepresentation]) // File path
		{
			const int fd = open(path, O_EVTONLY); if (fd < 0) return; // Exit on error

			const dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

			const unsigned long events = (DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK);

			if ((monitorVN = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, events, queue)))
			{
				__weak ReaderViewController *weakSelf = self; // ReaderViewController

				dispatch_source_set_event_handler(monitorVN, // Set event handler
				^{
					dispatch_async(dispatch_get_main_queue(), ^{ [weakSelf startUpdateTimer]; });

					//const unsigned long event = dispatch_source_get_data(monitorVN);
				});

				dispatch_source_set_cancel_handler(monitorVN, // Cancel handler
				^{
					close(fd);
				});

				dispatch_resume(monitorVN);
			}
		}
	}
}

- (void)stopUpdateTimer
{
	//NSLog(@"%s", __FUNCTION__);

	if (updateTimer != nil) { [updateTimer invalidate]; updateTimer = nil; }
}

- (void)startUpdateTimer
{
	//NSLog(@"%s", __FUNCTION__);

	[self stopUpdateTimer]; const NSTimeInterval ti = 4.0; // Update after 4 seconds

	updateTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:NO];
}

- (void)updateTimerFired:(nonnull NSTimer *)timer
{
	//NSLog(@"%s %@", __FUNCTION__, timer);

	[self stopUpdateTimer]; [self updateDocumentsList];
}

- (void)newSearchText:(nonnull NSString *)text
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	if ([text length] > 0) // Search text
	{
		if ([text isEqualToString:searchText] == NO)
		{
			searchText = text; [self startSearchTimer];
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
		if ([text isEqualToString:lastSearch] == NO) // New search term
		{
			searchText = text; [self stopSearchTimer]; [self startSearch:text];
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

	lastSearch = text; // Last search string

	filteredURLs = [self filterDocumentURLs:text];

	[pdfTableView reloadData];
}

- (void)clearSearch
{
	//NSLog(@"%s", __FUNCTION__);

	[self stopSearchTimer];

	lastSearch = nil; searchText = nil;

	filteredURLs = documentURLs;

	[pdfTableView reloadData];
}

- (void)stopSearchTimer
{
	//NSLog(@"%s", __FUNCTION__);

	if (searchTimer != nil) { [searchTimer invalidate]; searchTimer = nil; }
}

- (void)startSearchTimer
{
	//NSLog(@"%s", __FUNCTION__);

	[self stopSearchTimer]; const NSTimeInterval ti = [ReaderAppearance searchBeginTimer];

	searchTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(searchTimerFired:) userInfo:nil repeats:NO];
}

- (void)searchTimerFired:(nonnull NSTimer *)timer
{
	//NSLog(@"%s %@", __FUNCTION__, timer);

	[self stopSearchTimer]; [self startSearch:searchText];
}

- (void)openDocumentURL:(nonnull NSURL *)URL
{
	//NSLog(@"%s %@", __FUNCTION__, URL);

	//if (watermark == nil) watermark = [[UXReaderWatermark alloc] init];

	if (UXReaderDocument *document = [[UXReaderDocument alloc] initWithURL:URL])
	{
		//[document setRenderTile:watermark]; //[document setTitle:@"Custom Title"];

		[document setUseNativeRendering]; [document setHighlightLinks:NO]; [document setShowRTL:NO];

		if ([self splitViewController]) // Handle UISplitViewController host
		{
			if ([delegate respondsToSelector:@selector(readerViewController:showDocument:)])
			{
				[delegate readerViewController:self showDocument:document];
			}
		}
		else if (UXReaderViewController *readerViewController = [[UXReaderViewController alloc] init])
		{
			[readerViewController setDelegate:self]; [readerViewController setDocument:document];

			[readerViewController setDisplayMode:UXReaderDisplayModeSinglePageScrollH];

			if ([self navigationController]) // Handle UINavigationController host
			{
				[[self navigationController] pushViewController:readerViewController animated:YES];
			}
			else // Handle root UIViewController host
			{
				if (useViewControllerModal == YES) // Present as modal
				{
					[readerViewController setModalPresentationStyle:UIModalPresentationFullScreen];

					[readerViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

					[self presentViewController:readerViewController animated:YES completion:nil];
				}
				else // Present as child UIViewController
				{
					[self addChildViewController:readerViewController];

					readerViewController.view.frame = self.view.bounds;

					[self.view addSubview:[readerViewController view]];

					[readerViewController didMoveToParentViewController:self];

					anReaderViewController = readerViewController;

					[self setNeedsStatusBarAppearanceUpdate];
				}
			}
		}
	}
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//NSLog(@"%s %i", __FUNCTION__, int(section));

	return [filteredURLs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	static NSString *const rtvc = @"ReaderTableViewCell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rtvc];

	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:rtvc];

	cell.detailTextLabel.font = infoFont; cell.detailTextLabel.textColor = [ReaderAppearance lightTextColor];

	cell.textLabel.font = nameFont; cell.textLabel.textColor = [UIColor colorWithWhite:0.0 alpha:1.0];

	NSURL *URL = filteredURLs[indexPath.row];

	if ([URL isFileURL] == YES) // Local file URL
	{
		NSArray<NSURLResourceKey> *keys = @[NSURLNameKey, NSURLCreationDateKey, NSURLFileSizeKey];

		NSDictionary<NSURLResourceKey, id> *values = [URL resourceValuesForKeys:keys error:nil];

		NSString *name = values[NSURLNameKey]; cell.textLabel.text = [name stringByDeletingPathExtension];

		NSNumber *size = values[NSURLFileSizeKey]; NSString *bytes = [numberFormatter stringFromNumber:size];

		NSDate *date = values[NSURLCreationDateKey]; NSString *time = [dateFormatter stringFromDate:date];

		NSString *format = [bundle localizedStringForKey:@"%@ (%@ bytes)" value:nil table:nil];

		cell.detailTextLabel.text = [NSString stringWithFormat:format, time, bytes];
	}
	else // Remote host URL
	{
		NSString *name = [[URL lastPathComponent] stringByDeletingPathExtension];

		NSString *host = [NSString stringWithFormat:@"%@://%@/", [URL scheme], [URL host]];

		cell.textLabel.text = name; cell.detailTextLabel.text = host;
	}

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	NSURL *URL = filteredURLs[indexPath.row];

	return [URL isFileURL];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSURL *URL = filteredURLs[indexPath.row];

		if ([[NSFileManager defaultManager] removeItemAtURL:URL error:nil] == YES)
		{
			[filteredURLs removeObject:URL]; [documentURLs removeObject:URL]; // Remove the URL

			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		else // Delete failed
		{
			[tableView setEditing:FALSE animated:TRUE];
		}
	}
}

#pragma mark - UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	[upperToolbar dismissKeyboard];

	NSURL *URL = filteredURLs[indexPath.row];

	[self openDocumentURL:URL];
}

#pragma mark - ReaderUpperToolbarDelegate methods

- (void)upperToolbar:(nonnull ReaderUpperToolbar *)toolbar optionsButton:(nonnull UIButton *)button
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, button);

	//[self showOptionsUserInterface];
}

- (void)upperToolbar:(nonnull ReaderUpperToolbar *)toolbar searchTextDidChange:(nonnull NSString *)text
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, text);

	[self newSearchText:text];
}

- (void)upperToolbar:(nonnull ReaderUpperToolbar *)toolbar beginSearching:(nonnull NSString *)text
{
	//NSLog(@"%s %@ %@", __FUNCTION__, toolbar, text);

	[self beginTextSearch:text];
}

#pragma mark - ReaderLowerToolbarDelegate methods

#pragma mark - UXReaderViewControllerDelegate methods

- (void)readerViewController:(nonnull UXReaderViewController *)viewController didChangePage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));
}

- (void)readerViewController:(nonnull UXReaderViewController *)viewController didChangeDocument:(nullable UXReaderDocument *)document
{
	//NSLog(@"%s %@", __FUNCTION__, document);
}

- (void)readerViewController:(nonnull UXReaderViewController *)viewController didChangeMode:(UXReaderDisplayMode)mode
{
	//NSLog(@"%s %i", __FUNCTION__, int(mode));
}

- (void)dismissReaderViewController:(UXReaderViewController *)viewController
{
	//NSLog(@"%s %@", __FUNCTION__, viewController);

	if ([self navigationController]) // UINavigationController
	{
		[[self navigationController] popViewControllerAnimated:YES];
	}
	else // Root UIViewController host
	{
		if (useViewControllerModal == YES) // Dismiss modal
		{
			[self dismissViewControllerAnimated:YES completion:
			^{
				NSIndexPath *selected = [self->pdfTableView indexPathForSelectedRow];

				[self->pdfTableView deselectRowAtIndexPath:selected animated:NO];
			}];
		}
		else // Dismiss child UIViewController
		{
			[viewController willMoveToParentViewController:nil];

			[[viewController view] removeFromSuperview];

			[viewController removeFromParentViewController];

			anReaderViewController = nil; [self setNeedsStatusBarAppearanceUpdate];

			NSIndexPath *selected = [pdfTableView indexPathForSelectedRow];

			[pdfTableView deselectRowAtIndexPath:selected animated:YES];
		}
	}
}

@end

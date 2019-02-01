//
//	UXReaderOptionsView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017-2019 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderOptionsView.h"
#import "UXReaderShadowView.h"
#import "UXReaderFramework.h"

@interface UXReaderOptionsView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation UXReaderOptionsView
{
	UXReaderDocument *document;

	NSArray<NSAttributedString *> *debugging;
	NSArray<NSAttributedString *> *information;

	UITableViewCell *displayModeCell;
	UITableViewCell *searchMatchCell;

	UILabel *displayModeLabel;
	UILabel *searchMatchLabel;

	UITableView *optionsView;

	NSBundle *bundle;

	NSUInteger currentPage;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView instance methods

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if ((self = [self initWithFrame:CGRectZero])) // Initialize self
	{
		if (documentx != nil) [self populateView:documentx]; else self = nil;
	}

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO; self.hidden = YES;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

#pragma mark - UXReaderOptionsView instance methods

- (void)populateView:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	document = documentx; [self prepareInformation];

	const CGFloat si = ([UXReaderFramework isSmallDevice] ? 4.0 : 48.0);

	[self setLayoutMargins:UIEdgeInsetsMake(8.0, si, 8.0, si)]; // Side insets

	if (UXReaderShadowView *shadowView = [[UXReaderShadowView alloc] initWithFrame:CGRectZero])
	{
		[shadowView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]]; [self addSubview:shadowView];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0]];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
	}

	if ((optionsView = [[UITableView alloc] initWithFrame:CGRectZero])) // UITableView
	{
		optionsView.translatesAutoresizingMaskIntoConstraints = NO; [self addSubview:optionsView];

		const CGFloat ti = ([UXReaderFramework mainToolbarHeight] + [UXReaderFramework statusBarHeight]);

		optionsView.contentInset = UIEdgeInsetsMake(ti, 0.0, 0.0, 0.0); //optionsView.rowHeight = 28.0;

		optionsView.separatorStyle = UITableViewCellSeparatorStyleNone; //optionsView.allowsMultipleSelection = NO;

		optionsView.exclusiveTouch = YES; optionsView.scrollsToTop = NO; optionsView.dataSource = self; optionsView.delegate = self;

		[self addConstraint:[NSLayoutConstraint constraintWithItem:optionsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:optionsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0]];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:optionsView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:optionsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
	}
}

- (void)setCurrentPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	currentPage = page;

	if (optionsView != nil) // Go to top of scroll view
	{
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10000000ull), dispatch_get_main_queue(),
		^{
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; // Dispatch hack

			[self->optionsView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];

			[self->optionsView flashScrollIndicators];
		});
	}
}

- (void)didAppear
{
	//NSLog(@"%s", __FUNCTION__);

	[optionsView flashScrollIndicators];
}

- (void)prepareInformation
{
	//NSLog(@"%s", __FUNCTION__);

	UIFont *font = [UIFont systemFontOfSize:13.0];

	UIFont *bold = [UIFont boldSystemFontOfSize:13.0];

	bundle = [NSBundle bundleForClass:[self class]];

	NSMutableArray<NSAttributedString *> *info = [[NSMutableArray alloc] init];

	NSDictionary<NSString *, id> *boldAttributes = @{NSFontAttributeName : bold};

	NSDictionary<NSString *, id> *fontAttributes = @{NSFontAttributeName : font};

	NSString *local; NSString *head; NSString *text; NSString *format = @"%@: ";

	NSMutableAttributedString *string1; NSAttributedString *string2;

	local = [bundle localizedStringForKey:@"PDFVersion" value:nil table:nil];
	head = [NSString stringWithFormat:format, local]; text = [document fileVersion];
	string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
	string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
	[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];

	local = [bundle localizedStringForKey:@"Permissions" value:nil table:nil];
	head = [NSString stringWithFormat:format, local]; text = [self permissionsText];
	string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
	string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
	[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];

	static NSArray<NSString *> *keys = @[@"Title", @"Author", @"Subject", @"Keywords", @"Creator", @"Producer", @"CreationDate", @"ModDate"];

	for (NSString *key in keys) // Enumerate information keys
	{
		NSString *text = [document information][key];

		if ([text length] > 0) // Add document information text
		{
			head = [NSString stringWithFormat:format, [bundle localizedStringForKey:key value:nil table:nil]];
			string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
			string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
			[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];
		}
	}

	information = [info copy];

#if defined(DEBUG)

	[info removeAllObjects];

	const CGSize ps = [document pageSize:currentPage];
	const CGFloat pw = ps.width; const CGFloat ph = ps.height;
	const CGFloat iw = (pw / 72.0); const CGFloat ih = (ph / 72.0);

	if ([document URL] != nil) // Document NSURL
	{
		head = [NSString stringWithFormat:format, @"URL"];
		text = [[document URL] absoluteString]; // UXReaderDocument NSURL
		string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
		string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
		[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];
	}

	head = [NSString stringWithFormat:format, @"UUID"];
	text = [[document UUID] UUIDString]; // UXReaderDocument UUID
	string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
	string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
	[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];

	head = [NSString stringWithFormat:format, @"Page Size"];
	text = [NSString stringWithFormat:@"%g x %g points (%.1f x %.1f)", pw, ph, iw, ih];
	string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
	string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
	[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];

	head = [NSString stringWithFormat:format, @"Model"];
	text = [UXReaderFramework deviceModel]; // Current device model
	string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
	string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
	[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];

	head = [NSString stringWithFormat:format, @"Memory"]; const size_t MiB = 1048576;
	text = [NSString stringWithFormat:@"%lu MiB", [UXReaderFramework deviceMemory] / MiB];
	string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
	string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
	[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];

	head = [NSString stringWithFormat:format, @"CPU Cores"];
	text = [NSString stringWithFormat:@"%i", int([[NSProcessInfo processInfo] processorCount])];
	string1 = [[NSMutableAttributedString alloc] initWithString:head attributes:boldAttributes];
	string2 = [[NSAttributedString alloc] initWithString:text attributes:fontAttributes];
	[string1 appendAttributedString:string2]; [info addObject:[string1 copy]];

	debugging = [info copy];

#endif // End DEBUG
}

- (NSString *)permissionsText
{
	//NSLog(@"%s", __FUNCTION__);

	const uint32_t permissions = [document permissions];

	NSMutableString *text = [[NSMutableString alloc] init]; NSString *local;

	if (permissions & UXReaderDocumentPermissionCopy) // Copy allowed
	{
		local = [bundle localizedStringForKey:@"Copy" value:nil table:nil];
		[text appendString:local]; [text appendString:@" "];
	}

	if (permissions & UXReaderDocumentPermissionModify) // Modify allowed
	{
		local = [bundle localizedStringForKey:@"Modify" value:nil table:nil];
		[text appendString:local]; [text appendString:@" "];
	}

	if (permissions & UXReaderDocumentPermissionPrint) // Print allowed
	{
		local = [bundle localizedStringForKey:@"Print" value:nil table:nil];
		[text appendString:local]; [text appendString:@" "];
	}

	return [text copy];
}

- (NSUInteger)linesToFit:(nonnull NSAttributedString *)text inView:(nonnull UIView *)view lineHeight:(nullable CGFloat *)lineHeight
{
	//NSLog(@"%s %@", __FUNCTION__, text);

	const CGSize textSize = UXSizeCeil([text size]);

	if (lineHeight != nil) *lineHeight = textSize.height;

	const NSUInteger tw = textSize.width; const CGFloat fudge = 32;

	const NSUInteger vw = (view.bounds.size.width - fudge);

	NSUInteger lines = (tw / vw); if (tw % vw) lines++;

	return lines;
}

- (NSArray<NSString *> *)localizeStrings:(nonnull NSArray<NSString *> *)strings
{
	//NSLog(@"%s %@", __FUNCTION__, strings);

	NSMutableArray<NSString *> *localized = [[NSMutableArray alloc] init];

	for (NSString *string in strings) // Enumerate strings
	{
		[localized addObject:[bundle localizedStringForKey:string value:nil table:nil]];
	}

	return [localized copy];
}

- (UITableViewCell *)displayModeCell
{
	//NSLog(@"%s", __FUNCTION__);

	if (displayModeCell == nil) // Create UITableViewCell
	{
		static NSString *const imageName = @"UXReader-Display-Mode"; const CGFloat sp = 16.0;

		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

		cell.imageView.image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];

		UIView *view = [cell contentView]; NSArray *items = @[@"←1→", @"↓1↑", @"←2→", @"↓2↑"];

		UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:items];
		[control setTranslatesAutoresizingMaskIntoConstraints:NO]; [control setExclusiveTouch:YES];
		[control addTarget:self action:@selector(displayModeSelected:) forControlEvents:UIControlEventValueChanged];
		[control setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
		[view addSubview:control]; //[control setBackgroundColor:[UIColor lightGrayColor]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:[cell imageView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:sp]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero]; // UILabel
		[label setTranslatesAutoresizingMaskIntoConstraints:NO]; [label setBackgroundColor:[UIColor clearColor]];
		[label setFont:[UIFont systemFontOfSize:12.0]]; [label setHidden:[UXReaderFramework isSmallDevice]];
		[label setTextColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
		[view addSubview:label];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:control attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:sp]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

		if ([delegate respondsToSelector:@selector(optionsView:getDisplayMode:)])
		{
			[control setSelectedSegmentIndex:[delegate optionsView:self getDisplayMode:nil]];
		}

		displayModeCell = cell; displayModeLabel = label; [self updateDisplayModeLabel:[control selectedSegmentIndex]];
	}

	return displayModeCell;
}

- (UITableViewCell *)searchMatchCell
{
	//NSLog(@"%s", __FUNCTION__);

	if (searchMatchCell == nil) // Create UITableViewCell
	{
		static NSString *const imageName = @"UXReader-Toolbar-Search"; const CGFloat sp = 16.0;

		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

		cell.imageView.image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];

		UIView *view = [cell contentView]; NSArray *items = [self localizeStrings:@[@"Any", @"Case", @"Word"]];

		UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:items];
		[control setTranslatesAutoresizingMaskIntoConstraints:NO]; [control setExclusiveTouch:YES];
		[control addTarget:self action:@selector(searchMatchSelected:) forControlEvents:UIControlEventValueChanged];
		[control setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
		[view addSubview:control]; //[control setBackgroundColor:[UIColor lightGrayColor]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:[cell imageView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:sp]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero]; // UILabel
		[label setTranslatesAutoresizingMaskIntoConstraints:NO]; [label setBackgroundColor:[UIColor clearColor]];
		[label setFont:[UIFont systemFontOfSize:12.0]]; [label setHidden:[UXReaderFramework isSmallDevice]];
		[label setTextColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
		[view addSubview:label];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
															toItem:control attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:sp]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

		[view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
															toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

		if ([delegate respondsToSelector:@selector(optionsView:getSearchMatch:)])
		{
			[control setSelectedSegmentIndex:[delegate optionsView:self getSearchMatch:nil]];
		}

		searchMatchCell = cell; searchMatchLabel = label; [self updateSearchMatchLabel:[control selectedSegmentIndex]];
	}

	return searchMatchCell;
}

- (void)updateDisplayModeLabel:(NSUInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	static NSArray<NSString *> *names = @[@"SinglePageScrollH", @"SinglePageScrollV", @"DoublePageScrollH", @"DoublePageScrollV"];

	if (index < [names count]) [displayModeLabel setText:[bundle localizedStringForKey:names[index] value:nil table:nil]];
}

- (void)updateSearchMatchLabel:(NSUInteger)index
{
	//NSLog(@"%s %i", __FUNCTION__, int(index));

	static NSArray<NSString *> *names = @[@"CaseInsensitiveMatch", @"CaseSensitiveMatch", @"WholeWordMatch"];

	if (index < [names count]) [searchMatchLabel setText:[bundle localizedStringForKey:names[index] value:nil table:nil]];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//NSLog(@"%s %@", __FUNCTION__, tableView);

	NSInteger sections = 2;

	if ([debugging count] > 0) sections++;

	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//NSLog(@"%s %i", __FUNCTION__, int(section));

	NSInteger rows = 0;

	switch (section)
	{
		case 0: // Options
		{
			rows = 2;
			break;
		}

		case 1: // Information
		{
			rows = [information count];
			break;
		}

		case 2: // Debugging
		{
			rows = [debugging count];
			break;
		}
	}

	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	static NSString *const otvc = @"UXReaderOptionsViewCell";

	UITableViewCell *cell = [[UITableViewCell alloc] init];

	switch (indexPath.section)
	{
		case 0: // Options
		{
			switch (indexPath.row)
			{
				case 0: // Search
				{
					cell = [self searchMatchCell];
					break;
				}

				case 1: // Display
				{
					cell = [self displayModeCell];
					break;
				}
			}
			break;
		}

		case 1: // Information
		{
			cell = [tableView dequeueReusableCellWithIdentifier:otvc]; // Dequeue a cell

			if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:otvc];

			NSAttributedString *text = information[indexPath.row]; cell.textLabel.attributedText = text;

			cell.textLabel.numberOfLines = [self linesToFit:text inView:tableView lineHeight:nil];
			break;
		}

		case 2: // Debugging
		{
			cell = [tableView dequeueReusableCellWithIdentifier:otvc]; // Dequeue a cell

			if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:otvc];

			NSAttributedString *text = debugging[indexPath.row]; cell.textLabel.attributedText = text;

			cell.textLabel.numberOfLines = [self linesToFit:text inView:tableView lineHeight:nil];
			break;
		}
	}

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//NSLog(@"%s %i", __FUNCTION__, int(section));

	NSString *title = nil;

	static NSArray<NSString *> *titles = @[@"Reader Preferences", @"Document Information", @"Debug Information"];

	if (section < [titles count]) title = [bundle localizedStringForKey:titles[section] value:nil table:nil];

	return title;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	CGFloat rowHeight = [tableView rowHeight];

	switch (indexPath.section)
	{
		case 0: // Options
		{
			rowHeight = 48.0;
			break;
		}

		case 1: // Information
		{
			NSAttributedString *text = information[indexPath.row]; CGFloat lineHeight = 0;

			const NSUInteger lines = [self linesToFit:text inView:tableView lineHeight:&lineHeight];

			rowHeight = (30.0 + ((lines - 1) * lineHeight));
			break;
		}

		case 2: // Debugging
		{
			NSAttributedString *text = debugging[indexPath.row]; CGFloat lineHeight = 0;

			const NSUInteger lines = [self linesToFit:text inView:tableView lineHeight:&lineHeight];

			rowHeight = (30.0 + ((lines - 1) * lineHeight));
			break;
		}
	}

	return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	//NSLog(@"%s %i", __FUNCTION__, int(section));

	return 34.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
	//NSLog(@"%s %i", __FUNCTION__, int(section));

	if ([view isKindOfClass:[UITableViewHeaderFooterView class]] == YES)
	{
		UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;

		[[header contentView] setBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1.0]];

		[[header textLabel] setFont:[UIFont boldSystemFontOfSize:15.0]];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	return UITableViewCellEditingStyleNone;
}
	
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	return NO;
}

#pragma mark - UISegmentedControl action methods

- (void)displayModeSelected:(UISegmentedControl *)control
{
	//NSLog(@"%s %@", __FUNCTION__, control);

	const NSUInteger index = [control selectedSegmentIndex];

	if ([delegate respondsToSelector:@selector(optionsView:setDisplayMode:)])
	{
		[delegate optionsView:self setDisplayMode:index];

		[self updateDisplayModeLabel:index];
	}
}

- (void)searchMatchSelected:(UISegmentedControl *)control
{
	//NSLog(@"%s %@", __FUNCTION__, control);

	const NSUInteger index = [control selectedSegmentIndex];

	if ([delegate respondsToSelector:@selector(optionsView:setSearchMatch:)])
	{
		[delegate optionsView:self setSearchMatch:index];

		[self updateSearchMatchLabel:index];
	}
}

@end

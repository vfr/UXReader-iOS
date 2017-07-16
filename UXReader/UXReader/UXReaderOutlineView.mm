//
//	UXReaderOutlineView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderOutlineView.h"
#import "UXReaderShadowView.h"
#import "UXReaderFramework.h"

#import "UXReaderAction.h"
#import "UXReaderDestination.h"
#import "UXReaderOutline.h"

@interface UXReaderOutlineView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation UXReaderOutlineView
{
	UXReaderDocument *document;

	NSArray<UXReaderOutline *> *outline;

	UIFont *fontLevel0, *fontLevelN;

	UITableView *outlineView;

	UILabel *noneLabel;

	BOOL updateCells;
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

#pragma mark - UXReaderOutlineView instance methods

- (void)populateView:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	document = documentx; outline = [documentx outline];

	const CGFloat si = ([UXReaderFramework isSmallDevice] ? 4.0 : 32.0);

	[self setLayoutMargins:UIEdgeInsetsMake(8.0, si, 8.0, si)];

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

	if ([outline count] > 0) // Document has an outline
	{
		if ((outlineView = [[UITableView alloc] initWithFrame:CGRectZero])) // UITableView
		{
			outlineView.translatesAutoresizingMaskIntoConstraints = NO; [self addSubview:outlineView];

			const CGFloat ti = ([UXReaderFramework mainToolbarHeight] + [UXReaderFramework statusBarHeight]);

			outlineView.contentInset = UIEdgeInsetsMake(ti, 0.0, 0.0, 0.0); outlineView.rowHeight = 24.0;

			outlineView.separatorStyle = UITableViewCellSeparatorStyleNone; //outlineView.allowsMultipleSelection = NO;

			outlineView.exclusiveTouch = YES; outlineView.scrollsToTop = NO; outlineView.dataSource = self; outlineView.delegate = self;

			[self addConstraint:[NSLayoutConstraint constraintWithItem:outlineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:outlineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0.0]];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:outlineView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0.0]];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:outlineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

			const CGFloat fontSize = ([UXReaderFramework isSmallDevice] ? 13.0 : 14.0);

			fontLevel0 = [UIFont boldSystemFontOfSize:fontSize];

			fontLevelN = [UIFont systemFontOfSize:fontSize];
		}
	}
	else // Document does not have an outline
	{
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];

		if ((noneLabel = [[UILabel alloc] initWithFrame:CGRectZero])) // UILabel
		{
			noneLabel.translatesAutoresizingMaskIntoConstraints = NO; noneLabel.textAlignment = NSTextAlignmentCenter;
			noneLabel.textColor = [UXReaderFramework lightTextColor]; noneLabel.backgroundColor = [UIColor clearColor];
			noneLabel.text = [bundle localizedStringForKey:@"NoDocumentOutline" value:nil table:nil];
			noneLabel.font = [UIFont systemFontOfSize:17.0];
			[self addSubview:noneLabel];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:noneLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

			[self addConstraint:[NSLayoutConstraint constraintWithItem:noneLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
																toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
		}
	}
}

- (void)setCurrentPage:(NSUInteger)page
{
	//NSLog(@"%s %i", __FUNCTION__, int(page));

	if ((outlineView != nil) && (outline != nil))
	{
		__block NSUInteger row = 0; // UITableView row to scroll to

		[outline enumerateObjectsUsingBlock:^(UXReaderOutline *entry, NSUInteger index, BOOL *stop)
		{
			const NSUInteger dest = [[[entry action] destination] page]; // UXReaderOutline entry destination page

			if (dest == page) { *stop = YES; row = index; } else if (dest > page) { *stop = YES; if (index > 0) row = (index - 1); }
		}];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10000000ull), dispatch_get_main_queue(),
		^{
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // Dispatch hack

			[outlineView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];

			dispatch_async(dispatch_get_main_queue(), ^{ updateCells = YES; [outlineView reloadData]; [outlineView flashScrollIndicators]; });
		});
	}
}

- (void)didAppear
{
	//NSLog(@"%s", __FUNCTION__);

	if (updateCells == YES) [outlineView flashScrollIndicators];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//NSLog(@"%s %i", __FUNCTION__, int(section));

	return [outline count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	static NSString *const otvc = @"UXReaderOutlineViewCell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otvc];

	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:otvc];

	if (updateCells == YES) // Update UITableViewCell contents
	{
		const CGFloat iw = ([UXReaderFramework isSmallDevice] ? 12.0 : 28.0);

		UXReaderOutline *entry = outline[indexPath.row]; cell.indentationLevel = [entry level]; cell.indentationWidth = iw;

		UIFont *font = ([entry level] ? fontLevelN : fontLevel0); cell.textLabel.font = font; cell.detailTextLabel.font = font;

		const NSUInteger page = [[[entry action] destination] page]; NSString *label = [document pageLabel:page];

		cell.detailTextLabel.text = ((label == nil) ? [NSString stringWithFormat:@"%i", int(page+1)] : label);

		cell.textLabel.text = [entry name]; cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	}

	return cell;
}

#pragma mark - UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __FUNCTION__, indexPath);

	UXReaderOutline *entry = outline[indexPath.row];

	const NSUInteger page = [[[entry action] destination] page];

	if ([delegate respondsToSelector:@selector(outlineView:gotoPage:)])
	{
		[delegate outlineView:self gotoPage:page];
	}

	if ([delegate respondsToSelector:@selector(outlineView:dismiss:)])
	{
		[delegate outlineView:self dismiss:nil];
	}
}

@end

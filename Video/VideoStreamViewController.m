//
//  VideoStreamViewController.m
//  Video
//
//  Created by MacMiniA on 01/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoStreamViewController.h"
#import "VideoComposeViewController.h"
#import "VideoPlayViewController.h"

@interface VideoStreamViewController ()

@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) AssetBrowserItem* selectedItem;

@end

@implementation VideoStreamViewController

enum {
	AssetBrowserScrollDirectionDown,
    AssetBrowserScrollDirectionUp
};

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        haveBuiltSourceLibraries = NO;
        thumbnailScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare for segue %@", [segue identifier]);
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ComposeSegue"])
    {
        // Get reference to the destination view controller
        VideoComposeViewController *vc = [segue destinationViewController];
        vc.session = self.session;
        vc.svmDelegate = self;
    }
    if ([[segue identifier] isEqualToString:@"PlaySegue"])
    {
        VideoPlaybackViewController *vc = [segue destinationViewController];
        vc.session = self.session;
        vc.svmDelegate = self;
        if (self.selectedItem != nil) {
            [vc setURL:self.selectedItem.URL];
            self.selectedItem = nil;
        }
    }
}

- (IBAction)logoutAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated  {
    NSLog(@"viewWillApper");
    if (assetBrowser == nil) {
        assetBrowser = [AssetBrowserSource assetBrowserSource];
    }
    [assetBrowser buildSourceLibrary];
    [self.tableView reloadData];
    assetBrowser.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self enableThumbnailAndTitleGeneration];
	[self generateThumbnailsAndTitles];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
	[self disableThumbnailAndTitleGeneration];
	
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath)
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)enableThumbnailAndTitleGeneration
{
	thumbnailAndTitleGenerationEnabled = YES;
}

- (void)disableThumbnailAndTitleGeneration
{
	thumbnailAndTitleGenerationEnabled = NO;
}

- (void)generateThumbnailsAndTitles
{
    NSLog(@"generate thumbnail");
	if (! thumbnailAndTitleGenerationEnabled) {
		return;
	}
    NSLog(@"generate thumbnail");
	if (! thumbnailAndTitleGenerationIsRunning) {
		/* Run on the next run loop iteration. We may be called from with configureCell: and we don't want to slow down table view display. */
		thumbnailAndTitleGenerationIsRunning = YES;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self thumbnailsAndTitlesTask];
		});
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"table items count %lu", [[assetBrowser items] count]);
    if([[assetBrowser items] count] == 0) {
        self.errorMessage.hidden = NO;
        self.errorMessage.text = @"No videos send or received yet";
    }
    else {
        if ([self.errorMessage.text compare:@"No videos send or received yet"] == 0) {
            self.errorMessage.hidden = YES;
            self.errorMessage.text = @"";
        }
    }
	return [[assetBrowser items] count];
}

- (void)configureCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath *)indexPath
{
	if ( cell == nil)
		return;
		
	AssetBrowserItem *item = [[assetBrowser items] objectAtIndex:indexPath.row];
	cell.textLabel.text = item.title;
    
	UIImage *thumb = item.thumbnailImage;
	
	if ( !thumb || !item.haveRichestTitle ) {
		[self generateThumbnailsAndTitles];
	}
	
	if (!thumb) {
		thumb = [item placeHolderImage];
	}
	cell.imageView.image = thumb;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"updating cell");
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[self configureCell:cell forIndexPath:indexPath];
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedItem = [[assetBrowser items] objectAtIndex:indexPath.row];
    NSLog(@"Row selected");
    [self performSegueWithIdentifier:@"PlaySegue" sender:self];
}

#pragma mark -
#pragma mark Asset Library Delegate

- (void)assetBrowserSourceItemsDidChange:(AssetBrowserSource*)source
{
    NSLog(@"reloading table");
	
    if (self.tableView != nil) {
        NSLog(@"tableView is not nil");
        NSLog(@"Number of sections:%ld", self.tableView.numberOfSections);
        NSLog(@"Number of rows: %ld", [self.tableView numberOfRowsInSection:0]);
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark Thumbnail Generation

- (void)updateCellForBrowserItemIfVisible:(AssetBrowserItem*)browserItem
{
	NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		AssetBrowserItem *visibleBrowserItem = [[assetBrowser items] objectAtIndex:indexPath.row];
		if ([browserItem isEqual:visibleBrowserItem]) {
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			[self configureCell:cell forIndexPath:indexPath];
			[cell setNeedsLayout];
			break;
		}
	}
}

- (void)thumbnailsAndTitlesTask
{
	if (! thumbnailAndTitleGenerationEnabled) {
		thumbnailAndTitleGenerationIsRunning = NO;
		return;
	}
	NSLog(@"generate thumbnail task");
	thumbnailAndTitleGenerationIsRunning = YES;
	
	NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    NSLog(@"table cell count %lu", [visibleIndexPaths count]);
	
	id objOrEnumerator = (lastTableViewScrollDirection == AssetBrowserScrollDirectionDown) ? (id)visibleIndexPaths : (id)[visibleIndexPaths reverseObjectEnumerator];
	for (NSIndexPath *path in objOrEnumerator)
	{
        NSLog(@"generating thumbnail loop");
		NSArray *assetItemsInSection = [assetBrowser items];
		AssetBrowserItem *assetItem = ((NSInteger)[assetItemsInSection count] > path.row) ? [assetItemsInSection objectAtIndex:path.row] : nil;
        
		if (assetItem) {
			__block NSInteger runningRequests = 0;
			if (assetItem.thumbnailImage == nil) {
				CGFloat targetHeight = self.tableView.rowHeight -1.0; // The contentView is one point smaller than the cell because of the divider.
				targetHeight *= thumbnailScale;
				
				CGFloat targetAspectRatio = 1.5;
				CGSize targetSize = CGSizeMake(targetHeight*targetAspectRatio, targetHeight);
				
				runningRequests++;
				[assetItem generateThumbnailAsynchronouslyWithSize:targetSize fillMode:AssetBrowserItemFillModeCrop completionHandler:^(UIImage *thumbnail)
                 {
                     runningRequests--;
                     if (runningRequests == 0) {
                         [self updateCellForBrowserItemIfVisible:assetItem];
                         // Continue generating until all thumbnails/titles in range have been finished.
                         [self thumbnailsAndTitlesTask];
                     }
                 }];
				
                
			}
			if (!assetItem.haveRichestTitle) {
				runningRequests++;
				[assetItem generateTitleFromMetadataAsynchronouslyWithCompletionHandler:^(NSString *title){
					runningRequests--;
					if (runningRequests == 0) {
						[self updateCellForBrowserItemIfVisible:assetItem];
						// Continue generating until all thumbnails/titles in range have been finished.
						[self thumbnailsAndTitlesTask];
					}
				}];
			}
			// If we are generating a title or thumbnail then wait until that returns to generate the next one.
			if ( runningRequests > 0 )
				return;
		}
	}
	
	thumbnailAndTitleGenerationIsRunning = NO;
	
	return;
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

#if ONLY_GENERATE_THUMBS_AND_TITLES_WHEN_NOT_SCROLLING

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self disableThumbnailAndTitleGeneration];
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate) {
		[self enableThumbnailAndTitleGeneration];
		[self generateThumbnailsAndTitles];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self enableThumbnailAndTitleGeneration];
	[self generateThumbnailsAndTitles];
}

#endif //ONLY_GENERATE_THUMBS_AND_TITLES_WHEN_NOT_SCROLLING

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat newOffset = scrollView.contentOffset.y;
	CGFloat oldOffset = lastTableViewYContentOffset;
	
	CGFloat offsetAmount = newOffset-oldOffset;
	
	// Only update the scroll direction if we've passed some threshold (8 points).
	if ( fabs(offsetAmount) > 8.0 ) {
		if (offsetAmount > 0.0)
			lastTableViewScrollDirection = AssetBrowserScrollDirectionDown;
		else if (newOffset < oldOffset)
			lastTableViewScrollDirection = AssetBrowserScrollDirectionUp;
		
		lastTableViewYContentOffset = newOffset;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // Get rid of AVAsset and thumbnail caches for items which aren't on screen.
	NSLog(@"%@ memory warning, clearing asset and thumbnail caches", self);
	NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
	NSUInteger row = 0;
    for (AssetBrowserItem *item in [assetBrowser items]) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
		if (![visibleIndexPaths containsObject:path]) {
			[item clearAssetCache];
			[item clearThumbnailCache];
		}
		row++;
	}
	
}

- (void)SendVideoMailSuccess:(NSData *)response {
    self.errorMessage.text = @"Videomail successfully sent";
    self.errorMessage.hidden = NO;
    NSLog(@"Sending videomail success");
    
}
- (void)SendVideoMailFailedWithError:(NSError *)error {
    self.errorMessage.text = @"Sending Videomail failed";
    self.errorMessage.hidden = NO;
    NSLog(@"Sending videomail failed");
}

- (void)SendVideoMailInProgress {
    NSLog(@"Sending videomail");
    self.errorMessage.hidden = NO;
    self.errorMessage.text = @"Sending Videomail in progress";
}


@end

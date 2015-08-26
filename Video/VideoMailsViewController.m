//
//  VideoMailsViewController.m
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoMailsViewController.h"
#import "VideoVideoMailDataBuilder.h"
#import "VideoTabBarController.h"
#import "VideoMail.h"
//#import "UIImageView+WebCache.h"
#import "VideoComposeViewController.h"
#import "VideoMailTableCell.h"
#import "VideoMailStorage.h"
#import "VideoMailPlayViewController.h"


@interface VideoMailsViewController ()


@property (weak, nonatomic) IBOutlet UITabBarItem *tabButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *videoMailKeys;
@property (strong, nonatomic) NSDictionary *videoMails;
@property (weak, nonatomic) VideoMail *videoMailSelected;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) VideoMailStorage *videoMailStorage;
@end

@implementation VideoMailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.videoMailStorage == nil) {
        self.videoMailStorage = [[VideoMailStorage alloc] init];
    }
    //[self.videoMailStorage ClearContext];
    //return;
    //if (assetBrowser == nil) {
    //    assetBrowser = [AssetBrowserSource assetBrowserSource];
    //}
    //[assetBrowser buildSourceLibrary];


    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    NSArray *tmpArray = nil;
    self.videoMails = [self.videoMailStorage GetVideoMails:((VideoTabBarController *)self.tabBarController).tabBar.selectedItem.title WithKeys:&tmpArray];
    self.videoMailKeys = tmpArray;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    NSLog(@"VideoMailsViewController::ViewDidLoad Keys count: %d", [self.videoMailKeys count]);
    NSArray *urls = [NSArray arrayWithObjects:
                     @"assets-library://asset/asset.MOV?id=F0A3A8BD-4A59-43BE-B04E-034D2B82CC05&ext=MOV",
                     @"assets-library://asset/asset.MOV?id=8E475705-4C1F-41A2-9FB7-5B2F54E1FCCC&ext=MOV",
                     @"assets-library://asset/asset.MOV?id=157AFD17-C4CF-4D20-96FF-943F77D55C11&ext=MOV",
                     @"assets-library://asset/asset.MOV?id=D1CA8A4D-609B-4268-AA18-E163764155CC&ext=MOV",
                     @"assets-library://asset/asset.MOV?id=DC19E097-D407-4C02-B05B-FFE3C2E1D792&ext=MOV",
                     @"assets-library://asset/asset.MOV?id=04895427-30FF-49EC-A666-9599548E9179&ext=MOV",
                     @"assets-library://asset/asset.MOV?id=D076992D-EAEB-4451-91EE-117F5C7B5C6D&ext=MOV",
                     @"assets-library://asset/asset.MOV?id=5C6547C9-F9C7-4E32-B595-CF0C963E6A32&ext=MOV",
                     nil];
    NSInteger integer = 0;
    for (NSString *vmKey in self.videoMailKeys) {
        VideoMail* vMail = [self.videoMails objectForKey:vmKey];
        vMail.videoUrl = [NSURL URLWithString:[urls objectAtIndex:integer]];
        [self.videoMailStorage AddToStore:vMail];
        integer++;
    }
    //[self reload:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"VideoMailsViewController::ViewWillAppear:: Title: %@",((VideoTabBarController *)self.tabBarController).tabBar.selectedItem.title);
    self.tabBarController.title = ((VideoTabBarController *)self.tabBarController).tabBar.selectedItem.title;
}

- (void)reload:(__unused id)sender {
    ((VideoTabBarController *)self.tabBarController).session.gvmDelegate = self;
    NSLog(@"VideoMailsViewController::reload:: Title: %@",((VideoTabBarController *)self.tabBarController).tabBar.selectedItem.title);
    [((VideoTabBarController *)self.tabBarController).session GetVideoMails:((VideoTabBarController *)self.tabBarController).tabBar.selectedItem.title];
    [self.refreshControl beginRefreshing];
}

- (void)receivedVideoMails:(NSData *)response {
    
    NSArray *newVideoMails = [VideoVideoMailDataBuilder videoMailsFromJSON:response];
    NSMutableArray *newVideoMailKeys = [[NSMutableArray alloc] init];
    NSMutableDictionary* newVideoMailDic = [[NSMutableDictionary alloc] init];
    for (VideoMail *videoMail in newVideoMails) {
        [newVideoMailKeys addObject:videoMail.mhtKey];
        VideoMail *vMail = [self.videoMails objectForKey:videoMail.mhtKey];
        if ( vMail == nil ) {
            videoMail.folder = self.tabBarController.title;
            [newVideoMailDic setObject:videoMail forKey:videoMail.mhtKey];
            [self.videoMailStorage AddToStore:videoMail];
        }
        else {
            [newVideoMailDic setObject:vMail forKey:videoMail.mhtKey];
        }
    }
    self.videoMails = newVideoMailDic;
    self.videoMailKeys = newVideoMailKeys;
    [self.refreshControl endRefreshing];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    if([self.videoMails count] == 0) {
        self.errorMessage.hidden = NO;
        self.errorMessage.text = @"No videos send or received yet";
    }
    else {
        if ([self.errorMessage.text compare:@"No videos send or received yet"] == 0) {
            self.errorMessage.hidden = YES;
            self.errorMessage.text = @"";
        }
    }
}

- (void)fetchingVideoMailsFailedWithError:(NSError *)error {
    self.errorMessage.hidden = NO;
    self.errorMessage.text = @"Failed to fetch new videomails";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"table items count %d", [self.videoMails count]);
	return [self.videoMails count];
}

- (void) loadImageAsynchronously:(VideoMail *) videoMail InView:(UIImageView *)imageView {
    
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       
                       NSLog(@"Loading image: %@", videoMail.thumbnailUrl);
                       NSMutableData *data = [NSMutableData dataWithContentsOfURL:videoMail.thumbnailUrl];
                       if (data == nil) {
                           NSLog(@"Image load failed");
                           return;
                       } else {
                           NSLog(@"Image has loaded successfully.");
                       }
                       @try {
                           videoMail.thumbnailData = [[NSData alloc] initWithData:data];
                           [self.videoMailStorage AddToStore:videoMail];
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               imageView.image = [[UIImage alloc] initWithData:data];
                           });
                       }
                       @catch (NSException *exception) {
                           NSLog(@"VideoMailsVC::loadImageAsynchronously Exception %@", [exception reason]);
                       }
                   });
    
}

- (void)configureCell:(VideoMailTableCell*)cell forIndexPath:(NSIndexPath *)indexPath
{
	if ( cell == nil)
		return;
    
	VideoMail* videoMail = [self.videoMails objectForKey:[self.videoMailKeys objectAtIndex:indexPath.row]];
	[cell.subjectLabel setText:[videoMail.subject stringByRemovingPercentEncoding]];
    [cell.fromLabel setText:[videoMail.from stringByRemovingPercentEncoding]];
    [cell.dateLabel setText:[videoMail.date stringByRemovingPercentEncoding]];
    //[cell.sizeLabel setText:[videoMail.size stringByRemovingPercentEncoding]];
    /*if( indexPath.row == 0 ) {
        [cell.progressLabel setText:@"10%"];
        [cell.progressView setProgress:0.1 animated:NO];
        cell.unreadStatusImage.hidden = YES;
        cell.progressLabel.hidden = NO;
        cell.progressView.hidden = NO;
    }*/
    if( indexPath.row < 3 ) {
        cell.unreadStatusImage.hidden = NO;

    }
    
    @try {
        if (videoMail.thumbnailData != nil) {
            NSLog(@"Loading thumbnail from cache");
            cell.thumbnailView.image = [[UIImage alloc] initWithData:videoMail.thumbnailData];
            return;
        }
        
        if (videoMail.thumbnailUrl != nil) {
            NSLog(@"Loading thumbnail: %@", videoMail.thumbnailUrl);
            [self loadImageAsynchronously:videoMail InView:cell.thumbnailView];
            //[cell.thumbnailView setImageWithURL:videoMail.thumbnailUrl];
            return;
        }
        
        if (videoMail.thumbnailUrl == nil) {
            [((VideoTabBarController *)self.tabBarController).session generateThumbnailAsynchronously:videoMail InFolder:((VideoTabBarController *)self.tabBarController).tabBar.selectedItem.title completionHandler:^(void)
             {
                 if (videoMail.thumbnailUrl != nil) {
                     NSLog(@"Loading thumbnail: %@", videoMail.thumbnailUrl);
                     [NSThread sleepForTimeInterval:0.1*indexPath.row];
                     [self loadImageAsynchronously:videoMail InView:(UIImageView *)cell.thumbnailView];
                     //[cell.thumbnailView setImageWithURL:videoMail.thumbnailUrl];
                 }
                 else {
                     NSLog(@"Thumbnail url is nil");
                 }
             }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"VideoMailsVC::configureCell Exception %@", [exception reason]);
    }
}

// Customize the appearance of table view cells.
- (VideoMailTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"updating cell");
    static NSString *CellIdentifier = @"Cell";
    
	VideoMailTableCell *cell = nil;
    @try {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    @catch (NSException *exception) {
        NSLog(@"VideoMailsVC::cellForRowAtIndexPath Exception %@", [exception reason]);
    }
	if (cell == nil) {
        
		cell = [[VideoMailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[self configureCell:cell forIndexPath:indexPath];
	
	return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"VideoMailsVC:prepareForSegue %@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"PlaySegue"])
    {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        self.videoMailSelected = [self.videoMails objectForKey:[self.videoMailKeys objectAtIndex:indexPath.row]];
        VideoMailPlayViewController *vc = [segue destinationViewController];
        vc.session = ((VideoTabBarController *)self.tabBarController).session;
        vc.svmDelegate = (VideoTabBarController *)self.tabBarController;
     
        NSArray *items = [assetBrowser items];
        for (AssetBrowserItem* item in items) {
            NSLog(@"URL:%@", item.URL.absoluteString);
        }
        [vc setURL:[NSURL URLWithString:@"assets-library://asset/asset.MOV?id=BB675771-8153-4770-A46E-D0D2214F53DB&ext=MOV"]];
        [vc setSubject:[self.videoMailSelected.subject stringByRemovingPercentEncoding]];
        [vc setFrom:[self.videoMailSelected.from stringByRemovingPercentEncoding]];
        NSLog(@"subject:%@ from:%@",self.videoMailSelected.subject, self.videoMailSelected.from);
        NSLog(@"VideoTabBarVC::prepareForSegue URL:%@", ((AssetBrowserItem *)[[assetBrowser items] objectAtIndex:0]).URL.absoluteString);
        //[vc setURL:((AssetBrowserItem *)[[assetBrowser items] objectAtIndex:0]).URL];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

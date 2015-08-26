//
//  VideoSideBarViewController.m
//  Video
//
//  Created by MacMiniA on 16/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoSideBarViewController.h"
#import "VideoTabBarController.h"
#import "VideoComposeViewController.h"
#import "VideoViewController.h"
#import "SWRevealViewController.h"
#import "VideoMailsViewController.h"

@interface VideoSideBarViewController ()
@property (strong, nonatomic) NSArray *menuItems;
@end

@implementation VideoSideBarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.menuItems = @[@"title", @"inbox", @"sent", @"compose", @"settings", @"logout"];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2f alpha:0.2f];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.menuItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        // cell.backgroundColor = [UIColor clearColor];
    }
    //[cell.imageView setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [cell setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    return cell;
}



- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    //destViewController.title = [[self.menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    if ([[segue identifier] isEqualToString:@"ComposeSegue"])
    {
        VideoComposeViewController *vc = (VideoComposeViewController *) segue.destinationViewController;
        vc.session = ((VideoViewController *)((UINavigationController *)self.revealViewController.frontViewController).topViewController).session;
        vc.svmDelegate = ((UINavigationController *)self.revealViewController.frontViewController).topViewController;
    }
    
    if (([[segue identifier] isEqualToString:@"SettingsSegue"]) || ([[segue identifier] isEqualToString:@"ComposeSegue"]))
    {
      
        if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
            SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
            swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
                UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
                [navController pushViewController:dvc animated:NO ];
                [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated: YES];
            };
        }
        return;
    }
    
    if ([[segue identifier] isEqualToString:@"LogoutSegue"])
    {
        [((VideoViewController *)((UINavigationController *)self.revealViewController.frontViewController).topViewController).session Logout];
        if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
            SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
            
            swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
                [(UINavigationController *)self.revealViewController.frontViewController popViewControllerAnimated:YES];
                [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated: YES];
            };
        }
        return;
    }
    
    if (([[segue identifier] isEqualToString:@"InboxSegue"]) || ([[segue identifier] isEqualToString:@"SentSegue"]))
    {

        //[self PrintViewControllerType:self.revealViewController.frontViewController];
        //[self PrintViewControllerType:((UINavigationController *)self.revealViewController.frontViewController).topViewController];
        //[self PrintViewControllerType:((UINavigationController *)self.revealViewController.frontViewController).visibleViewController];
        VideoTabBarController *tbc = (VideoTabBarController *)(((UINavigationController *)self.revealViewController.frontViewController).topViewController);
        NSInteger selectedIndex = ([[segue identifier] isEqualToString:@"InboxSegue"]) ? 0 : 1;
        [tbc.delegate tabBarController:tbc shouldSelectViewController:[[tbc viewControllers] objectAtIndex:selectedIndex]];
        [tbc setSelectedIndex:selectedIndex];
        if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
            SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
            
            swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
                [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated: YES];
            };
        }
    }
    
}

- (void) PrintViewControllerType:(id) vc {
    if (vc == nil) {
        NSLog(@"Nil object");
    }
    if ([vc isKindOfClass: [VideoMailsViewController class]]) {
        NSLog(@"Object of type VideoMailsViewController");
    }
    else if ([vc isKindOfClass: [VideoViewController class]]) {
        NSLog(@"Object of type VideoViewController");
    }
    else if ([vc isKindOfClass: [VideoTabBarController class]]){
        NSLog(@"Object of type VideoTabBarController");
    }
    else if ([vc isKindOfClass: [UINavigationController class]]){
        NSLog(@"Object of type UINavigationController");
    }
    else if ([vc isKindOfClass:[SWRevealViewController class]]) {
        NSLog(@"Object of type SWRevealViewController");
    }
    else if ([vc isKindOfClass:[VideoSideBarViewController class]]) {
        NSLog(@"Object of type VideoSideBarViewController");
    }
    else {
        NSLog(@"Object type is unknown");
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

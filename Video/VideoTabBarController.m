//
//  VideoTabBarController.m
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoTabBarController.h"
#import "VideoComposeViewController.h"
#import "VideoMailsViewController.h"
#import "SWRevealViewController.h"

@interface VideoTabBarController ()

@property  (strong, nonatomic) NSMutableArray *tabBarButtonItems;

@end

@implementation VideoTabBarController

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
    
    // Change button color
    // self.sidebarButton.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"VideoTabBarVC::prepareForSegue %@", [segue identifier]);
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ComposeSegue"])
    {
        // Get reference to the destination view controller
        VideoComposeViewController *vc = [segue destinationViewController];
        vc.session = self.session;
        vc.svmDelegate = self;
    }    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if ([[tabBarController viewControllers] objectAtIndex:tabBarController.selectedIndex] == viewController)
    {
        NSLog(@"shouldSelectViewController no");
        return NO;
    }
    else
    {
        NSLog(@"shouldSelectViewController yes");
        return YES;
    }
}


- (void)SendVideoMailSuccess:(NSData *)response {
    [(UIActivityIndicatorView *)self.navigationItem.titleView stopAnimating];
    self.navigationItem.titleView = nil;
    self.title = self.selectedViewController.tabBarItem.title;
    NSLog(@"Videomail successfully sent");
}

- (void)SendVideoMailFailedWithError:(NSError *)error {
    [(UIActivityIndicatorView *)self.navigationItem.titleView stopAnimating];
    self.navigationItem.titleView = nil;
    self.title = self.selectedViewController.tabBarItem.title;
    NSLog(@"Sending videomail failed");
}

- (void)SendVideoMailInProgress {
    NSLog(@"Sending videomail");
  
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [aiView startAnimating];
    self.navigationItem.titleView = aiView;
}

@end

//
//  VideoViewController.m
//  Video
//
//  Created by MacMiniA on 20/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoMailsViewController.h"

@interface VideoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation VideoViewController

- (IBAction)LoginButton:(UIButton *)sender {
    NSLog(@"%s %s", [self.username.text UTF8String], [self.password.text UTF8String]);
    self.session = [[VideoSession alloc] initWithUserName:self.username.text WithPassWord:self.password.text];
    if ([self.session CreateSession] != 1) {
        self.errorMessage.text = @"Invalid username or password";
        self.errorMessage.hidden = NO;
    }
    else {
 
        [((VideoViewController *)[self.navigationController.viewControllers objectAtIndex:0]).settings setValue:self.username.text forKey:@"username"];
        [((VideoViewController *)[self.navigationController.viewControllers objectAtIndex:0]).settings setValue:self.password.text forKey:@"password"];
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"LoginSegue"]) {
        return self.session.authenticated;
    }
    // by default perform the segue transition
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"LoginSegue"])
    {
        // Get reference to the destination view controller
        VideoMailsViewController *vc = [segue destinationViewController];
        vc.session = self.session;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.errorMessage.hidden = YES;
    [[self.loginButton layer] setCornerRadius:3];
    self.navigationController.navigationBar.barTintColor = self.loginButton.backgroundColor;
    [[self.username layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.username layer] setBorderWidth:0.4];
    [[self.username layer] setCornerRadius:3];
    [[self.password layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.password layer] setBorderWidth:0.4];
    [[self.password layer] setCornerRadius:3];
    if (self.username.leftView == nil) {
        UIView *userPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.username.leftView = userPaddingView;
        UIView *passPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.password.leftView = passPaddingView;
        self.username.leftViewMode = self.password.leftViewMode = UITextFieldViewModeAlways;
    }

    if ( self.settingsPath == nil ) {
        self.settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        self.settings = [[NSMutableDictionary alloc] initWithContentsOfFile:self.settingsPath];
    }
    
    NSLog(@"Settings count:%luu", (unsigned long)[self.settings count]);
    NSLog(@"Settings window count:%lu", [((VideoViewController *)[self.navigationController.viewControllers objectAtIndex:0]).settings count]);
    for (NSString *key in self.settings) {
        NSLog(@"Key:%@ Value:%@", key, [self.settings objectForKey:key]);
    }
    if ( ( [[self.settings objectForKey:@"username"] length] != 0 ) &&
         ( [[self.settings objectForKey:@"password"] length] != 0 ) ) {
        [self.username setText:[self.settings objectForKey:@"username"]];
        [self.password setText:[self.settings objectForKey:@"password"]];
        self.session = [[VideoSession alloc] initWithUserName:self.username.text WithPassWord:self.password.text];
        if ( ([self.session CreateSession] == 1) &&
             (self.session.authenticated) ) {
            [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        }
    }
}


@end

//
//  VideoComposeViewController.m
//  Video
//
//  Created by MacMiniA on 21/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoComposeViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoAssetBrowserItem.h"
#import <AssertMacros.h>
#import "VideoSession.h"
#import "VideoAutoCompleteContactsBuilder.h"
#import "VideoContact.h"
#import "VideoStreamViewController.h"
#import "VideoPlayViewController.h"
#import "VideoTabBarController.h"

@interface VideoComposeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UITextField *toText;
@property (weak, nonatomic) IBOutlet UITableView *autoCompleteTable;
@property (weak, nonatomic) IBOutlet UITextField *subjectText;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;


@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) UIImage *deleteButtonImage;
@property (strong, nonatomic) UIImage *uploadButtonImage;
@end

@implementation VideoComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         self.searchString = [[NSString alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self.toText layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.subjectText layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.bodyText layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.toText layer] setBorderWidth:0.4];
    [[self.subjectText layer] setBorderWidth:0.4];
    [[self.bodyText layer] setBorderWidth:0.4];
    [[self.toText layer] setCornerRadius:3];
    [[self.subjectText layer] setCornerRadius:3];
    [[self.bodyText layer] setCornerRadius:3];
    if (self.toText.leftView == nil) {
        UIView *toPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.toText.leftView = toPaddingView;
    }
    if (self.subjectText.leftView == nil) {
        UIView *subjectPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.subjectText.leftView = subjectPaddingView;
    }
    self.toText.leftViewMode = self.subjectText.leftViewMode = UITextFieldViewModeAlways;
    
    [self.bodyText setDelegate:self];
    self.session.acDelegate = self;
    self.session.svmDelegate = self.svmDelegate;
    //[self.navigationItem setHidesBackButton:YES];
    
    self.playButton.hidden = YES;
    self.deleteButtonImage = [UIImage imageNamed:@"close_red2.png"];
    self.uploadButtonImage = [UIImage imageNamed:@"camera_green.png"];
    [self.autoCompleteTable setOpaque:YES];
    if (self.subject != nil && [self.subjectText.text length] == 0) {
        self.subjectText.text = self.subject;
    }
    if (self.videoUrl != nil) {
        AssetBrowserItem *assetItem = [[AssetBrowserItem alloc] initWithURL:self.videoUrl];
        
        CGFloat targetHeight = 64.0;
        CGFloat thumbnailScale = [[UIScreen mainScreen] scale];
        targetHeight *= thumbnailScale;
        
        CGFloat targetAspectRatio = 1.5;
        CGSize targetSize = CGSizeMake(targetHeight*targetAspectRatio, targetHeight);
        NSLog(@"Video URL: %@ Size: %ld", self.videoUrl.absoluteString, [[NSData dataWithContentsOfURL:self.videoUrl] length]);
        
        [assetItem generateThumbnailAsynchronouslyWithSize:targetSize fillMode:AssetBrowserItemFillModeCrop completionHandler:^(UIImage *thumbnail)
         {
             self.thumbnailView.image = thumbnail;
             self.uploadButton.imageView.image = self.deleteButtonImage;
             self.playButton.hidden = NO;
             NSLog(@"Image generated");
         }];
    }
}

//Actions start
- (IBAction)closeButton:(id)sender {
    self.closeButton.hidden = YES;
    self.errorMessage.text = @"";
    self.errorMessage.hidden = YES;
}

- (IBAction)ToFieldChanged:(id)sender {
    NSArray *toArray = [self.toText.text componentsSeparatedByString:@","];
    NSString *searchStr = [toArray.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( searchStr.length > 1 ) {
        if ( self.searchString != nil && self.searchString.length > 0 &&
            [searchStr compare:self.searchString options:0 range:NSMakeRange(0,self.searchString.length)] == NSOrderedSame) {
            NSLog(@"skipping autocomplete till previous one is loaded");
        }
        else {
            NSLog(@"getting contacts");
            self.searchString = searchStr;
            [self.session GetContacts:searchStr];
        }
    }
    else {
        self.autoCompleteTable.hidden = YES;
        self.contacts = nil;
        [self.autoCompleteTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}


- (IBAction)UploadVideo:(id)sender {
    if (self.thumbnailView.image == nil) {
       //[self startMediaBrowserFromViewController];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Choose existing video", @"Record new video", nil];
        [actionSheet showInView:self.view];
        
    }
    else {
        self.thumbnailView.image = nil;
        self.uploadButton.imageView.image = self.uploadButtonImage;
        self.playButton.hidden = YES;
        
    }
}


- (IBAction)SendVideoMail:(UIBarButtonItem *)sender {
    if ([self.toText text].UTF8String[0] == '\0') {
        self.errorMessage.text = @"To is empty";
        self.errorMessage.hidden = NO;
        self.closeButton.hidden = NO;
        NSLog(@"To is empty");
        return;
    }
    if ([self.subjectText text].UTF8String[0] == '\0') {
        self.errorMessage.text = @"Subject is empty";
        self.errorMessage.hidden = NO;
        self.closeButton.hidden = NO;
        NSLog(@"Subject is empty");
        return;
    }
    if ([self.bodyText text].UTF8String[0] == '\0') {
        self.errorMessage.text = @"Message is empty";
        self.errorMessage.hidden = NO;
        self.closeButton.hidden = NO;
        NSLog(@"Message is empty");
        return;
    }
 	NSLog(@"to:%@ subject:%@ message:%@", [self.toText text],
          [self.subjectText text], [self.bodyText text]);
    
    [self.session SendVideoMail:self.videoUrl To:self.toText.text WithSubject:self.subjectText.text WithBody:self.bodyText.text];
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[VideoTabBarController class]]) {
            [self.navigationController popToViewController:aViewController animated:NO];
        }
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelAction:(id)sender {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[VideoTabBarController class]]) {
            [self.navigationController popToViewController:aViewController animated:NO];
        }
    }
}
//Actions end

- (BOOL) startMediaBrowserFromViewController {
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) @"public.movie", nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
 
    mediaUI.delegate = self;
   
    [self presentViewController: mediaUI animated:YES completion:NULL];

    return YES;
}

- (BOOL) startCameraFromViewController {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) @"public.movie", nil];
    [self presentViewController:picker animated:YES completion:NULL];
    return YES;
    
}

// Callbacks for UIImagePickerController start
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Handle a movied picked from a photo album
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if (CFStringCompare ((CFStringRef) mediaType,(CFStringRef) @"public.movie", 0)
        != kCFCompareEqualTo) {
        NSLog(@"Video is not picked");
        [self dismissViewControllerAnimated:YES completion:^(void) {
            NSLog(@"completion of dismiss");
        }];
        return;
    }
    
    NSLog(@"Video picked");
    self.videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    
    AssetBrowserItem *assetItem = [[AssetBrowserItem alloc] initWithURL:self.videoUrl];
    
    CGFloat targetHeight = 64.0;
    CGFloat thumbnailScale = [[UIScreen mainScreen] scale];
    targetHeight *= thumbnailScale;
    
    CGFloat targetAspectRatio = 1.5;
    CGSize targetSize = CGSizeMake(targetHeight*targetAspectRatio, targetHeight);
    
    
    [assetItem generateThumbnailAsynchronouslyWithSize:targetSize fillMode:AssetBrowserItemFillModeCrop completionHandler:^(UIImage *thumbnail)
     {
         self.thumbnailView.image = thumbnail;
         self.uploadButton.imageView.image = self.deleteButtonImage;
         self.playButton.hidden = NO;
         NSLog(@"Image generated");
     }];
    
    
    [self dismissViewControllerAnimated:YES completion:^(void) {
        NSLog(@"completion of dismiss");
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Video pick cancelled2");
    [self dismissViewControllerAnimated:YES completion:^(void) {
        NSLog(@"completion of dismiss");
    }];
}
// Callbacks for UIImagePickerController end

// AutoComplete delegate methods start
- (void)receivedAutoCompleteJSON:(NSData *)response {
    self.contacts = [VideoAutoCompleteContactsBuilder contactsFromJSON:response];
    if (self.contacts.count == 0) {
        self.autoCompleteTable.hidden = YES;
        self.contacts = nil;
    }
    else {
        self.autoCompleteTable.hidden = NO;
        self.searchString = @"";
        NSLog(@"Reloading autoComplete Table");
    }
    [self.autoCompleteTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)fetchingAutoCompleteFailedWithError:(NSError *)error {
    NSLog(@"Fetching contacts failed %@", [error localizedDescription]);
}
// AutoComplete delegate methods end

// tableview datasource methods start
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection %lu", [self.contacts count]);
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRow");
    static NSString *simpleTableIdentifier = @"TableCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    VideoContact* contact = (VideoContact *)[self.contacts objectAtIndex:indexPath.row];
    NSMutableString *cellText = [[NSMutableString alloc] init];
    if (contact.fname != nil && contact.fname.length > 0) {
        [cellText appendString:contact.fname];
    }
    if (contact.lname != nil && contact.lname.length > 0) {
        [cellText appendFormat:@" %@", contact.lname];
    }
    if (contact.alias != nil && contact.alias.length > 0) {
        [cellText appendFormat:@" (%@)", contact.alias];
    }
    if (contact.email != nil && contact.email.length > 0) {
        [cellText appendFormat:@" <%@>", [contact.email stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    NSLog (@"%@", cellText);
    cell.textLabel.text = cellText;
    return cell;
}
// tableview datasource methods end

// tableview delegate methods start
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectTo = [((VideoContact *)[self.contacts objectAtIndex:indexPath.row]).email stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *toArray = [NSMutableArray arrayWithArray:[self.toText.text componentsSeparatedByString:@","]];
    [toArray removeLastObject];
    NSMutableString *updatedTo = [[NSMutableString alloc] init];
    for (NSString *to in toArray) {
        [updatedTo appendFormat:@"%@ , ", [to stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    [updatedTo appendFormat:@"%@ , ", selectTo];
    NSLog(@"%@ %@",selectTo, updatedTo);
    self.toText.text = updatedTo;
    self.autoCompleteTable.hidden = YES;
}
// tableview delegate methods end



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"Return pressed, do whatever you like here");
        [self.view endEditing:YES];
    
    }
    
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"The %@ button was tapped %lu", [actionSheet buttonTitleAtIndex:buttonIndex], buttonIndex);
    if ( buttonIndex == 0 ) {
        [self startMediaBrowserFromViewController];
    }
    else if (buttonIndex == 1 ) {
        [self startCameraFromViewController];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare for segue %@", [segue identifier]);

    if ([[segue identifier] isEqualToString:@"PlaySegue"])
    {
        VideoPlaybackViewController *vc = [segue destinationViewController];
        vc.hideChoose = YES;
        [vc setURL:self.videoUrl];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

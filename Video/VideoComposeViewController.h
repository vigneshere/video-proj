//
//  VideoComposeViewController.h
//  Video
//
//  Created by MacMiniA on 21/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSession.h"

@interface VideoComposeViewController : UIViewController <VideoAutoCompleteDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) VideoSession* session;
@property (weak, nonatomic) id <VideoSendMailDelegate> svmDelegate;
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) NSString *to;
@property (strong, nonatomic) NSString *subject;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end

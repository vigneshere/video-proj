//
//  VideoTabBarController.h
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSession.h"

@interface VideoTabBarController : UITabBarController <VideoSendMailDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) VideoSession *session;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

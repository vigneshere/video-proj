//
//  VideoViewController.h
//  Video
//
//  Created by MacMiniA on 20/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSession.h"

@interface VideoViewController : UIViewController
@property (strong, nonatomic)  VideoSession* session;
@property (strong, nonatomic) NSMutableDictionary *settings;
@property (strong, nonatomic) NSString *settingsPath;
@end

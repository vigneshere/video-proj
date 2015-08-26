//
//  VideoSession.h
//  Video
//
//  Created by MacMiniA on 20/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoAutoCompleteDelegate.h"
#import "VideoSendMailDelegate.h"
#import "VideoGetVideoMailDelegate.h"
#import "VideoMail.h"


@interface VideoSession : NSObject

@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString * password;
@property (nonatomic) BOOL authenticated;
@property (weak, nonatomic) id <VideoAutoCompleteDelegate> acDelegate;
@property (weak, nonatomic) id <VideoSendMailDelegate> svmDelegate;
@property (weak, nonatomic) id <VideoGetVideoMailDelegate> gvmDelegate;

- (int) CreateSession;
- (id) initWithUserName:(NSString *) username WithPassWord:(NSString *) password;
- (void) SendVideoMail:(NSURL *)videoUrl To:(NSString *)to WithSubject:(NSString *)subject
             WithBody:(NSString *)body;
- (void) GetContacts:(NSString *)searchStr;
- (void) GetVideoMails:(NSString *)folder;
- (void) Logout;
- (void)generateThumbnailAsynchronously:(VideoMail *)videoMail InFolder:(NSString *)folder completionHandler:(void (^)(void))handler;

@end

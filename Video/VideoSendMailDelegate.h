//
//  VideoSendMailDelegate.h
//  Video
//
//  Created by MacMiniA on 31/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoSendMailDelegate
- (void)SendVideoMailInProgress;
- (void)SendVideoMailSuccess:(NSData *)response;
- (void)SendVideoMailFailedWithError:(NSError *)error;
@end

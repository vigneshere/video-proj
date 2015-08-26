//
//  VideoGetVideoMailDelegate.h
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoGetVideoMailDelegate <NSObject>
- (void)receivedVideoMails:(NSData *)response;
- (void)fetchingVideoMailsFailedWithError:(NSError *)error;
@end

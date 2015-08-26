//
//  VideoMailStorage.h
//  Video
//
//  Created by MacMiniA on 15/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoMail.h"

@interface VideoMailStorage : NSObject

- (NSDictionary *) GetVideoMails:(NSString *)folder WithKeys:(NSArray **)keys;
- (void) AddToStore:(VideoMail *) videoMail;
- (void) ClearContext;

@end

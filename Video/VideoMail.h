//
//  VideoMail.h
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoMail : NSObject
@property (strong, nonatomic) NSString *folder;
@property (strong, nonatomic) NSString *mhtKey;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSData *thumbnailData;
@property (strong, nonatomic) NSURL *thumbnailUrl;
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) NSURL *videoAssetUrl;
@end

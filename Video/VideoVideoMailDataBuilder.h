//
//  VideoVideoMailDataBuilder.h
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoVideoMailDataBuilder : NSObject
+ (NSArray *)videoMailsFromJSON:(NSData *)objectNotation;
@end

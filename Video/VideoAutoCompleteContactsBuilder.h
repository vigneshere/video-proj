//
//  VideoAutoCompleteContactsBuilder.h
//  Video
//
//  Created by MacMiniA on 31/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VideoAutoCompleteContactsBuilder : NSObject
+ (NSArray *)contactsFromJSON:(NSData *)objectNotation;
@end

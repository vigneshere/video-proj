//
//  VideoAutoCompleteContactsBuilder.m
//  Video
//
//  Created by MacMiniA on 31/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoAutoCompleteContactsBuilder.h"
#import "VideoContact.h"
#import <objc/runtime.h>

@implementation VideoAutoCompleteContactsBuilder
+ (NSArray *)contactsFromJSON:(NSData *)objectNotation
{
    NSError *localError = nil;
    NSArray *results = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil || results == nil) {
        return nil;
    }

    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSLog(@"Count %lu", results.count);
    
    for (NSDictionary *contactDic in results) {
        if (![contactDic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        if ( [contactDic valueForKey:@"email"] == nil ) {
            continue;
        }
        VideoContact *contact = [[VideoContact alloc] init];
        for (NSString *key in contactDic) {
            NSLog(@"%@", key);
            if ([contact respondsToSelector:NSSelectorFromString(key)]) {
                [contact setValue:[contactDic valueForKey:key] forKey:key];
            }
        }
        
        [contacts addObject:contact];
    }
    
    return contacts;
}
@end
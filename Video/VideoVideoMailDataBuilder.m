//
//  VideoVideoMailDataBuilder.m
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoVideoMailDataBuilder.h"
#import "VideoMail.h"

@implementation VideoVideoMailDataBuilder
+ (NSArray *)videoMailsFromJSON:(NSData *)objectNotation {
    NSError *localError = nil;
        
    NSArray *results = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        NSLog(@"Error in JSON parsing %@", [localError localizedDescription]);
        return nil;
    }
    
    if (results == nil) {
        NSLog(@"Results is nil");
        return nil;
    }
    
    NSMutableArray *videomails = [[NSMutableArray alloc] init];
    NSLog(@"Mail Count %ld", results.count);

    for (NSArray *arr in results) {
        if([(NSString *)[arr objectAtIndex:9] compare:@"videomail"] == NSOrderedSame) {
            VideoMail *vm =  [[VideoMail alloc] init];
            vm.mhtKey = [arr objectAtIndex:0];
            vm.from = [arr objectAtIndex:1];
            vm.subject = [arr objectAtIndex:2];
            vm.date = [[arr objectAtIndex:3] substringToIndex:8];
            vm.size = [arr objectAtIndex:4];
            NSLog(@"MHTKey:%@ From:%@", vm.mhtKey, vm.from);
            [videomails addObject:vm];
        }
    }
    return videomails;
}
@end

//
//  VideoMailStorage.m
//  Video
//
//  Created by MacMiniA on 15/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoMailStorage.h"

#import <CoreData/CoreData.h>

@interface VideoMailStorage()
    @property (strong, nonatomic) NSDictionary *videoMailObjects;
@end

@implementation VideoMailStorage

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void) ClearContext {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"VideoMail"];
    NSArray* videomails = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"count of videomails in persistent storage: %lu", [videomails count]);
    for (NSManagedObject *videoMailObj in videomails) {
        [context deleteObject:videoMailObj];
    }
    NSError *error = nil;
    [context save:&error];
}

- (NSDictionary *) GetVideoMails : (NSString *) folder WithKeys:(NSArray **) keys {
    
    NSMutableDictionary *videoMailDic = [[NSMutableDictionary alloc] init];
    @try {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"VideoMail"];
        NSArray* videomails = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
        NSLog(@"count of videomails in persistent storage: %lu", [videomails count]);
        
        NSMutableArray *vmKeys = [[NSMutableArray alloc] init];
        if (self.videoMailObjects == nil) {
            self.videoMailObjects = [[NSMutableDictionary alloc] init];
        }
        for (NSManagedObject *videoMailObj in videomails) {
            if ( [videoMailObj valueForKey:@"mhtKey"] == nil ) {
                continue;
            }
            VideoMail* videoMail = [[VideoMail alloc] init];
            NSData *imgData = [videoMailObj valueForKey:@"thumbnail"];
            NSLog(@"subject: %@ mhtkey:%@ thumbnail:%d", [videoMailObj valueForKey:@"subject"], [videoMailObj valueForKey:@"mhtKey"], (imgData == nil));
            videoMail.subject = [videoMailObj valueForKey:@"subject"];
            videoMail.from = [videoMailObj valueForKey:@"from"];
            videoMail.mhtKey = [videoMailObj valueForKey:@"mhtKey"];
            videoMail.thumbnailUrl = [NSURL URLWithString:[videoMailObj valueForKey:@"thumbnailUrl"]];
            videoMail.videoUrl = [NSURL URLWithString:[videoMailObj valueForKey:@"videoUrl"]];
            videoMail.videoAssetUrl = [NSURL URLWithString:[videoMailObj valueForKey:@"videoAssetUrl"]];
            if ( imgData != nil ) {
                videoMail.thumbnailData = [[NSData alloc] initWithData:imgData];
            }
            videoMail.date = [videoMailObj valueForKey:@"date"];
            videoMail.size = [videoMailObj valueForKey:@"size"];
            videoMail.folder = [videoMailObj valueForKey:@"folder"];
            if ( [videoMail.folder compare:folder] == NSOrderedSame ) {
                [videoMailDic setValue:videoMail forKey:videoMail.mhtKey];
                [vmKeys addObject:videoMail.mhtKey];
            }
            [self.videoMailObjects setValue:videoMail forKey:videoMail.mhtKey];
        }
        *keys = [NSArray arrayWithArray:vmKeys];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", [exception reason]);
    }
    return videoMailDic;
}

- (void) AddToStore:(VideoMail *) videoMail {
    
    if(videoMail.mhtKey == nil) {
        NSLog(@"AddToStore:: Null key");
        return;
    }
    @try {
        NSManagedObjectContext *context = [self managedObjectContext];
        if (self.videoMailObjects == nil) {
            self.videoMailObjects = [[NSMutableDictionary alloc] init];
        }
        NSManagedObject *videoMailObj = [self.videoMailObjects valueForKey:videoMail.mhtKey];
        BOOL addNewObj = NO;
        if (videoMailObj == nil) {
            videoMailObj = [NSEntityDescription insertNewObjectForEntityForName:@"VideoMail" inManagedObjectContext:context];
            addNewObj = YES;
            NSLog(@"AddToStore:: New Obj:%@ thumbnail:%d", videoMail.mhtKey, (videoMail.thumbnailData == nil));
        }
        else {
            //[context deleteObject:videoMailObj];
            NSLog(@"AddToStore:: Existing Obj:%@ thumbnail:%d", videoMail.mhtKey, (videoMail.thumbnailData == nil));
        }
        
        [videoMailObj setValue:videoMail.subject forKey:@"subject"];
        [videoMailObj setValue:videoMail.from forKey:@"from"];
        [videoMailObj setValue:videoMail.mhtKey forKey:@"mhtKey"];
        if (videoMail.thumbnailData != nil) {
            [videoMailObj setValue:UIImageJPEGRepresentation([UIImage imageWithData:videoMail.thumbnailData],0)  forKey:@"thumbnail"];
        }
        [videoMailObj setValue:videoMail.thumbnailUrl.absoluteString forKey:@"thumbnailUrl"];
        [videoMailObj setValue:videoMail.videoUrl.absoluteString forKey:@"videoUrl"];
        [videoMailObj setValue:videoMail.videoAssetUrl.absoluteString forKey:@"videoAssetUrl"];
        [videoMailObj setValue:videoMail.date forKey:@"date"];
        [videoMailObj setValue:videoMail.size forKey:@"size"];
        [videoMailObj setValue:videoMail.folder forKey:@"folder"];
        if (addNewObj == YES) {
            NSLog(@"AddToStore:: Adding: %@", videoMail.mhtKey);
            [self.videoMailObjects setValue:videoMailObj forKey:videoMail.mhtKey];
        }
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"AddToStore:: Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        for (NSString *mhtKey in self.videoMailObjects) {
            NSLog(@"AddToStore:: key:%@", mhtKey);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"AddToStore:: Exception %@", [exception reason]);
    }
    
}

@end

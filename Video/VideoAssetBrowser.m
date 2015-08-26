/*
 File: AssetBrowserSource.m
 Abstract: Represents a source like the camera roll and vends AssetBrowserItems.
 Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011-2013 Apple Inc. All Rights Reserved.
 
 */

#import "VideoAssetBrowser.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetBrowserSource ()

@property (nonatomic, copy) NSArray *items; // NSArray of AssetBrowserItems

@end


@implementation AssetBrowserSource

@synthesize items = assetBrowserItems;


+ (AssetBrowserSource*)assetBrowserSource
{
	return [[self alloc] init];
}

- (id)init
{
	if ((self = [super init])) {
		assetBrowserItems = [NSArray array];
		enumerationQueue = dispatch_queue_create("Browser Enumeration Queue", DISPATCH_QUEUE_SERIAL);
		dispatch_set_target_queue(enumerationQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
	}
	return self;
}

- (void)updateBrowserItemsAndSignalDelegate:(NSArray*)newItems
{
	self.items = newItems;
    
	/* Ideally we would reuse the AssetBrowserItems which remain unchanged between updates.
	 This could be done by maintaining a dictionary of assetURLs -> AssetBrowserItems.
	 This would also allow us to more easily tell our delegate which indices were added/removed
	 so that it could animate the table view updates. */
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(assetBrowserSourceItemsDidChange:)]) {
		[self.delegate assetBrowserSourceItemsDidChange:self];
	}
}

- (void)dealloc
{

	//dispatch_release(enumerationQueue);
	
	if (assetsLibrary) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];

	}

}

- (void)updateAssetsLibrary
{
	NSMutableArray *assetItems = [NSMutableArray arrayWithCapacity:0];
	ALAssetsLibrary *assetLibrary = assetsLibrary;
	NSLog(@"Updating assests library");
	[assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSLog(@"inside group");
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:
             ^(ALAsset *asset, NSUInteger index, BOOL *stopIt)
             {
                 if (asset) {
                     NSLog(@"inside asset");
                     ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                     NSString *uti = [defaultRepresentation UTI];
                     NSURL *URL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                     NSString *title = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"Video", nil), [assetItems count]+1];
                     AssetBrowserItem *item = [[AssetBrowserItem alloc] initWithURL:URL title:title];
                     
                     [assetItems addObject:item];
                 }
             }];
        }
		// group == nil signals we are done iterating.
		else {
            NSLog(@"inside group nil");
			dispatch_async(dispatch_get_main_queue(), ^{
				[self updateBrowserItemsAndSignalDelegate:assetItems];
			});
		}
	}
                              failureBlock:^(NSError *error) {
                                  NSLog(@"error enumerating AssetLibrary groups %@\n", error);
                              }];
}

- (void)assetsLibraryDidChange:(NSNotification*)changeNotification
{
	[self updateAssetsLibrary];
}

- (void)buildAssetsLibrary
{
	assetsLibrary = [[ALAssetsLibrary alloc] init];
	[self updateAssetsLibrary];
}


- (void)buildSourceLibrary
{
    NSLog(@"building Source Library");
	if (haveBuiltSourceLibrary)
		return;
    [self buildAssetsLibrary];
    NSLog(@"building Source Library");
	haveBuiltSourceLibrary = YES;
}

@end

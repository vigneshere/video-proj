//
//  VideoStreamViewController.h
//  Video
//
//  Created by MacMiniA on 01/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSession.h"
#import "VideoAssetBrowser.h"

@interface VideoStreamViewController : UIViewController <VideoSendMailDelegate, AssetBrowserSourceDelegate> {
    
@private
    AssetBrowserSource *assetBrowser;
    BOOL haveBuiltSourceLibraries;

	BOOL thumbnailAndTitleGenerationIsRunning;
	BOOL thumbnailAndTitleGenerationEnabled;
	
	CGFloat lastTableViewYContentOffset;
	BOOL lastTableViewScrollDirection;
	
	CGFloat thumbnailScale;
   
}
@property (weak, nonatomic) VideoSession* session;
@end

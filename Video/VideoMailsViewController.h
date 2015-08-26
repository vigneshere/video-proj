//
//  VideoMailsViewController.h
//  Video
//
//  Created by MacMiniA on 13/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoGetVideoMailDelegate.h"
#import "VideoSession.h"
#import "VideoAssetBrowser.h"

@interface VideoMailsViewController : UIViewController <VideoGetVideoMailDelegate>{
@private
    AssetBrowserSource *assetBrowser;
}
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) VideoSession* session;
@end

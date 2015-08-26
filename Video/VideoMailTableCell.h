//
//  VideoMailTableCell.h
//  Video
//
//  Created by MacMiniA on 14/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoMailTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *unreadStatusImage;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@end

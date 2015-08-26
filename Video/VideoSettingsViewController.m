//
//  VideoSettingsViewController.m
//  Video
//
//  Created by MacMiniA on 16/02/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoSettingsViewController.h"
#import "VideoViewController.h"

@interface VideoSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *uploadUseCellularData;
@property (weak, nonatomic) IBOutlet UISwitch *saveCameraRoll;
@property (weak, nonatomic) IBOutlet UISwitch *downloadInBackground;
@property (weak, nonatomic) IBOutlet UILabel *storageLimit;
@property (weak, nonatomic) IBOutlet UISlider *storageLimitSlide;
@property (weak, nonatomic) IBOutlet UISwitch *downloadUseCellularData;
@property (weak, nonatomic) NSMutableDictionary *settingDictionary;
@end

@implementation VideoSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)DoneAction:(id)sender {
    [self.settingDictionary writeToFile:((VideoViewController *)[self.navigationController.viewControllers objectAtIndex:0]).settingsPath atomically:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    if (self.settingDictionary == nil) {
        self.settingDictionary = ((VideoViewController *)[self.navigationController.viewControllers objectAtIndex:0]).settings;
    }
    NSLog(@"Settings window count:%lu", [((VideoViewController *)[self.navigationController.viewControllers objectAtIndex:0]).settings count]);
    NSLog(@"Settings count: %lu", [self.settingDictionary count]);
    for (NSString *key in self.settingDictionary) {
        NSLog(@"Key:%@ Value:%@", key, [self.settingDictionary objectForKey:key]);
    }
    self.uploadUseCellularData.on = [[self.settingDictionary objectForKey:@"uploadOverCellularData"] integerValue];
    self.downloadUseCellularData.on = [[self.settingDictionary objectForKey:@"downloadOverCellularData"] integerValue];
    self.saveCameraRoll.on = [[self.settingDictionary objectForKey:@"saveToCameraRoll"] integerValue];
    self.downloadInBackground.on = [[self.settingDictionary objectForKey:@"downloadInBackground"] integerValue];
    [self.storageLimit setText:[NSString stringWithFormat:@"%d MB", [[self.settingDictionary objectForKey:@"storageLimit"] integerValue]]];
    [self.storageLimitSlide setValue:[[self.settingDictionary objectForKey:@"storageLimit"] floatValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadUseCellularDataSwitch:(id)sender {
    [self.settingDictionary setObject:[NSString stringWithFormat:@"%d",self.uploadUseCellularData.on] forKey:@"uploadOverCellularData"];
}

- (IBAction)saveCameraRollSwitch:(id)sender {
    [self.settingDictionary setObject:[NSString stringWithFormat:@"%d",self.saveCameraRoll.on] forKey:@"saveToCameraRoll"];
}

- (IBAction)backgroundDownloadSwitch:(id)sender {
    [self.settingDictionary setObject:[NSString stringWithFormat:@"%d",self.downloadInBackground.on] forKey:@"downloadInBackground"];
}

- (IBAction)storageLimitSlide:(id)sender {
    [self.storageLimit setText:[NSString stringWithFormat:@"%d MB", (int)self.storageLimitSlide.value]];
    [self.settingDictionary setObject:[NSString stringWithFormat:@"%f",self.storageLimitSlide.value] forKey:@"storageLimit"];
}

- (IBAction)downloadUseCellDataSwitch:(id)sender {
        [self.settingDictionary setObject:[NSString stringWithFormat:@"%d",self.downloadUseCellularData.on] forKey:@"downloadOverCellularData"];
}


@end

//
//  MainViewController.h
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStatusBarNotification.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UISlider *sliderDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblAnimationDuration;
@property (weak, nonatomic) IBOutlet UISlider *sliderAnimationDuration;
@property (weak, nonatomic) IBOutlet UITextField *txtNotificationMessage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segFromStyle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segToStyle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notificationStyle;

@property (strong, nonatomic) CWStatusBarNotification *notification;

- (IBAction)sliderDurationChanged:(UISlider *)sender;
- (IBAction)sliderAnimationDurationChanged:(UISlider *)sender;
- (IBAction)btnShowNotificationPressed:(UIButton *)sender;
- (IBAction)btnShowCustomNotificationPressed:(UIButton *)sender;

@end

//
//  MainViewController.m
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

#pragma mark - Superclass Methods Override -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"CWStatusBarNotification";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIFont *font = [UIFont boldSystemFontOfSize:10.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    [self updateDurationLabel];
    [self.segToStyle setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.segFromStyle setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    // initialize CWNotification
    self.notification = [CWStatusBarNotification new];
}

#pragma mark - Private APIs -
#pragma mark Helpers

- (void)updateDurationLabel
{
    self.lblDuration.text = [NSString stringWithFormat:@"%.2f seconds", self.sliderDuration.value];
}

#pragma mark Actions

- (IBAction)sliderDurationChanged:(UISlider *)sender
{
    [self updateDurationLabel];
}

- (IBAction)textColorChange:(UISegmentedControl *)sender {
    UIColor *textColor = nil;
    switch (sender.selectedSegmentIndex) {
        case 0:
            textColor = [UIColor whiteColor];
            break;
            
        case 1:
            textColor = [UIColor blackColor];
            break;
            
        case 2:
            textColor = [UIColor redColor];
            break;
            
        case 3:
            textColor = [UIColor orangeColor];
            break;
            
        case 4:
            textColor = [UIColor greenColor];
            break;
            
        default:
            textColor = sender.tintColor;
            break;
    }
    
    NSMutableDictionary *attributes = [self.notification.textAttributes mutableCopy];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    self.notification.textAttributes = attributes;
}

- (IBAction)backgroundColorChanged:(UISegmentedControl *)sender {
    UIColor *backgroundColor = nil;
    switch (sender.selectedSegmentIndex) {
        case 0:
            backgroundColor = self.view.tintColor;
            break;
            
        case 1:
            backgroundColor = [UIColor whiteColor];
            break;
            
        case 2:
            backgroundColor = [UIColor blackColor];
            break;
            
        case 3:
            backgroundColor = [UIColor redColor];
            break;
            
        case 4:
            backgroundColor = [UIColor yellowColor];
            break;
            
        default:
            backgroundColor = sender.tintColor;
            break;
    }
    
    NSMutableDictionary *attributes = [self.notification.textAttributes mutableCopy];
    [attributes setObject:backgroundColor forKey:NSBackgroundColorAttributeName];
    self.notification.textAttributes = attributes;
}

- (IBAction)btnShowNotificationPressed:(UIButton *)sender
{
    self.notification.notificationAnimationOutStyle = self.segToStyle.selectedSegmentIndex;
    self.notification.notificationAnimationInStyle = self.segFromStyle.selectedSegmentIndex;
    
    [self.notification displayNotificationWithMessage:self.txtNotificationMessage.text
                                          forDuration:self.sliderDuration.value];
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self btnShowNotificationPressed:nil];
    
    return YES;
}

@end

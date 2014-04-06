//
//  AppDelegate.m
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

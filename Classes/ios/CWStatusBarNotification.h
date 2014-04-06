//
//  CWStatusBarNotification
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollLabel : UILabel

- (CGFloat)scrollTime;

@end

@interface CWStatusBarNotification : NSObject

typedef NS_ENUM(NSInteger, CWNotificationStyle) {
    CWNotificationStyleStatusBarNotification,
    CWNotificationStyleNavigationBarNotification
};

typedef NS_ENUM(NSInteger, CWNotificationAnimationStyle) {
    CWNotificationAnimationStyleTop,
    CWNotificationAnimationStyleBottom,
    CWNotificationAnimationStyleLeft,
    CWNotificationAnimationStyleRight
};

typedef NS_ENUM(NSInteger, CWNotificationAnimationType) {
    CWNotificationAnimationTypeReplace,
    CWNotificationAnimationTypeOverlay
};

@property (strong, nonatomic) ScrollLabel *notificationLabel;
@property (assign, nonatomic) BOOL multiline;

@property (copy, nonatomic) NSDictionary *textAttributes; // Uses the same attributes as NSAttributedString.
@property (assign, nonatomic) CGFloat notificationLabelHeight;

@property (strong, nonatomic) UIColor *notificationLabelBackgroundColor __deprecated;
@property (strong, nonatomic) UIColor *notificationLabelTextColor __deprecated;
@property (strong, nonatomic) UIFont *notificationLabelFont __deprecated;

@property (strong, nonatomic) UIView *statusBarView;
@property (strong, nonatomic) UIWindow *notificationWindow;

@property (assign, nonatomic) BOOL notificationIsShowing __deprecated;
@property (assign, nonatomic, readonly, getter = isShowing) BOOL showing;
@property (assign, nonatomic) CWNotificationAnimationStyle notificationStyle;
@property (assign, nonatomic) CWNotificationAnimationStyle notificationAnimationInStyle;
@property (assign, nonatomic) CWNotificationAnimationStyle notificationAnimationOutStyle;
@property (assign, nonatomic) CWNotificationAnimationType notificationAnimationType;

- (void)dismissNotification;
- (void)displayNotificationWithMessage:(NSString *)message forDuration:(CGFloat)duration;
- (void)displayNotificationWithMessage:(NSString *)message completion:(void (^)(void))completion;

@end

//
//  CWStatusBarNotification
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(void);

@interface ScrollLabel : UILabel
- (CGFloat)scrollTime;
@end

@interface CWWindowContainer : UIWindow
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
@property (strong, nonatomic) UIColor *notificationLabelBackgroundColor;
@property (strong, nonatomic) UIColor *notificationLabelTextColor;
@property (assign, nonatomic) CGFloat notificationLabelHeight;
@property (assign, nonatomic) BOOL multiline;

@property (strong, nonatomic) UIView *statusBarView;

@property (copy, nonatomic) CompletionBlock notificationTappedBlock;

@property (nonatomic) CWNotificationAnimationStyle notificationStyle;
@property (nonatomic) CWNotificationAnimationStyle notificationAnimationInStyle;
@property (nonatomic) CWNotificationAnimationStyle notificationAnimationOutStyle;
@property (nonatomic) CWNotificationAnimationType notificationAnimationType;
@property (nonatomic) BOOL notificationIsShowing;
@property (nonatomic) BOOL notificationIsDismissing;

@property (strong, nonatomic) CWWindowContainer *notificationWindow;

- (void)displayNotificationWithMessage:(NSString *)message forDuration:(NSTimeInterval)duration;
- (void)displayNotificationWithMessage:(NSString *)message completion:(void (^)(void))completion;
- (void)displayNotificationWithMessage:(NSString *)message minimumDuration:(NSTimeInterval)minimumDuration completion:(void (^)(void))completion;
- (void)dismissNotification;

@end

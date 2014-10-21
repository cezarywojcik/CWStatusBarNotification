//
//  CWStatusBarNotification
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CWCompletionBlock)(void);

@interface ScrollLabel : UILabel
- (CGFloat)scrollTime;
@end

@interface CWWindowContainer : UIWindow

@property (assign, nonatomic) CGFloat notificationHeight;

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
@property (strong, nonatomic) UIView *customView;
@property (assign, nonatomic) BOOL multiline;

@property (strong, nonatomic) UIView *statusBarView;

@property (copy, nonatomic) CWCompletionBlock notificationTappedBlock;

@property (nonatomic) CWNotificationStyle notificationStyle;
@property (nonatomic) CWNotificationAnimationStyle notificationAnimationInStyle;
@property (nonatomic) CWNotificationAnimationStyle notificationAnimationOutStyle;
@property (nonatomic) CWNotificationAnimationType notificationAnimationType;
@property (nonatomic) BOOL notificationIsShowing;
@property (nonatomic) BOOL notificationIsDismissing;

@property (strong, nonatomic) CWWindowContainer *notificationWindow;

- (void)displayNotificationWithMessage:(NSString *)message forDuration:(CGFloat)duration;
- (void)displayNotificationWithMessage:(NSString *)message completion:(void (^)(void))completion;
- (void)displayNotificationWithView:(UIView *)view forDuration:(CGFloat)duration;
- (void)displayNotificationWithView:(UIView *)view completion:(void (^)(void))completion;
- (void)dismissNotification;
- (void)dismissNotificationWithCompletion:(void(^)(void))completion;

@end

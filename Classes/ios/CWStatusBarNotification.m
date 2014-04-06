//
//  CWStatusBarNotification.m
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "CWStatusBarNotification.h"

#define STATUS_BAR_ANIMATION_LENGTH 0.25f
#define SCROLL_SPEED 40.0f
#define SCROLL_DELAY 1.0f
#define PADDING 10.0f

@implementation CWStatusBarNotification

#pragma mark - Superclass Methods Override -

- (instancetype)init {
    self = [super init];
    if (self) {
        // set defaults
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UIColor *tintColor = window.tintColor ?: [self.class defaultBackgroundColor];
        
        self.textAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]],
                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSBackgroundColorAttributeName: tintColor};
        
        self.notificationStyle = CWNotificationStyleStatusBarNotification;
        self.notificationAnimationType = CWNotificationAnimationTypeReplace;
        self.notificationAnimationInStyle = CWNotificationAnimationStyleBottom;
        self.notificationAnimationOutStyle = CWNotificationAnimationStyleBottom;
    }
    return self;
}

#pragma mark - Public APIs -

- (void)dismissNotification
{
    if (self.notificationIsShowing) {
        [self secondFrameChange];
        [UIView animateWithDuration:STATUS_BAR_ANIMATION_LENGTH animations:^{
            [self thirdFrameChange];
        } completion:^(BOOL finished) {
            [self.notificationLabel removeFromSuperview];
            [self.statusBarView removeFromSuperview];
            [self setNotificationIsShowing:NO];
            [self setNotificationWindow:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationDidChangeStatusBarOrientationNotification
                                                          object:nil];
        }];
    }
}

- (void)displayNotificationWithMessage:(NSString *)message forDuration:(CGFloat)duration
{
    [self displayNotificationWithMessage:message completion:^{
        double delayInSeconds = duration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissNotification];
        });
    }];
}

- (void)displayNotificationWithMessage:(NSString *)message completion:(void (^)(void))completion
{
    if (!self.notificationIsShowing) {
        self.notificationIsShowing = YES;
        
        // create UIWindow
        [self setupNotificationWindow];
        
        // create UILabel
        [self setupNotificationLabelWithMessage:message];
        
        // create status bar view
        [self setupStatusBarView];
        
        // add label to window
        [self.notificationWindow.rootViewController.view addSubview:self.notificationLabel];
        [self.notificationWindow.rootViewController.view bringSubviewToFront:self.notificationLabel];
        [self.notificationWindow setHidden:NO];
        
        // checking for screen orientation change
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        // animate
        [UIView animateWithDuration:STATUS_BAR_ANIMATION_LENGTH animations:^{
            [self firstFrameChange];
        } completion:^(BOOL finished) {
            double delayInSeconds = [self.notificationLabel scrollTime];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [completion invoke];
            });
        }];
    }
    else {
        // only update the displayed text
        self.notificationLabel.attributedText = [[NSAttributedString alloc] initWithString:message
                                                                                attributes:self.textAttributes];
    }
}

#pragma mark - Private APIs -
#pragma mark Helpers

- (void)setupNotificationWindow
{
    self.notificationWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.notificationWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.notificationWindow.rootViewController.view.bounds = [self notificationLabelFrame];
    self.notificationWindow.rootViewController = [UIViewController new];
    self.notificationWindow.backgroundColor = [UIColor clearColor];
    self.notificationWindow.windowLevel = UIWindowLevelStatusBar;
    self.notificationWindow.userInteractionEnabled = NO;
}

- (void)setupStatusBarView
{
    self.statusBarView = [[UIView alloc] initWithFrame:[self notificationLabelFrame]];
    self.statusBarView.clipsToBounds = YES;
    
    if (self.notificationAnimationType == CWNotificationAnimationTypeReplace) {
        UIView *statusBarImageView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
        [self.statusBarView addSubview:statusBarImageView];
    }
    
    [self.notificationWindow.rootViewController.view addSubview:self.statusBarView];
    [self.notificationWindow.rootViewController.view sendSubviewToBack:self.statusBarView];
}

- (void)setupNotificationLabelWithMessage:(NSString *)message
{
    self.notificationLabel = [ScrollLabel new];
    self.notificationLabel.adjustsFontSizeToFitWidth = NO;
    self.notificationLabel.numberOfLines = self.multiline ? 0 : 1;
    self.notificationLabel.textAlignment = NSTextAlignmentCenter;
    self.notificationLabel.attributedText = [[NSAttributedString alloc] initWithString:message
                                                                            attributes:self.textAttributes];
    self.notificationLabel.backgroundColor = [self.textAttributes objectForKey:NSBackgroundColorAttributeName];
    
    switch (self.notificationAnimationInStyle) {
        case CWNotificationAnimationStyleTop:
            self.notificationLabel.frame = [self notificationLabelTopFrame];
            break;
            
        case CWNotificationAnimationStyleBottom:
            self.notificationLabel.frame = [self notificationLabelBottomFrame];
            break;
            
        case CWNotificationAnimationStyleLeft:
            self.notificationLabel.frame = [self notificationLabelLeftFrame];
            break;
            
        case CWNotificationAnimationStyleRight:
            self.notificationLabel.frame = [self notificationLabelRightFrame];
            break;
    }
}

#pragma mark Colors

+ (UIColor *)defaultBackgroundColor {
    return [UIColor colorWithRed:0.082f green:0.478f blue:0.984f alpha:1.0f];
}

#pragma mark Dimensions

- (CGFloat)statusBarHeight {
    if (self.notificationLabelHeight > 0) {
        return self.notificationLabelHeight;
    }
    else {
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
        }
        
        return statusBarHeight > 0 ? statusBarHeight : 20;
    }
}

- (CGFloat)statusBarWidth {
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIScreen mainScreen].bounds.size.width;
    }
    else {
        return [UIScreen mainScreen].bounds.size.height;
    }
}

- (CGRect)notificationLabelFrame {
    return CGRectMake(0, 0, [self statusBarWidth], [self calculateNotificationLabelHeight]);
}

- (CGFloat)calculateNavigationBarHeight {
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ||
        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 44.0f;
    }
    else {
        return 30.0f;
    }
}

- (CGFloat)calculateNotificationLabelHeight {
    switch (self.notificationStyle) {
        case CWNotificationStyleStatusBarNotification:
            return [self statusBarHeight];
        case CWNotificationStyleNavigationBarNotification:
            return [self statusBarHeight] + [self calculateNavigationBarHeight];
        default:
            return [self statusBarHeight];
    }
}

- (CGRect)notificationLabelTopFrame {
    return CGRectMake(0, -[self calculateNotificationLabelHeight], [self statusBarWidth], [self calculateNotificationLabelHeight]);
}

- (CGRect)notificationLabelLeftFrame {
    return CGRectMake(-[self statusBarWidth], 0, [self statusBarWidth], [self calculateNotificationLabelHeight]);
}

- (CGRect)notificationLabelRightFrame {
    return CGRectMake([self statusBarWidth], 0, [self statusBarWidth], [self calculateNotificationLabelHeight]);
}

- (CGRect)notificationLabelBottomFrame {
    return CGRectMake(0, [self calculateNotificationLabelHeight], [self statusBarWidth], 0);
}

#pragma mark Screen Orientation Change Support

- (void)screenOrientationChanged {
    self.notificationLabel.frame = [self notificationLabelFrame];
    self.statusBarView.hidden = YES;
}

#pragma mark Frame Changes Support

- (void)firstFrameChange
{
    self.notificationLabel.frame = [self notificationLabelFrame];
    switch (self.notificationAnimationInStyle) {
        case CWNotificationAnimationStyleTop:
            self.statusBarView.frame = [self notificationLabelBottomFrame];
            break;
            
        case CWNotificationAnimationStyleBottom:
            self.statusBarView.frame = [self notificationLabelTopFrame];
            break;
            
        case CWNotificationAnimationStyleLeft:
            self.statusBarView.frame = [self notificationLabelRightFrame];
            break;
            
        case CWNotificationAnimationStyleRight:
            self.statusBarView.frame = [self notificationLabelLeftFrame];
            break;
    }
}

- (void)secondFrameChange
{
    switch (self.notificationAnimationOutStyle) {
        case CWNotificationAnimationStyleTop:
            self.statusBarView.frame = [self notificationLabelBottomFrame];
            break;
            
        case CWNotificationAnimationStyleBottom:
            self.statusBarView.frame = [self notificationLabelTopFrame];
            self.notificationLabel.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
            self.notificationLabel.center = CGPointMake(self.notificationLabel.center.x, [self calculateNotificationLabelHeight]);
            break;
            
        case CWNotificationAnimationStyleLeft:
            self.statusBarView.frame = [self notificationLabelRightFrame];
            break;
            
        case CWNotificationAnimationStyleRight:
            self.statusBarView.frame = [self notificationLabelLeftFrame];
            break;
    }
}

- (void)thirdFrameChange
{
    self.statusBarView.frame = [self notificationLabelFrame];
    switch (self.notificationAnimationOutStyle) {
        case CWNotificationAnimationStyleTop:
            self.notificationLabel.frame = [self notificationLabelTopFrame];
            break;
            
        case CWNotificationAnimationStyleBottom:
            self.notificationLabel.transform = CGAffineTransformMakeScale(1.0f, 0.0f);
            break;
            
        case CWNotificationAnimationStyleLeft:
            self.notificationLabel.frame = [self notificationLabelLeftFrame];
            break;
            
        case CWNotificationAnimationStyleRight:
            self.notificationLabel.frame = [self notificationLabelRightFrame];
            break;
    }
}

@end

@implementation ScrollLabel {
    UIImageView *textImage;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        textImage = [[UIImageView alloc] init];
        [self addSubview:textImage];
    }
    return self;
}

- (CGFloat)fullWidth {
    return [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}].width;
}

- (CGFloat)scrollOffset {
    if (self.numberOfLines != 1) return 0;

    CGRect insetRect = CGRectInset(self.bounds, PADDING, 0);
    return MAX(0, [self fullWidth] - insetRect.size.width);
}

- (CGFloat)scrollTime {
    return ([self scrollOffset] > 0) ? [self scrollOffset] / SCROLL_SPEED + SCROLL_DELAY : 0;
}

- (void)drawTextInRect:(CGRect)rect {
    if ([self scrollOffset] > 0) {
        rect.size.width = [self fullWidth] + PADDING * 2;
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        [super drawTextInRect:rect];
        textImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [textImage sizeToFit];
        [UIView animateWithDuration:[self scrollTime] - SCROLL_DELAY
                              delay:SCROLL_DELAY
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             textImage.transform = CGAffineTransformMakeTranslation(-[self scrollOffset], 0);
                         } completion:^(BOOL finished) {
                         }];
    } else {
        textImage.image = nil;
        [super drawTextInRect:CGRectInset(rect, PADDING, 0)];
    }
}

@end

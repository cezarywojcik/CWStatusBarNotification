//
//  CWStatusBarNotification.swift
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 6/3/14.
//  Copyright (c) 2014 Cezary Wojcik. All rights reserved.
//

import Foundation
import UIKit

// ---- [ constants ] ---------------------------------------------------------

let STATUS_BAR_ANIMATION_LENGTH : Double = 0.25
let FONT_SIZE : CGFloat = 12.0
let PADDING : CGFloat = 10.0
let SCROLL_SPEED : CGFloat = 40.0
let SCROLL_DELAY : CGFloat = 1.0

// ---- [ enums ] -------------------------------------------------------------

enum CWNotificationStyle : Int {
    case StatusBarNotification
    case NavigationBarNotification
}

enum CWNotificationAnimationStyle : Int {
    case Top
    case Bottom
    case Left
    case Right
}

enum CWNotificationAnimationType : Int {
    case Replace
    case Overlay
}

// ---- [ ScrollLabel ] -------------------------------------------------------

class ScrollLabel : UILabel {
    
    var textImage : UIImageView!

    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        self.textImage = UIImageView()
        super.init(frame: frame)
    }
    
    func fullWidth() -> CGFloat {
        var content : NSString = self.text!
        var size = content.sizeWithAttributes([NSFontAttributeName: self.font])
        return size.width
    }
    
    func scrollOffset() -> CGFloat {
        if self.numberOfLines != 1 {
            return 0
        }
        
        var insetRect : CGRect = CGRectInset(self.bounds, PADDING, 0)
        return max(0, self.fullWidth() - insetRect.size.width)
    }
    
    
    func scrollTime() -> CGFloat {
        return self.scrollOffset() > 0 ? self.scrollOffset() / SCROLL_SPEED + SCROLL_DELAY : 0
    }
    
    override func drawTextInRect(rect: CGRect) {
        if self.scrollOffset() > 0 {
            var frame = rect
            frame.size.width = self.fullWidth() + PADDING * 2
            UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
            super.drawTextInRect(frame)
            self.textImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            textImage.sizeToFit()
            UIView.animateWithDuration(NSTimeInterval(self.scrollTime() - SCROLL_DELAY),
                delay: NSTimeInterval(SCROLL_DELAY),
                options: UIViewAnimationOptions.BeginFromCurrentState |
                    UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                    self.textImage.transform =
                        CGAffineTransformMakeTranslation(-1 *
                            self.scrollOffset(), 0)
                }, completion: nil)
        } else {
            self.textImage = nil
            super.drawTextInRect(CGRectInset(rect, PADDING, 0))
        }
    }
}

// ---- [ CWWindowContainer ] -------------------------------------------------

class CWWindowContainer : UIWindow {
    override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView?  {
        if point.y > 0 && point.y <
            UIApplication.sharedApplication().statusBarFrame.size.height {
            return super.hitTest(point, withEvent: event)
        }
        return nil
    }
}

// ---- [ delayed closure handle ] ----------------------------------------------

typealias CWDelayedClosureHandle = (Bool) -> ()

func performClosureAfterDelay(seconds : Double, closure: dispatch_block_t?) -> CWDelayedClosureHandle? {
    if closure == nil {
        return nil
    }
        
    var closureToExecute : dispatch_block_t! = closure // copy?
    var delayHandleCopy : CWDelayedClosureHandle! = nil
    
    var delayHandle : CWDelayedClosureHandle = {
        (cancel : Bool) -> () in
        if !cancel && closureToExecute != nil {
            dispatch_async(dispatch_get_main_queue(), closureToExecute)
        }
        closureToExecute = nil
        delayHandleCopy = nil
    }
    
    delayHandleCopy = delayHandle // copy?
    
    let delay = Int64(Double(seconds) * Double(NSEC_PER_SEC))
    let after = dispatch_time(DISPATCH_TIME_NOW, delay)
    dispatch_after(after, dispatch_get_main_queue()) {
        if delayHandleCopy != nil {
            delayHandleCopy(false)
        }
    }
    
    return delayHandleCopy
}

func cancelDelayedClosure(delayedHandle : CWDelayedClosureHandle!) {
    if delayedHandle == nil {
        return
    }
    
    delayedHandle(true)
}

// ---- [ CWStatusBarNotification ] -------------------------------------------

class CWStatusBarNotification : NSObject {
    
    var notificationLabel : ScrollLabel!
    var notificationLabelBackgroundColor : UIColor = UIColor.blackColor()
    var notificationLabelTextColor : UIColor = UIColor.whiteColor()
    var notificationLabelHeight : CGFloat!
    var multiline : Bool = false
    var statusBarView : UIView!
    var notificationTappedClosure : () -> () = {}
    var notificationStyle : CWNotificationStyle = .StatusBarNotification
    var notificationAnimationInStyle : CWNotificationAnimationStyle = .Bottom
    var notificationAnimationOutStyle : CWNotificationAnimationStyle = .Bottom
    var notificationAnimationType : CWNotificationAnimationType = .Replace
    var notificationIsShowing : Bool = false
    var notificationIsDismissing : Bool = false
    var notificationWindow : CWWindowContainer!
    
    var tapGestureRecognizer : UITapGestureRecognizer?
    var dismissHandle : CWDelayedClosureHandle?

    override init() {
        super.init()
        
        self.notificationTappedClosure = {
            if !self.notificationIsDismissing {
                self.dismissNotification()
            }
        }
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "notificationTapped:")
    }
    
    // dimensions
    
    func getStatusBarHeight() -> CGFloat {
        if self.notificationLabelHeight > 0 {
            return self.notificationLabelHeight
        }
        
        let sharedApp = UIApplication.sharedApplication()
        
        var statusBarHeight = sharedApp.statusBarFrame.size.height
        if UIInterfaceOrientationIsLandscape(sharedApp.statusBarOrientation) {
            statusBarHeight = sharedApp.statusBarFrame.size.width
        }
        
        return statusBarHeight > 0 ? statusBarHeight : 20.0;
    }
    
    func getStatusBarWidth() -> CGFloat {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            return UIScreen.mainScreen().bounds.size.width
        }
        return UIScreen.mainScreen().bounds.size.height
    }
    
    func getNotificationLabelTopFrame() -> CGRect {
        return CGRectMake(0, -1 * self.getNotificationLabelHeight(), self.getStatusBarWidth(), self.getNotificationLabelHeight())
    }
    
    func getNotificationLabelLeftFrame() -> CGRect {
        return CGRectMake(-1 * self.getStatusBarWidth(), 0, self.getStatusBarWidth(), self.getNotificationLabelHeight())
    }
    
    func getNotificationLabelRightFrame() -> CGRect {
        return CGRectMake(self.getStatusBarWidth(), 0, self.getStatusBarWidth(), self.getNotificationLabelHeight())
    }
    
    func getNotificationLabelBottomFrame() -> CGRect {
        return CGRectMake(0, self.getNotificationLabelHeight(), self.getStatusBarWidth(), 0)
    }
    
    func getNotificationLabelFrame() -> CGRect {
        return CGRectMake(0, 0, self.getStatusBarWidth(), self.getNotificationLabelHeight())
    }
    
    func getNavigationBarHeight() -> CGFloat {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) || UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            return 44.0
        }
        return 30.0
    }
    
    func getNotificationLabelHeight() -> CGFloat {
        switch self.notificationStyle {
        case .NavigationBarNotification:
            return self.getStatusBarHeight() + self.getNavigationBarHeight()
        case .StatusBarNotification:
            fallthrough
        default:
            return self.getStatusBarHeight()
        }
    }
    
    // screen orientation change
    
    func screenOrientationChanged() {
        self.notificationLabel.frame = self.getNotificationLabelFrame()
        self.statusBarView.hidden = true
    }
    
    // on tap
    
    func notificationTapped(recognizer : UITapGestureRecognizer) {
        self.notificationTappedClosure()
    }
    
    // display helpers
    
    func createNotificationLabelWithMessage(message : String) {
        self.notificationLabel = ScrollLabel()
        self.notificationLabel.numberOfLines = self.multiline ? 0 : 1
        self.notificationLabel.text = message
        self.notificationLabel.textAlignment = .Center
        self.notificationLabel.adjustsFontSizeToFitWidth = false
        self.notificationLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
        self.notificationLabel.backgroundColor = self.notificationLabelBackgroundColor
        self.notificationLabel.textColor = self.notificationLabelTextColor
        self.notificationLabel.clipsToBounds = true
        self.notificationLabel.userInteractionEnabled = true
        self.notificationLabel.addGestureRecognizer(self.tapGestureRecognizer!)
        switch self.notificationAnimationInStyle {
        case .Top:
            self.notificationLabel.frame = self.getNotificationLabelTopFrame()
        case .Bottom:
            self.notificationLabel.frame = self.getNotificationLabelBottomFrame()
        case .Left:
            self.notificationLabel.frame = self.getNotificationLabelLeftFrame()
        case .Right:
            self.notificationLabel.frame = self.getNotificationLabelRightFrame()
        }
    }
    
    func createNotificationWindow() {
        self.notificationWindow = CWWindowContainer(frame: UIScreen.mainScreen().bounds)
        self.notificationWindow.backgroundColor = UIColor.clearColor()
        self.notificationWindow.userInteractionEnabled = true
        self.notificationWindow.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.notificationWindow.windowLevel = UIWindowLevelStatusBar
        self.notificationWindow.rootViewController = UIViewController()
    }
    
    func createStatusBarView() {
        self.statusBarView = UIView(frame: self.getNotificationLabelFrame())
        self.statusBarView.clipsToBounds = true
        if self.notificationAnimationType == .Replace {
            var statusBarImageView : UIView = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(true)
            self.statusBarView.addSubview(statusBarImageView)
        }
        self.notificationWindow.rootViewController!.view.addSubview(self.statusBarView)
        self.notificationWindow.rootViewController!.view.sendSubviewToBack(self.statusBarView)
    }
    
    // frame changing
    
    func firstFrameChange() {
        self.notificationLabel.frame = self.getNotificationLabelFrame()
        switch self.notificationAnimationInStyle {
        case .Top:
            self.statusBarView.frame = self.getNotificationLabelBottomFrame()
        case .Bottom:
            self.statusBarView.frame = self.getNotificationLabelTopFrame()
        case .Left:
            self.statusBarView.frame = self.getNotificationLabelRightFrame()
        case .Right:
            self.statusBarView.frame = self.getNotificationLabelLeftFrame()
        }
    }
    
    func secondFrameChange() {
        switch self.notificationAnimationOutStyle {
        case .Top:
            self.statusBarView.frame = self.getNotificationLabelBottomFrame()
        case .Bottom:
            self.statusBarView.frame = self.getNotificationLabelTopFrame()
            self.notificationLabel.layer.anchorPoint = CGPointMake(0.5, 1.0)
            self.notificationLabel.center = CGPointMake(self.notificationLabel.center.x, self.getNotificationLabelHeight())
        case .Left:
            self.statusBarView.frame = self.getNotificationLabelRightFrame()
        case .Right:
            self.statusBarView.frame = self.getNotificationLabelLeftFrame()
        }
    }
    
    func thirdFrameChange() {
        self.statusBarView.frame = self.getNotificationLabelFrame()
        switch self.notificationAnimationOutStyle {
        case .Top:
            self.notificationLabel.frame = self.getNotificationLabelTopFrame()
        case .Bottom:
            self.notificationLabel.transform = CGAffineTransformMakeScale(1.0, 0.01)
        case .Left:
            self.notificationLabel.frame = self.getNotificationLabelLeftFrame()
        case .Right:
            self.notificationLabel.frame = self.getNotificationLabelRightFrame()
        }
    }
    
    // display notification
    
    func displayNotificationWithMessage(message: NSString, completion: (() -> ())?) {
        if !self.notificationIsShowing {
            self.notificationIsShowing = true
            
            // create CWWindowContainer
            self.createNotificationWindow()
            
            // create ScrollLabel
            self .createNotificationLabelWithMessage(message)
            
            // create status bar view
            self.createStatusBarView()
            
            // add label to window
            self.notificationWindow.rootViewController!.view.addSubview(self.notificationLabel)
            self.notificationWindow.rootViewController!.view.bringSubviewToFront(self.notificationLabel)
            self.notificationWindow.hidden = false
            
            // checking for screen orientation change
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenOrientationChanged", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
            
            UIView.animateWithDuration(STATUS_BAR_ANIMATION_LENGTH, animations: {
                self.firstFrameChange()
                }, completion: { (finished : Bool) -> () in
                    var delayInSeconds = Double(self.notificationLabel.scrollTime())
                    performClosureAfterDelay(delayInSeconds, {
                        if completion() != nil {
                            completion()!
                        }
                    })
                })
        }
    }
    
    func dismissNotification() {
        if self.notificationIsShowing {
            cancelDelayedClosure(self.dismissHandle)
            self.notificationIsDismissing = true
            self.secondFrameChange()
            UIView.animateWithDuration(STATUS_BAR_ANIMATION_LENGTH, animations: {
                self.thirdFrameChange()
                }, completion: { (finished : Bool) -> () in
                    self.notificationLabel?.removeFromSuperview()
                    self.statusBarView?.removeFromSuperview()
                    self.notificationWindow = nil
                    self.notificationLabel = nil
                    self.notificationIsShowing = false
                    self.notificationIsDismissing = false
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
                })
        }
    }
    
    func displayNotificationWithMessage(message: String, duration: Double) {
        self.displayNotificationWithMessage(message, completion: {
            self.dismissHandle = performClosureAfterDelay(duration, {
                self.dismissNotification()
                })
            })
    }
}

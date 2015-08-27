//
//  MainViewController.swift
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 7/11/15.
//  Copyright © 2015 Cezary Wojcik. All rights reserved.
//

import UIKit
import CWStatusBarNotification

class MainViewController: UIViewController {
    // MARK: - IB outlets
    
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var txtNotificationMessage: UITextField!
    @IBOutlet weak var segFromStyle: UISegmentedControl!
    @IBOutlet weak var segToStyle: UISegmentedControl!
    @IBOutlet weak var segNotificationStyle: UISegmentedControl!
    
    // MARK: - properties
    
    let notification = CWStatusBarNotification()
    
    // MARK: - setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CWStatusBarNotification"
        self.updateDurationLabel()
        
        // setup font
        let font = UIFont.boldSystemFontOfSize(10.0)
        let attributes = [NSFontAttributeName : font]
        self.segFromStyle.setTitleTextAttributes(attributes, forState: .Normal)
        self.segToStyle.setTitleTextAttributes(attributes, forState: .Normal)
        
        // set default blue color (since iOS 7.1, default window `tintColor`
        // is black)
        self.notification.notificationLabelBackgroundColor = UIColor(red: 0.0,
            green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    }
    
    // MARK: - methods
    
    func updateDurationLabel() {
        self.lblDuration.text = NSString(format: "%.1f seconds",
            self.sliderDuration.value) as String
    }
    
    func setupNotification() {
        guard let inStyle = CWNotificationAnimationStyle(rawValue:
            self.segFromStyle.selectedSegmentIndex) else {
                return
        }
        guard let outStyle = CWNotificationAnimationStyle(rawValue:
            self.segToStyle.selectedSegmentIndex) else {
                return
        }
        guard let notificationStyle = CWNotificationStyle(rawValue:
            self.segNotificationStyle.selectedSegmentIndex) else {
                return
        }
        self.notification.notificationAnimationInStyle = inStyle
        self.notification.notificationAnimationOutStyle = outStyle
        self.notification.notificationStyle = notificationStyle
    }
    
    // MARK: - IB actions
    
    @IBAction func sliderDurationChanged(sender: UISlider) {
        self.updateDurationLabel()
    }
    
    @IBAction func btnShowNotificationPressed(sender: UIButton) {
        self.setupNotification()
        let duration = NSTimeInterval(self.sliderDuration.value)
        self.notification.displayNotificationWithMessage(
            self.txtNotificationMessage.text!, forDuration: duration)
    }
    
    @IBAction func btnShowCustomNotificationPressed(sender: UIButton) {
        self.setupNotification()
        let duration = NSTimeInterval(self.sliderDuration.value)
        guard let view = NSBundle.mainBundle().loadNibNamed("CustomView",
            owner: nil, options: nil)[0] as? UIView else {
                return
        }
        self.notification.displayNotificationWithView(view,
            forDuration: duration)
    }
    
}
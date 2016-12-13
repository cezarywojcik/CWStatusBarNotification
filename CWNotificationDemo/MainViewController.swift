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
        let font = UIFont.boldSystemFont(ofSize: 10.0)
        let attributes = [NSFontAttributeName : font]
        self.segFromStyle.setTitleTextAttributes(attributes, for: UIControlState())
        self.segToStyle.setTitleTextAttributes(attributes, for: UIControlState())
        
        // set default blue color (since iOS 7.1, default window `tintColor`
        // is black)
        self.notification.backgroundColor = UIColor(red: 0.0,
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
        self.notification.animationInStyle = inStyle
        self.notification.animationOutStyle = outStyle
        self.notification.style = notificationStyle
    }
    
    // MARK: - IB actions
    
    @IBAction func sliderDurationChanged(_ sender: UISlider) {
        self.updateDurationLabel()
    }
    
    @IBAction func btnShowNotificationPressed(_ sender: UIButton) {
        self.setupNotification()
        let duration = TimeInterval(self.sliderDuration.value)
        self.notification.displayNotification(message:
            self.txtNotificationMessage.text!, duration: duration)
    }
    
    @IBAction func btnShowCustomNotificationPressed(_ sender: UIButton) {
        self.setupNotification()
        let duration = TimeInterval(self.sliderDuration.value)
        guard let view = Bundle.main.loadNibNamed("CustomView",
            owner: nil, options: nil)?[0] as? UIView else {
                return
        }
        self.notification.displayNotification(view: view,
            forDuration: duration)
    }
    
}

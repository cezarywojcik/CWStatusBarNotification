//
//  ViewController.swift
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 6/8/14.
//  Copyright (c) 2014 Cezary Wojcik. All rights reserved.
//

//
//  MainViewController.swift
//  CWNotificationDemo
//
//  Created by Cezary Wojcik on 6/8/14.
//  Copyright (c) 2014 Cezary Wojcik. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet var labelDuration : UILabel?
    @IBOutlet var sliderDuration : UISlider?
    @IBOutlet var textNotificationMessage : UITextField?
    @IBOutlet var segFromStyle : UISegmentedControl?
    @IBOutlet var segToStyle : UISegmentedControl?
    
    let notification = CWStatusBarNotification()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CWStatusBarNotification"
        self.updateDurationLabel()
        var font = UIFont.boldSystemFontOfSize(10.0)
        var attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
        self.segFromStyle!.setTitleTextAttributes(attributes as [NSObject : AnyObject], forState: .Normal)
        self.segToStyle!.setTitleTextAttributes(attributes as [NSObject : AnyObject], forState: .Normal)
        
        // set default blue color
        self.notification.notificationLabelBackgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    }
    
    func updateDurationLabel() {
        self.labelDuration!.text = NSString(format: "%.1f seconds", self.sliderDuration!.value) as String
    }
    
    @IBAction func sliderDurationChanged(sender : UISlider) {
        self.updateDurationLabel()
    }
    
    @IBAction func showNotificationPressed(sender : UIButton) {
        self.notification.notificationAnimationInStyle = CWNotificationAnimationStyle(rawValue: self.segFromStyle!.selectedSegmentIndex)!
        self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyle(rawValue: self.segToStyle!.selectedSegmentIndex)!
        self.notification.displayNotificationWithMessage(self.textNotificationMessage!.text, duration: Double(self.sliderDuration!.value))
    }
    
}

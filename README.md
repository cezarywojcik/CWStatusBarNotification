# CWStatusBarNotification - Swift Branch

[![Build Status](https://travis-ci.org/cezarywojcik/CWStatusBarNotification.png?branch=master)](https://travis-ci.org/cezarywojcik/CWStatusBarNotification)

`CWStatusBarNotification` is a library that allows you to easily create text-based notifications that appear on the status bar.

![demo](screenshots/demo.gif)

## Requirements

`CWStatusBarNotification` uses Swift 3.0 and requires iOS 7.0+.

Works for iPhone and iPad.

## Installation

### Copy Files 

Copy the two `*.swift` files from `CWStatusBarNotification/CWStatusBarNotification/` into your project.

## Usage

You need to create a `CWStatusBarNotification` object. It is recommended that you do so by attaching it as a property to a view controller.

```
let notification = CWStatusBarNotification()
```

After you have a `CWStatusBarNotification` object, you can simply call the `displayNotificationMessage(message: String, duration: NSTimeInterval)` method:

```
self.notification.displayNotification(message: "Hello, World!", duration: 1.0)
```

If you prefer to manually choose when to display and dismiss the notification, you can do so as well:

```
self.notification.displayNotification(message: "Hello", completion: nil)
// wait until you need to dismiss
self.notification.dismissNotification()
```

### Behavior on Tap

The default behavior when the notification is tapped is to dismiss it. However, you can override this behavior by setting the `notificationTappedClosure` closure to something different. 

For example:
```
self.notification.notificationTappedClosure = {
    println("notification tapped")
    // more code here
}
```

Note that overriding this closure means that the notification will no longer be dismissed when tapped. If you want the notification to still dismiss when tapped, make sure to implement the following when overriding the closure:

```
self.notification.notificationTappedClosure = {
    if !self.isDismissing {
        self.dismissNotification()
    }
    // more code here
}
```

## Customizing Appearance

First of all, you can customize the background color and text color using the following properties: `backgroundColor` and `textColor`.

Example:

```
self.notification.backgroundColor = UIColor.black
self.notification.textColor = UIColor.green
```

![custom colors](screenshots/ss1.gif)

The default value of `backgroundColor` is `UIColor.blackColor()`.

The default value of `notification.textColor` is `UIColor.white`.

Finally, you can also choose from two styles - a notification the size of the status bar, or a notification the size of the status bar and a navigation bar. Simply change the `notificationStyle` property of the `CWStatusBarNotification` object to either `CWNotificationStyle.statusBarNotification` or `CWNotificationStyle.navigationBarNotification`.

Example:

```
self.notification.notificationStyle = .navigationBarNotification
```

![custom style](screenshots/ss2.gif)

The default value of `notificationStyle` is `CWNotificationStyle.statusBarNotification`.

## Customizing Animation

There are two properties that determine the animation style of the notification: `notificationAnimationInStyle` and `notificationAnimationOutStyle`. Each can take on one of four values:

* `CWNotificationAnimationStyle.top`
* `CWNotificationAnimationStyle.bottom`
* `CWNotificationAnimationStyle.left`
* `CWNotificationAnimationStyle.right`

The `animationInStyle` describes where the notification comes from, whereas the `animationOutStyle` describes where the notification will go.

The default value for `animationInStyle` is `CWNotificationAnimationStyle.bottom`.

The default value for `animationOutStyle` is `CWNotificationAnimationStyle.bottom`.

### Additional Remarks

The notifications will work in both screen orientations, however, screen rotation while a notification is displayed is not yet fully supported.

## License

    The MIT License (MIT)

    Copyright (c) 2015 Cezary Wojcik <http://www.cezarywojcik.com>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

//
//  UIViewController+keyboard.swift
//  Storyboard
//
//  Created by n-studio on 6/9/15.
//  Copyright (c) 2015 Solfanto, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    private struct Properties {
        static var keyboardStatus: NSString?
        static var originalInset: NSValue?
        static var tabBarHeight: CGFloat = 0.0
        static var outsideKeyboardTapRecognizer: UITapGestureRecognizer?
    }
    
    var keyboardStatus: NSString? {
        get {
            return objc_getAssociatedObject(self, &Properties.keyboardStatus) as? NSString
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Properties.keyboardStatus, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
    
    var originalInset: NSValue? {
        get {
            return objc_getAssociatedObject(self, &Properties.originalInset) as? NSValue
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Properties.originalInset, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
    
    var tabBarHeight: CGFloat {
        get {
            if let value = objc_getAssociatedObject(self, &Properties.tabBarHeight) as? CGFloat {
                return value
            }
            else {
                return 0
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Properties.tabBarHeight, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
    
    var outsideKeyboardTapRecognizer: UITapGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &Properties.outsideKeyboardTapRecognizer) as? UITapGestureRecognizer
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Properties.outsideKeyboardTapRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func bs_setKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bs_keyboardWillAppear:", name: UIKeyboardWillShowNotification, object:nil
        )
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bs_keyboardDidAppear:", name: UIKeyboardDidShowNotification, object:nil
        )
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bs_keyboardWillHide:", name: UIKeyboardWillHideNotification, object:nil
        )
    }
    
    func bs_unsetKeyboardNotifications() {
        self.dismissKeyboard(nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillShowNotification, object:nil
        )
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardDidShowNotification, object:nil
        )
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillHideNotification, object:nil
        )
    }
    
    func bs_keyboardWillAppear(notification: NSNotification) {
        if self.outsideKeyboardTapRecognizer == nil {
            self.outsideKeyboardTapRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        }
        if let recognizer = self.outsideKeyboardTapRecognizer {
            self.view.addGestureRecognizer(recognizer)
        }
        self.keyboardWillAppear(notification)
        self.moveScrollViewForKeyboardUp(notification)
    }
    
    func keyboardWillAppear(notification: NSNotification) {
        
    }
    
    func bs_keyboardDidAppear(notification: NSNotification) {
        self.keyboardDidAppear(notification)
    }
    
    func keyboardDidAppear(notification: NSNotification) {
        
    }
    
    func bs_keyboardWillHide(notification: NSNotification) {
        if let recognizer = outsideKeyboardTapRecognizer {
            self.view.removeGestureRecognizer(recognizer)
        }
        self.keyboardWillDisappear(notification)
        self.moveScrollViewForKeyboardDown(notification)
    }
    
    func keyboardWillDisappear(notification: NSNotification) {
        
    }
    
    func dismissKeyboard(sender: AnyObject?) {
        self.view.endEditing(true)
    }
    
    func moveScrollViewForKeyboardUp(notification: NSNotification) {
        if keyboardStatus == "up" {
            return
        }
        
        if let scrollView = getScrollView() {
            originalInset = NSValue(UIEdgeInsets: scrollView.contentInset)
            var inset = scrollView.contentInset
            inset.bottom -= tabBarHeight
            scrollView.contentInset = inset
            
            guard let userInfo = notification.userInfo,
                let durationInfo = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let sizeInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                    return
            }
            
            // Get animation info from userInfo
            // let animationCurve = (userInfo?[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue
            let animationCurve = UIViewAnimationCurve.EaseInOut.rawValue
            let animationDuration = durationInfo.doubleValue
            let keyboardSize = sizeInfo.CGRectValue().size
            
            // Animate up or down
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(animationDuration)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: animationCurve)!)
            
            var newInset = scrollView.contentInset
            newInset.bottom += keyboardSize.height
            scrollView.contentInset = newInset
            
            UIView.commitAnimations()
            
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
            keyboardStatus = "up"
        }
    }
    
    func moveScrollViewForKeyboardDown(notification: NSNotification) {
        if keyboardStatus == "down" {
            return
        }
        
        if let scrollView = getScrollView() {
            guard let userInfo = notification.userInfo,
                let durationInfo = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
                    return
            }
            
            // Get animation info from userInfo
            // let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue
            let animationCurve = UIViewAnimationCurve.EaseInOut.rawValue
            let animationDuration = durationInfo.doubleValue
            // let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
            
            // Animate up or down
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(animationDuration)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: animationCurve)!)
            
            if let inset = originalInset {
                scrollView.contentInset = inset.UIEdgeInsetsValue()
            }
            var inset = scrollView.contentInset
            inset.bottom -= tabBarHeight
            scrollView.contentInset = inset
            
            UIView.commitAnimations()
            
            if let inset = originalInset {
                scrollView.contentInset = inset.UIEdgeInsetsValue()
            }
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            originalInset = nil
            
            keyboardStatus = "down"
        }
    }
    
    func getScrollView() -> UIScrollView? {
        if let tc = self as? UITableViewController {
            return tc.tableView
        }
        
        for subview in self.view.subviews {
            if subview is UIScrollView {
                return subview as? UIScrollView
            }
        }
        return nil
    }
}
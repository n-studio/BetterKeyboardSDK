//
//  UIViewController+keyboard.swift
//  Storyboard
//
//  Created by n-studio on 6/9/15.
//  Copyright (c) 2015 Solfanto, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    fileprivate struct Properties {
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
        NotificationCenter.default.addObserver(self, selector: #selector(bs_keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object:nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(bs_keyboardDidAppear(_:)), name: UIResponder.keyboardDidShowNotification, object:nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(bs_keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object:nil
        )
    }
    
    func bs_unsetKeyboardNotifications() {
        self.dismissKeyboard(nil)
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillShowNotification, object:nil
        )
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardDidShowNotification, object:nil
        )
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillHideNotification, object:nil
        )
    }
    
    @objc func bs_keyboardWillAppear(_ notification: Notification) {
        if self.outsideKeyboardTapRecognizer == nil {
            self.outsideKeyboardTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        }
        if let recognizer = self.outsideKeyboardTapRecognizer {
            self.view.addGestureRecognizer(recognizer)
        }
        self.keyboardWillAppear(notification)
        self.moveScrollViewForKeyboardUp(notification)
    }
    
    func keyboardWillAppear(_ notification: Notification) {
        
    }
    
    @objc func bs_keyboardDidAppear(_ notification: Notification) {
        self.keyboardDidAppear(notification)
    }
    
    func keyboardDidAppear(_ notification: Notification) {
        
    }
    
    @objc func bs_keyboardWillHide(_ notification: Notification) {
        if let recognizer = outsideKeyboardTapRecognizer {
            self.view.removeGestureRecognizer(recognizer)
        }
        self.keyboardWillDisappear(notification)
        self.moveScrollViewForKeyboardDown(notification)
    }
    
    func keyboardWillDisappear(_ notification: Notification) {
        
    }
    
    @objc func dismissKeyboard(_ sender: AnyObject?) {
        self.view.endEditing(true)
    }
    
    func moveScrollViewForKeyboardUp(_ notification: Notification) {
        if keyboardStatus == "up" {
            return
        }
        
        if let scrollView = getScrollView() {
            originalInset = NSValue(uiEdgeInsets: scrollView.contentInset)
            var inset = scrollView.contentInset
            inset.bottom -= tabBarHeight
            scrollView.contentInset = inset
            
            guard let userInfo = notification.userInfo,
                let durationInfo = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let sizeInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return
            }
            
            // Get animation info from userInfo
            // let animationCurve = (userInfo?[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue
            let animationDuration = durationInfo.doubleValue
            let keyboardSize = sizeInfo.cgRectValue.size
            
            // Animate up or down
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut) {
                var newInset = scrollView.contentInset
                newInset.bottom += keyboardSize.height
                scrollView.contentInset = newInset
            } completion: { _ in
                scrollView.scrollIndicatorInsets = scrollView.contentInset

                self.keyboardStatus = "up"
            }
        }
    }
    
    func moveScrollViewForKeyboardDown(_ notification: Notification) {
        if keyboardStatus == "down" {
            return
        }
        
        if let scrollView = getScrollView() {
            guard let userInfo = notification.userInfo,
                let durationInfo = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
                    return
            }
            
            // Get animation info from userInfo
            // let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue
            let animationDuration = durationInfo.doubleValue
            // let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
            
            // Animate up or down
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut) {
                if let inset = self.originalInset {
                    scrollView.contentInset = inset.uiEdgeInsetsValue
                }
                var inset = scrollView.contentInset
                inset.bottom -= self.tabBarHeight
                scrollView.contentInset = inset
            } completion: { _ in
                if let inset = self.originalInset {
                    scrollView.contentInset = inset.uiEdgeInsetsValue
                }
                scrollView.scrollIndicatorInsets = scrollView.contentInset
                self.originalInset = nil

                self.keyboardStatus = "down"
            }
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

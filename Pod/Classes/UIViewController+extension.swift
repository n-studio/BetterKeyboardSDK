//
//  UIViewController+extension.swift
//  betterkeyboard
//
//  Created by Lidner on 10/26/15.
//  Copyright © 2015 Solfanto. All rights reserved.
//

import UIKit

extension UIViewController {
    public func bk_getKeyboardView() -> UIView? {
        for window in UIApplication.sharedApplication().windows {
            if NSStringFromClass(window.dynamicType) == "UIRemoteKeyboardWindow" {
                for subView in window.subviews {
                    if NSStringFromClass(subView.dynamicType) == "UIInputSetContainerView" {
                        for subsubView in subView.subviews {
                            if NSStringFromClass(subsubView.dynamicType) == "UIInputSetHostView" {
                                return subsubView
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
}

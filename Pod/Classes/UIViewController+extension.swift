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
        for window in UIApplication.shared.windows {
            if NSStringFromClass(type(of: window)) == "UIRemoteKeyboardWindow" {
                for subView in window.subviews {
                    if NSStringFromClass(type(of: subView)) == "UIInputSetContainerView" {
                        for subsubView in subView.subviews {
                            if NSStringFromClass(type(of: subsubView)) == "UIInputSetHostView" {
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

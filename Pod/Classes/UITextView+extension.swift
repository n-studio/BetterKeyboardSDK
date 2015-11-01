//
//  UITextView+extension.swift
//  betterkeyboard
//
//  Created by Lidner on 10/22/15.
//  Copyright © 2015 Solfanto. All rights reserved.
//

import UIKit

extension UITextView {
    private struct Properties {
        static var bk_currentCursor: Int? // 1: right, 0: left
        static var bk_viEnabled: Bool?
        static var bk_viInsertMode: Bool?
    }
    
    public var bk_currentCursor: Int? {
        get {
            if let value = objc_getAssociatedObject(self, &Properties.bk_currentCursor) as? Int {
                return value
            }
            return 1
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Properties.bk_currentCursor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public var bk_viEnabled: Bool? {
        get {
            if let value = objc_getAssociatedObject(self, &Properties.bk_viEnabled) as? Bool {
                return value
            }
            return false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Properties.bk_viEnabled, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public var bk_viInsertMode: Bool? {
        get {
            if let value = objc_getAssociatedObject(self, &Properties.bk_viInsertMode) as? Bool {
                return value
            }
            return false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Properties.bk_viInsertMode, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func bk_advancedTextViewShouldChangeTextInRange(range: NSRange, replacementText text: String) -> Bool {
        if self.bk_viEnabled == true {
            if let _ = text.rangeOfString("^⌘.$", options: .RegularExpressionSearch) {
                switch text {
                case "⌘a":
                    self.selectAll(nil)
                case "⌘c":
                    copyText(nil)
                case "⌘x":
                    copyText(nil)
                case "⌘←":
                    selectLeft()
                case "⌘→":
                    selectRight()
                default:
                    break
                }
                return false
            }
            else {
                if self.bk_viInsertMode == false {
                    switch text {
                    case "i":
                        self.bk_viInsertMode = true
                    case "x":
                        self.deleteBackward()
                        self.setMarkedText(String(self.text![self.text.startIndex.advancedBy(1)]), selectedRange: NSRange(location: self.selectedRange.location, length: 1))
                        
                    default:
                        break
                    }
                    return false
                }
                else {
                    if text == "⎋" || text == "␛" {
                        self.bk_viInsertMode = false
                        return false
                    }
                    return true
                }
            }
            
        }
        else {
            if let _ = text.rangeOfString("^⌘.$", options: .RegularExpressionSearch) {
                switch text {
                case "⌘a":
                    self.selectAll(nil)
                case "⌘c":
                    copyText(nil)
                case "⌘x":
                    cutText(nil)
                case "⌘v":
                    pasteText(nil)
                case "⌘z":
                    undo()
                case "⌘y":
                    redo()
                case "⌘←":
                    selectLeft()
                case "⌘→":
                    selectRight()
                default:
                    break
                }
                return false
            }
            else if text == "⎋" || text == "␛" {
                return false
            }
            return true
        }
    }
    
    func undo() {
        if self.undoManager?.canUndo == true {
            self.undoManager?.undo()
        }
        else {
            NSLog("can't undo")
        }
    }
    
    func redo() {
        if self.undoManager?.canRedo == true {
            self.undoManager?.redo()
        }
        else {
            NSLog("can't redo")
        }
    }
    
    func copyText(sender: AnyObject?) {
        let pasteBoard: UIPasteboard = UIPasteboard.generalPasteboard()
        let textToCopy = (self.text as NSString).substringWithRange(self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
    }
    
    func cutText(sender: AnyObject?) {
        let pasteBoard: UIPasteboard = UIPasteboard.generalPasteboard()
        let textToCopy = (self.text as NSString).substringWithRange(self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
        self.text = (self.text as NSString).stringByReplacingCharactersInRange(self.selectedRange, withString: "")
    }
    
    func pasteText(sender: AnyObject?) {
        let pasteBoard: UIPasteboard = UIPasteboard.generalPasteboard()
        if pasteBoard.string != nil {
            self.text = (self.text as NSString).stringByReplacingCharactersInRange(self.selectedRange, withString: pasteBoard.string!)
        }
    }
    
    func selectLeft() {
        let length = self.selectedRange.length
        
        if length == 0 {
            self.bk_currentCursor = 0
        }
        
        if self.bk_currentCursor == 1 {
            self.selectedRange = NSRange(location: self.selectedRange.location, length: length - 1)
        }
        else {
            self.selectedRange = NSRange(location: self.selectedRange.location - 1, length: self.selectedRange.length + 1)
        }
    }
    
    func selectRight() {
        let length = self.selectedRange.length
        
        if length == 0 {
            self.bk_currentCursor = 1
        }
        
        if self.bk_currentCursor == 1 {
            self.selectedRange = NSRange(location: self.selectedRange.location, length: length + 1)
        }
        else {
            self.selectedRange = NSRange(location: self.selectedRange.location + 1, length: self.selectedRange.length - 1)
        }
    }
    
    public func bk_advancedTextViewDidChangeSelection() {
        if self.selectedRange.length == 0 {
            self.bk_currentCursor = 1
        }
    }
}

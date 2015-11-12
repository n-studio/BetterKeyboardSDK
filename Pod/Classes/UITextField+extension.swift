//
//  UITextField+extension.swift
//  Pods
//
//  Created by Matthew Nguyen on 11/8/15.
//  Copyright © 2015 Solfanto, Inc. All rights reserved.
//

// This file is a copy paste from UITextView, and is not DRY at all
// I'm not sure how to factorize it

import UIKit

extension UITextField {
    private struct Properties {
        static var bk_currentCursor: Int? // 1: right, 0: left
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
    
    public func bk_advancedTextFieldShouldChangeTextInRange(range: NSRange, replacementString string: String) -> Bool {
        if let _ = string.rangeOfString("^⌘.$", options: .RegularExpressionSearch) {
            switch string {
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
        else if string == "⎋" || string == "␛" {
            return false
        }
        return true
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
    
    var selectedRange: NSRange {
        get {
            guard let selectedTextRange = self.selectedTextRange else {
                return NSRange()
            }
            return NSRangeFromString("{\(self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.start)),\(self.offsetFromPosition(selectedTextRange.start, toPosition: selectedTextRange.end))}")
        }
    }
    
    func copyText(sender: AnyObject?) {
        let pasteBoard: UIPasteboard = UIPasteboard.generalPasteboard()
        let textToCopy = (self.text! as NSString).substringWithRange(self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
    }
    
    func cutText(sender: AnyObject?) {
        let range = self.selectedRange
        let pasteBoard: UIPasteboard = UIPasteboard.generalPasteboard()
        let textToCopy = (self.text! as NSString).substringWithRange(self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
        self.text = (self.text! as NSString).stringByReplacingCharactersInRange(self.selectedRange, withString: "")
        if let position = self.positionFromPosition(self.beginningOfDocument, offset: range.location) {
            self.selectedTextRange = self.textRangeFromPosition(position, toPosition: position)
        }
    }
    
    func pasteText(sender: AnyObject?) {
        let range = self.selectedRange
        if let pasteBoardString = UIPasteboard.generalPasteboard().string {
            self.text = (self.text! as NSString).stringByReplacingCharactersInRange(self.selectedRange, withString: pasteBoardString)
            if let position = self.positionFromPosition(self.beginningOfDocument, offset: range.location + pasteBoardString.characters.count) {
                self.selectedTextRange = self.textRangeFromPosition(position, toPosition: position)
            }
        }
    }
    
    func selectLeft() {
        let length = self.selectedRange.length
        
        if length == 0 {
            self.bk_currentCursor = 0
        }
        
        if self.bk_currentCursor == 1 {
            if let startPosition = self.positionFromPosition(self.beginningOfDocument, offset: self.selectedRange.location) {
                if let endPosition = self.positionFromPosition(startPosition, offset: length - 1) {
                    self.selectedTextRange = self.textRangeFromPosition(startPosition, toPosition: endPosition)
                }
            }
        }
        else {
            if let startPosition = self.positionFromPosition(self.beginningOfDocument, offset: self.selectedRange.location - 1) {
                if let endPosition = self.positionFromPosition(startPosition, offset: self.selectedRange.length + 1) {
                    self.selectedTextRange = self.textRangeFromPosition(startPosition, toPosition: endPosition)
                }
            }
        }
        
        if self.selectedRange.length == 0 {
            self.bk_currentCursor = 1
        }
    }
    
    func selectRight() {
        let length = self.selectedRange.length
        
        if length == 0 {
            self.bk_currentCursor = 1
        }
        
        if self.bk_currentCursor == 1 {
            if let startPosition = self.positionFromPosition(self.beginningOfDocument, offset: self.selectedRange.location) {
                if let endPosition = self.positionFromPosition(startPosition, offset: length + 1) {
                    self.selectedTextRange = self.textRangeFromPosition(startPosition, toPosition: endPosition)
                }
            }
        }
        else {
            if let startPosition = self.positionFromPosition(self.beginningOfDocument, offset: self.selectedRange.location + 1) {
                if let endPosition = self.positionFromPosition(startPosition, offset: length - 1) {
                    self.selectedTextRange = self.textRangeFromPosition(startPosition, toPosition: endPosition)
                }
            }
        }
        
        if self.selectedRange.length == 0 {
            self.bk_currentCursor = 1
        }
    }
}

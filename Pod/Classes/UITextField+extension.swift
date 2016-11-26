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
    fileprivate struct Properties {
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
    
    public func bk_advancedTextFieldShouldChangeTextInRange(_ range: NSRange, replacementString string: String) -> Bool {
        if let _ = string.range(of: "^⌘.$", options: .regularExpression) {
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
            NSLog("Error: can't undo")
        }
    }
    
    func redo() {
        if self.undoManager?.canRedo == true {
            self.undoManager?.redo()
        }
        else {
            NSLog("Error: can't redo")
        }
    }
    
    var selectedRange: NSRange {
        get {
            guard let selectedTextRange = self.selectedTextRange else {
                return NSRange()
            }
            return NSRangeFromString("{\(self.offset(from: self.beginningOfDocument, to: selectedTextRange.start)),\(self.offset(from: selectedTextRange.start, to: selectedTextRange.end))}")
        }
    }
    
    func copyText(_ sender: AnyObject?) {
        let pasteBoard: UIPasteboard = UIPasteboard.general
        let textToCopy = (self.text! as NSString).substring(with: self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
    }
    
    func cutText(_ sender: AnyObject?) {
        let range = self.selectedRange
        let pasteBoard: UIPasteboard = UIPasteboard.general
        let textToCopy = (self.text! as NSString).substring(with: self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
        self.text = (self.text! as NSString).replacingCharacters(in: self.selectedRange, with: "")
        if let position = self.position(from: self.beginningOfDocument, offset: range.location) {
            self.selectedTextRange = self.textRange(from: position, to: position)
        }
    }
    
    func pasteText(_ sender: AnyObject?) {
        let range = self.selectedRange
        if let pasteBoardString = UIPasteboard.general.string {
            self.text = (self.text! as NSString).replacingCharacters(in: self.selectedRange, with: pasteBoardString)
            if let position = self.position(from: self.beginningOfDocument, offset: range.location + pasteBoardString.characters.count) {
                self.selectedTextRange = self.textRange(from: position, to: position)
            }
        }
    }
    
    func selectLeft() {
        let length = self.selectedRange.length
        
        if length == 0 {
            self.bk_currentCursor = 0
        }
        
        if self.bk_currentCursor == 1 {
            if let startPosition = self.position(from: self.beginningOfDocument, offset: self.selectedRange.location) {
                if let endPosition = self.position(from: startPosition, offset: length - 1) {
                    self.selectedTextRange = self.textRange(from: startPosition, to: endPosition)
                }
            }
        }
        else {
            if let startPosition = self.position(from: self.beginningOfDocument, offset: self.selectedRange.location - 1) {
                if let endPosition = self.position(from: startPosition, offset: self.selectedRange.length + 1) {
                    self.selectedTextRange = self.textRange(from: startPosition, to: endPosition)
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
            if let startPosition = self.position(from: self.beginningOfDocument, offset: self.selectedRange.location) {
                if let endPosition = self.position(from: startPosition, offset: length + 1) {
                    self.selectedTextRange = self.textRange(from: startPosition, to: endPosition)
                }
            }
        }
        else {
            if let startPosition = self.position(from: self.beginningOfDocument, offset: self.selectedRange.location + 1) {
                if let endPosition = self.position(from: startPosition, offset: length - 1) {
                    self.selectedTextRange = self.textRange(from: startPosition, to: endPosition)
                }
            }
        }
        
        if self.selectedRange.length == 0 {
            self.bk_currentCursor = 1
        }
    }
}

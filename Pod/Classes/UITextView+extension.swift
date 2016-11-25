//
//  UITextView+extension.swift
//  betterkeyboard
//
//  Created by Matthew Nguyen on 10/22/15.
//  Copyright © 2015 Solfanto, Inc. All rights reserved.
//

import UIKit

@objc enum BKViMode: Int {
    case `default`
    case insert
    case visual
}

@objc protocol BKTextViewDelegate {
    @objc optional func bk_keyboardViModeDidChange(_ textView: UITextView, mode: BKViMode)
}

extension UITextView {
    fileprivate struct Properties {
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
    
    public func bk_advancedTextViewShouldChangeTextInRange(_ range: NSRange, replacementText text: String) -> Bool {
        if self.bk_viEnabled == true {
            if let _ = text.range(of: "^⌘.$", options: .regularExpression) {
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
                    // this part is in progress
                    switch text {
                    case "i":
                        self.bk_viInsertMode = true
                    case "x":
                        self.deleteBackward()
                        self.setMarkedText(String(self.text![self.text.index(self.text.startIndex, offsetBy: 1)]), selectedRange: NSRange(location: self.selectedRange.location, length: 1))
                        
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
            if let _ = text.range(of: "^⌘.$", options: .regularExpression) {
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
            else if let exp = try? NSRegularExpression(pattern: "^\\[data:image/([a-z]{3,4});base64,([^\\]]+)\\]$", options: []) {
                var matches = exp.matches(in: text, options: [], range: NSMakeRange(0, text.characters.count))
                if matches.count == 0 {
                    return true
                }
                let formatRange = matches[0].rangeAt(1)
                let format = text.substring(with: (text.characters.index(text.startIndex, offsetBy: formatRange.location) ..< text.characters.index(text.startIndex, offsetBy: formatRange.location + formatRange.length)))
                let codeRange = matches[0].rangeAt(2)
                let code = text.substring(with: (text.characters.index(text.startIndex, offsetBy: codeRange.location) ..< text.characters.index(text.startIndex, offsetBy: codeRange.location + codeRange.length)))
                
                insertPictureWithCode(code, format: format)
                return false
            }
            else if text == "⎋" || text == "␛" {
                return false
            }
            return true
        }
    }
    
    func insertPictureWithCode(_ code: String, format: String) {
        if let data = Data(base64Encoded: code, options: []) {
            let range = self.selectedRange
            let image = UIImage(data: data)
            let textAttachment = NSTextAttachment()
            textAttachment.image = image
            let attributedString = self.attributedText.mutableCopy()
            let attributedImage = NSAttributedString(attachment: textAttachment)
            (attributedString as AnyObject).replaceCharacters(in: NSRange(location: self.selectedRange.location,length: 0), with: attributedImage)
            self.attributedText = attributedString as? NSAttributedString
            self.selectedRange = NSRange(location: range.location + 1, length: 0)
        }
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
    
    func copyText(_ sender: AnyObject?) {
        let pasteBoard: UIPasteboard = UIPasteboard.general
        let textToCopy = (self.text as NSString).substring(with: self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
    }
    
    func cutText(_ sender: AnyObject?) {
        let range = self.selectedRange
        let pasteBoard: UIPasteboard = UIPasteboard.general
        let textToCopy = (self.text as NSString).substring(with: self.selectedRange)
        if textToCopy != "" {
            pasteBoard.string = textToCopy
        }
        self.text = (self.text as NSString).replacingCharacters(in: self.selectedRange, with: "")
        self.selectedRange = NSRange(location: range.location, length: 0)
    }
    
    func pasteText(_ sender: AnyObject?) {
        let range = self.selectedRange
        let pasteBoard: UIPasteboard = UIPasteboard.general
        if let string = pasteBoard.string {
            self.text = (self.text as NSString).replacingCharacters(in: self.selectedRange, with: string)
            self.selectedRange = NSRange(location: range.location + string.characters.count, length: 0)
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

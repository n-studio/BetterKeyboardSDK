//
//  ViewController.swift
//  BetterKeyboardSDK
//
//  Created by n-studio on 10/27/2015.
//  Copyright (c) 2015 Solfanto, Inc. All rights reserved.
//

import UIKit
import BetterKeyboardSDK

class ViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {

    var swipeKeyboardInitialPosition: CGPoint?
    let swipeKeyboardMargin: CGFloat = 44.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.title = "Text View"
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        textView.allowsEditingTextAttributes = true
        let text = "You can use shortcuts in this view!\nTry ⌘+a, ⌘+c, ⌘+x, ⌘+v, ⌘+z, ⌘+y!!\n\nYou can also try the text selection with ⌘+← and ⌘+→!\n\nIf you want to implement this shortcuts to your apps, just detect the input of the strings '⌘[key]' and '␛'\n\nTo be able to use shortcuts, please download Better Keyboard (by Solfanto) or any other compatible iOS keyboard extension.\n\n"
        let attributedString = NSMutableAttributedString(string: text)
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "Image")
        let attributedImage = NSAttributedString(attachment: textAttachment)
        attributedString.replaceCharactersInRange(NSRange(location: text.characters.count, length: 0), withAttributedString: attributedImage)
        
        textView.attributedText = attributedString

        textView.delegate = self
        self.view.addSubview(textView)
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(swipeKeyboard(_:)))
        swipeGesture.delegate = self
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarController = self.tabBarController {
            self.tabBarHeight = tabBarController.tabBar.frame.size.height
        }
        bs_setKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        bs_unsetKeyboardNotifications()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textView.bk_advancedTextViewShouldChangeTextInRange(range, replacementText: text)
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        textView.bk_advancedTextViewDidChangeSelection()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func swipeKeyboard(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            self.swipeKeyboardInitialPosition = sender.locationInView(self.view)
        }
        else if sender.state == .Changed {
            guard let initialPosition = self.swipeKeyboardInitialPosition else {
                return
            }
            
            let diffY = sender.locationInView(self.view).y - initialPosition.y
            let keyboard = bk_getKeyboardView()
            if let frame = keyboard?.frame {
                if sender.locationInView(self.view).y < UIScreen.mainScreen().bounds.size.height - frame.size.height - swipeKeyboardMargin {
                    return
                }
                
                var newFrame = frame
                newFrame.origin.y = (UIScreen.mainScreen().bounds.size.height - frame.size.height) + diffY
                if newFrame.origin.y < UIScreen.mainScreen().bounds.size.height - frame.size.height {
                    newFrame.origin.y = UIScreen.mainScreen().bounds.size.height - frame.size.height
                }
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    keyboard?.frame = newFrame
                })
                
            }
        }
        else if sender.state == .Ended {
            let keyboard = bk_getKeyboardView()
            if let frame = keyboard?.frame {
                var newFrame = frame
                if frame.origin.y > UIScreen.mainScreen().bounds.size.height - frame.size.height / 2 {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        newFrame.origin.y = UIScreen.mainScreen().bounds.size.height
                        keyboard?.frame = newFrame
                        }, completion: { (finished) -> Void in
                            UIView.setAnimationsEnabled(false)
                            self.view.endEditing(true)
                            UIView.setAnimationsEnabled(true)
                    })
                }
                else {
                    newFrame.origin.y = UIScreen.mainScreen().bounds.size.height - frame.size.height
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        keyboard?.frame = newFrame
                    })
                }
            }
            
            self.swipeKeyboardInitialPosition = nil
        }
    }
}


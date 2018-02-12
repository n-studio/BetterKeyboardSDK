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
        self.view.backgroundColor = UIColor.white
        
        self.title = "Text View"
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        textView.allowsEditingTextAttributes = true
        let text = "You can use shortcuts in this view!\nTry ⌘+a, ⌘+c, ⌘+x, ⌘+v, ⌘+z, ⌘+y!!\n\nYou can also try the text selection with ⌘+← and ⌘+→!\n\nIf you want to implement this shortcuts to your apps, just detect the input of the strings '⌘[key]' and '␛'\n\nTo be able to use shortcuts, please download Better Keyboard (by Solfanto) or any other compatible iOS keyboard extension.\n\n"
        let attributedString = NSMutableAttributedString(string: text)
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "Image")
        let attributedImage = NSAttributedString(attachment: textAttachment)
        attributedString.replaceCharacters(in: NSRange(location: text.count, length: 0), with: attributedImage)
        
        textView.attributedText = attributedString

        textView.delegate = self
        self.view.addSubview(textView)
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(swipeKeyboard(_:)))
        swipeGesture.delegate = self
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarController = self.tabBarController {
            self.tabBarHeight = tabBarController.tabBar.frame.size.height
        }
        bs_setKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bs_unsetKeyboardNotifications()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.bk_advancedTextViewShouldChangeTextInRange(range, replacementText: text)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.bk_advancedTextViewDidChangeSelection()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func swipeKeyboard(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.swipeKeyboardInitialPosition = sender.location(in: self.view)
        }
        else if sender.state == .changed {
            guard let initialPosition = self.swipeKeyboardInitialPosition else {
                return
            }
            
            let diffY = sender.location(in: self.view).y - initialPosition.y
            let keyboard = bk_getKeyboardView()
            if let frame = keyboard?.frame {
                if sender.location(in: self.view).y < UIScreen.main.bounds.size.height - frame.size.height - swipeKeyboardMargin {
                    return
                }
                
                var newFrame = frame
                newFrame.origin.y = (UIScreen.main.bounds.size.height - frame.size.height) + diffY
                if newFrame.origin.y < UIScreen.main.bounds.size.height - frame.size.height {
                    newFrame.origin.y = UIScreen.main.bounds.size.height - frame.size.height
                }
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    keyboard?.frame = newFrame
                })
                
            }
        }
        else if sender.state == .ended {
            let keyboard = bk_getKeyboardView()
            if let frame = keyboard?.frame {
                var newFrame = frame
                if frame.origin.y > UIScreen.main.bounds.size.height - frame.size.height / 2 {
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        newFrame.origin.y = UIScreen.main.bounds.size.height
                        keyboard?.frame = newFrame
                        }, completion: { (finished) -> Void in
                            UIView.setAnimationsEnabled(false)
                            self.view.endEditing(true)
                            UIView.setAnimationsEnabled(true)
                    })
                }
                else {
                    newFrame.origin.y = UIScreen.main.bounds.size.height - frame.size.height
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        keyboard?.frame = newFrame
                    })
                }
            }
            
            self.swipeKeyboardInitialPosition = nil
        }
    }
}


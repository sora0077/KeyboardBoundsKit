//
//  KeyboardBoundsView.swift
//  KeyboardBoundsKit
//
//  Created by 林達也 on 2015/09/24.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import UIKit

/// KeyboardBoundsView
@IBDesignable
public final class KeyboardBoundsView: UIView {
    
    /// if keyboard did appear then `true`
    public private(set) var keyboardAppearing: Bool = false
    
    private var heightConstraint: NSLayoutConstraint?
    private var keyboardView: UIView? {
        willSet {
            keyboardView?.removeObserver(self, forKeyPath: "center")
            newValue?.addObserver(self, forKeyPath: "center", options: .New, context: nil)
        }
    }
    private var changeFrameAnimation: Bool = false
 
    /**
    intrinsicContentSize
    
    - returns: `superview?.bounds.size`
    */
    public override func intrinsicContentSize() -> CGSize {
        return superview?.bounds.size ?? super.intrinsicContentSize()
    }
    
    /**
    didMoveToSuperview
    */
    public override func didMoveToSuperview() {
        
        if let newSuperview = superview {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: newSuperview,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0
            )
            heightConstraint = constraint
            
            NSLayoutConstraint.activateConstraints([constraint])
            startObserving()
        } else {
            keyboardView?.removeObserver(self, forKeyPath: "center")
            if let constraint = heightConstraint {
                NSLayoutConstraint.deactivateConstraints([constraint])
            }
            stopObserving()
            heightConstraint = nil
        }
    }
    
    /**
    prepareForInterfaceBuilder
    */
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        backgroundColor = UIColor.clearColor()
    }
    
    /**
    observeValueForKeyPath:ofObject:change:context
    
    - parameter keyPath: `center`
    - parameter object:  object
    - parameter change:  change
    - parameter context: context
    */
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        
        if !keyboardAppearing {
            return
        }
        
        if changeFrameAnimation {
            return
        }
        
        guard let keyboardView = keyboardView else {
            return
        }
        
        let height = superview!.bounds.height
        
        
        heightConstraint?.constant = -(height - keyboardView.frame.origin.y)
        
        superview?.layoutIfNeeded()
    }
}

private extension KeyboardBoundsView {
    
    func startObserving() {
        
        let notifications = [
            (UIKeyboardDidHideNotification, "keyboardDidHideNotification:"),
            (UIKeyboardDidShowNotification, "keyboardDidShowNotification:"),
            (UIKeyboardWillChangeFrameNotification, "keyboardWillChangeFrameNotification:"),
        ]
        
        let center = NSNotificationCenter.defaultCenter()
        notifications.forEach { name, sel in
            center.addObserver(self, selector: Selector(sel), name: name, object: nil)
        }
    }
    
    func stopObserving() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

//MARK: - Notification
private extension KeyboardBoundsView {
    
    @objc
    func keyboardDidHideNotification(notification: NSNotification) {
        
        keyboardAppearing = false
    }
    
    @objc
    func keyboardDidShowNotification(notification: NSNotification) {
        
        keyboardAppearing = true
        
        func getKeyboardView() -> UIView? {
            
            func getUIInputSetHostView(view: UIView) -> UIView? {
                
                if let clazz = NSClassFromString("UIInputSetHostView") {
                    if view.isMemberOfClass(clazz) {
                        return view
                    }
                }
                
                for subview in view.subviews {
                    if let subview = getUIInputSetHostView(subview) {
                        return subview
                    }
                }
                return nil
            }
            
            let windows = UIApplication.sharedApplication().windows
            for window in windows {
                if let clazz = NSClassFromString("UITextEffectsWindow") {
                    if window.isKindOfClass(clazz) {
                        return getUIInputSetHostView(window)
                    }
                }
            }
            return nil
        }
        
        keyboardView = getKeyboardView()
    }
    
    @objc
    func keyboardWillChangeFrameNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.floatValue!
        
        let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue!
        
        let height = superview!.bounds.height
        
        
        heightConstraint?.constant = -(height - endFrame.origin.y)
        
        changeFrameAnimation = true
        UIView.animateWithDuration(
            NSTimeInterval(duration),
            delay: 0.0,
            options: UIViewAnimationOptions(rawValue: UInt(curve) << 16),
            animations: {
                self.superview?.layoutIfNeeded()
            },
            completion: { finished in
                self.changeFrameAnimation = false
            }
        )
        
    }
}

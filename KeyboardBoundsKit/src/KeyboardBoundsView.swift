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
    public fileprivate(set) var keyboardAppearing: Bool = false
    
    fileprivate var heightConstraint: NSLayoutConstraint?
    fileprivate var keyboardView: UIView? {
        willSet {
            keyboardView?.removeObserver(self, forKeyPath: "center")
            newValue?.addObserver(self, forKeyPath: "center", options: .new, context: nil)
        }
    }
    fileprivate var changeFrameAnimation: Bool = false
 
    /**
    intrinsicContentSize
    
    - returns: `superview?.bounds.size`
    */
    public override var intrinsicContentSize: CGSize {
        return superview?.bounds.size ?? super.intrinsicContentSize
    }
    
    /**
    didMoveToSuperview
    */
    public override func didMoveToSuperview() {
        if let newSuperview = superview {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: newSuperview,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            )
            heightConstraint = constraint
            NSLayoutConstraint.activate([constraint])
            startObserving()
            backgroundColor = UIColor.clear
        } else {
            keyboardView?.removeObserver(self, forKeyPath: "center")
            if let constraint = heightConstraint {
                NSLayoutConstraint.deactivate([constraint])
            }
            stopObserving()
            heightConstraint = nil
        }
    }
    
    
    /**
    observeValueForKeyPath:ofObject:change:context
    
    - parameter keyPath: `center`
    - parameter object:  object
    - parameter change:  change
    - parameter context: context
    */
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard changeFrameAnimation else { return }
        guard let keyboardView = keyboardView else { return }
        guard let height = superview?.bounds.height else { return }
        
        let dockDistance = UIScreen.main.bounds.height - keyboardView.frame.origin.y - keyboardView.frame.height
        
        heightConstraint?.constant = dockDistance > 0 ? 0 : keyboardView.frame.origin.y - height
        
        superview?.layoutIfNeeded()
    }
    
    /**
    drawRect
    
    - parameter rect: rect
    */
    public override func draw(_ rect: CGRect) {
        #if TARGET_INTERFACE_BUILDER
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),
                UIColor(red:0.941, green:0.941, blue:0.941, alpha: 1).CGColor)
            CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
            
            let className = "Keyboard Bounds View"
            let attr = [
                NSForegroundColorAttributeName : UIColor(red:0.796, green:0.796, blue:0.796, alpha: 1),
                NSFontAttributeName : UIFont(name: "Helvetica-Bold", size: 28)!
            ]
            let size = className.boundingRectWithSize(rect.size, options: [], attributes: attr, context: nil)
            className.drawAtPoint(CGPointMake(rect.width/2 - size.width/2, rect.height/2 - size.height/2), withAttributes: attr)
            
            if rect.height > 78.0 {
                let subTitle:NSString = "Prototype Content"
                let subAttr = [
                    NSForegroundColorAttributeName : UIColor(red:0.796, green:0.796, blue:0.796, alpha: 1),
                    NSFontAttributeName : UIFont(name: "Helvetica-Bold", size: 17)!
                ]
                let subTitleSize = subTitle.boundingRectWithSize(rect.size, options: [], attributes: subAttr, context: nil)
                subTitle.drawAtPoint(CGPointMake(rect.width/2 - subTitleSize.width/2, rect.height/2 - subTitleSize.height/2 + 30), withAttributes: subAttr)
            }
        #else
            super.draw(rect)
        #endif
    }
}

private extension KeyboardBoundsView {
    
    func startObserving() {
        
        let notifications = [
            (NSNotification.Name.UIKeyboardDidHide, #selector(self.keyboardDidHideNotification(_:))),
            (NSNotification.Name.UIKeyboardDidShow, #selector(self.keyboardDidShowNotification(_:))),
            (NSNotification.Name.UIKeyboardWillChangeFrame, #selector(self.keyboardWillChangeFrameNotification(_:))),
        ]
        
        notifications.forEach { name, sel in
            NotificationCenter.default.addObserver(self, selector: sel, name: name, object: nil)
        }
    }
    
    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK: - Notification
private extension KeyboardBoundsView {
    
    @objc
    func keyboardDidHideNotification(_ notification: Notification) {
        keyboardAppearing = false
    }
    
    @objc
    func keyboardDidShowNotification(_ notification: Notification) {
        
        keyboardAppearing = true
        
        func getKeyboardView() -> UIView? {
            
            func getUIInputSetHostView(_ view: UIView) -> UIView? {
                if let clazz = NSClassFromString("UIInputSetHostView") {
                    if view.isMember(of: clazz) {
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
            
            for window in UIApplication.shared.windows {
                if let clazz = NSClassFromString("UITextEffectsWindow") {
                    if window.isKind(of: clazz) {
                        return getUIInputSetHostView(window)
                    }
                }
            }
            return nil
        }
        
        keyboardView = getKeyboardView()
    }
    
    @objc
    func keyboardWillChangeFrameNotification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard
            let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Float,
            let _beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue,
            let beginFrame = Optional(_beginFrame.cgRectValue),
            let _endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let endFrame = Optional(_endFrame.cgRectValue)
        else {
            return
        }
        
        let height = superview!.bounds.height
        
        if endFrame.size == CGSize.zero {
            heightConstraint?.constant = beginFrame.origin.y - height
        } else {
            heightConstraint?.constant = endFrame.origin.y - height
        }
        
        
        changeFrameAnimation = true
        UIView.animate(
            withDuration: TimeInterval(duration),
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

//
//  ViewController.swift
//  KeyboardBoundsKitDemo
//
//  Created by 林達也 on 2015/09/24.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import UIKit
import KeyboardBoundsKit

class ViewController: UIViewController {

    @IBOutlet private weak var resignButton: UIButton! {
        willSet {
            newValue.transform = CGAffineTransformMakeRotation(CGFloat(45 * M_PI / 180))
        }
    }
    
    
    @IBOutlet weak var boundsView: KeyboardBoundsView! {
        willSet {
            newValue.layer.borderColor = UIColor.redColor().CGColor
            newValue.layer.borderWidth = 4
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction private func resignButtonAction(sender: AnyObject) {
        self.view.endEditing(true)
    }
    

}


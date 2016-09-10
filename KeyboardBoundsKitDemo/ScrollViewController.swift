//
//  ScrollViewController.swift
//  KeyboardBoundsKit
//
//  Created by 林達也 on 2015/09/24.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import UIKit
import KeyboardBoundsKit

class ScrollViewController: UIViewController {
    
    @IBOutlet fileprivate weak var resignButton: UIButton! {
        willSet {
            newValue.transform = CGAffineTransform(rotationAngle: CGFloat(45 * M_PI / 180))
        }
    }
    
    
    @IBOutlet weak var boundsView: KeyboardBoundsView! {
        willSet {
            newValue.layer.borderColor = UIColor.red.cgColor
            newValue.layer.borderWidth = 4
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction fileprivate func resignButtonAction(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

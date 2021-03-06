//
//  webVC.swift
//  EventsList
//
//  Created by Ray Smith on 4/19/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

import UIKit
import WebKit

class webVC: UIViewController {
    
    @IBOutlet weak var noVideoLabel: UILabel?
    @IBOutlet weak var dismissButton: UIButton?
    var webView: WKWebView?
    var video: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Force an orientation change to landscape
//        let orientationValue = UIInterfaceOrientation.LandscapeLeft.rawValue
//        UIDevice.currentDevice().setValue(orientationValue, forKey: "orientation")

        if self.video == nil {
            
            // Alert that there is no video to show
            self.noVideoLabel?.isHidden = false
            self.dismissButton?.isHidden = false
            return
            
        }else{
            
            self.noVideoLabel?.isHidden = true
            self.dismissButton?.isHidden = true
            
            let webView = WKWebView.init(frame: self.view.frame)
            self.webView = webView
            
            let myUrl = URL.init(string: self.video!)
            
            if self.webView != nil{
                self.view.addSubview(self.webView!)
                // TODO: Needs constraints?
                
                self.webView!.load(URLRequest.init(url: myUrl!))
            }
        }
    }
    
    
    @IBAction func dismissWebView() {
        self.dismiss(animated: true, completion: {
        })
    }
    
    // MARK: - Orientation allowances and changes
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        let widthValue = size.width
        if widthValue < 400 {
            
            // Rotated to portrait, exit the webView
            self.dismiss(animated: true, completion: { 
                
                
            })
            
        }else{
            
            // Rotated to landscape
            
            
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }

    /*
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

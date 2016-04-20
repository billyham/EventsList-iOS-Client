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
    
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Force an orientation change to landscape
//        let orientationValue = UIInterfaceOrientation.LandscapeLeft.rawValue
//        UIDevice.currentDevice().setValue(orientationValue, forKey: "orientation")

        let webView = WKWebView.init(frame: self.view.frame)
        self.webView = webView
        
        let myUrl = NSURL.init(string: "https://www.youtube.com/watch?v=pmLJrnN8aEU")
        
        if self.webView != nil{
            self.view.addSubview(self.webView!)
            // ____!!!! Needs constraints???  !!!!____
            
            self.webView!.loadRequest(NSURLRequest.init(URL: myUrl!))
        }
    }
    
    
    // MARK: - Orientation allowances and changes
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        let widthValue = size.width
        if widthValue < 400 {
            
            // Rotated to portrait, exit the webView
            self.dismissViewControllerAnimated(true, completion: { 
                
                
            })
            
        }else{
            
            // Rotated to landscape
            
            
        }
    }
    
    override func shouldAutorotate() -> Bool {
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

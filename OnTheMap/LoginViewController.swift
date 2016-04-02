//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Long Wang on 2016-01-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    

    //MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    var session: NSURLSession!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Get the shared URL Session
        session = NSURLSession.sharedSession()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.debugTextLabel.text = ""
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        if usernameTextField.text!.isEmpty {
            displayAlert("Email Empty.")
        } else if passwordTextField.text!.isEmpty {
            displayAlert("Password Empty.")
        } else {
            
            //Steps for Authentication ...
            let username = usernameTextField.text
            let password = passwordTextField.text
            OTMClient.sharedInstance().loginWithUserName(username!, password: password!) { (success, userID, sessionID, errorString) in
                
                if success {
                    OTMClient.sharedInstance().sessionID = sessionID
                    OTMClient.sharedInstance().userID =  userID
                    self.completeLogin()
                    
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    
    @IBAction func signUpButtonTouch(sender: AnyObject) {
        
        let app = UIApplication.sharedApplication()
        let toOpen = "https://www.udacity.com/account/auth#!/signup"
        app.openURL(NSURL(string: toOpen)!)
    }
    

    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
            //print("Session ID: " + OTMClient.sharedInstance().sessionID!)
            //print("User ID: " + String(OTMClient.sharedInstance().userID))
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OTMTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }

    
    
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        })
    }
    
    func displayAlert(alertString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let alertString = alertString {
                let alertController = UIAlertController(title: "", message: "\(alertString)", preferredStyle: .Alert)
                let dismiss = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) -> Void in }
                alertController.addAction(dismiss)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
}

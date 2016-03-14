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
        usernameTextField.text = "lw3111@intl.att.com"
        passwordTextField.text = "F0rever.ud"
        
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
            displayError("Email Empty.")
        } else if passwordTextField.text!.isEmpty {
            displayError("Password Empty.")
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
    
}

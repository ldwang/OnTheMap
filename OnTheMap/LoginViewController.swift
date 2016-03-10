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
            loginWithUdacity()
        }
    }
    
    // MARK: Login with Udacity Username/Password
    func loginWithUdacity() {
    
        /* Build the URL and configure the request */
        let urlString = OTMClient.Constants.UdacityBaseURLSecure + OTMClient.Methods.Session
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(usernameTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.displayError("\(error)")
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            
            //print(response)
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            
            
            /* Parse the data and use the data (happens in completion handler) */
            let parsedResult: AnyObject!
            do {
                //Remove first 5 characters from data
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                
            } catch {
                parsedResult = nil
                return
            }
            //GUARD: Did the Udacity Authentication return an error?
            guard parsedResult.objectForKey("account")!["registered"] as! Bool  else {
                print("The User is not registered. See the errors in \(parsedResult)")
                return
            }
            
            guard let accountKey = parsedResult.objectForKey("account")!["key"] as? String else {
                print("\(parsedResult.objectForKey("account")!["key"])")
                print("The account Key is no available. See the errors in \(parsedResult)")
                return
            }
            
            guard let sessionID = parsedResult.objectForKey("session")!["id"] as? String else {
                print("The session id is not valid. See the errors in \(parsedResult)")
                return
            }
            
            //Use the data
            OTMClient.sharedInstance().sessionID = sessionID
            OTMClient.sharedInstance().userID =  Int(accountKey)
            self.completeLogin()
        }
        
        /* 7. Start the request */
        task.resume()

    }
    

    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
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

//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Long Wang on 2016-01-26.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import UIKit
import Foundation

// Mark: OTMClient (Convenient Resource Methods)

extension OTMClient {
    
    //Mark: Login Udacity with Username/Password
    func loginWithUserName(username: String, password: String, completionHandler: (success: Bool, userID: String?, sessionID: String?, errorString: String?) -> Void ) {
        
        let site = "Udacity"
        let method = OTMClient.Methods.Session
        let parameters = [String: AnyObject]()
        let jsonBody : [String: AnyObject] = [
            "udacity" : [
                "username" : "\(username)",
                "password" : "\(password)"
            ]
        ]
        
        taskForPOSTMethod(site, method: method, parameters: parameters, jsonBody: jsonBody) { jsonResult, error in
            if let error = error {
                let errorCode = error.code
                if errorCode == 403 {
                    completionHandler(success: false, userID: nil, sessionID: nil, errorString: "Invalid Email or Password.")
                } else {
                    completionHandler(success: false, userID: nil, sessionID: nil, errorString: error.localizedDescription)
                }
            } else {
                //Did the Udacity Authentication return an error?
                if jsonResult.objectForKey("account")!["registered"] as! Bool {
                    if let accountKey = jsonResult.objectForKey("account")!["key"] as? String {
                        if let sessionID = jsonResult.objectForKey("session")!["id"] as? String {
                            completionHandler(success: true, userID: accountKey, sessionID: sessionID, errorString: nil)
                        } else {
                            print("The session id is not valid. See the errors in \(jsonResult)")
                            completionHandler(success: false, userID: nil, sessionID: nil, errorString: "Login Udacity Failed(Session ID)")
                        }
                    } else {
                        print("The user ID is no available. See the errors in \(jsonResult)")
                        completionHandler(success: false, userID: nil, sessionID: nil, errorString: "Login Udacity Failed(User ID)")
                    }
                } else {
                    print("The User is not registered. See the errors in \(jsonResult)")
                    completionHandler(success: false, userID: nil, sessionID: nil, errorString: "Login Udacity Failed(Account not registered.)")
                }
            }
        }
    }
    
    func logoutUdacity(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void){
        /* Build the URL and configure the request */
        let urlString = OTMClient.Constants.UdacityBaseURLSecure + OTMClient.Methods.Session
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, errorString: error?.localizedDescription)
            } else {
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }
    
    func getStudentLocations(completionHandler: (success: Bool, locations: [StudentInformation], errorString: String?) -> Void) {
        let site = "Parse"
        let method = OTMClient.Methods.StudentLocation
        let parameters = [
            "limit" : 100,
            "order" : "-updatedAt"]
        taskForGETMethod(site, method: method, parameters: parameters) { (jsonResult, error) in
            if let error = error {
                print(error)
                completionHandler(success: false, locations: [StudentInformation](), errorString: "Get Students Location Data Failed.(\(error.localizedDescription))")
            } else {
                if let results = jsonResult["results"] as? [[String : AnyObject]] {
                    var locations: [StudentInformation] = [StudentInformation]()
                    locations = StudentInformation.studentInformationFromResults(results)
                    completionHandler(success: true, locations: locations, errorString: nil)
                } else {
                    print("Cannot find key 'results' in \(jsonResult)")
                    completionHandler(success: false, locations: [StudentInformation](), errorString: "Cannot find key 'results' in the response data.")
                }
            }
        }
    }
    
    func postStudentLocation(studentInfo: StudentInformation, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let site = "Parse"
        let method = OTMClient.Methods.StudentLocation
        let parameters = [String: AnyObject]()
        let jsonBody : [String: AnyObject] = [
            "uniqueKey" : studentInfo.uniqueKey!,
            "firstName" : studentInfo.firstName!,
            "lastName"  : studentInfo.lastName!,
            "mapString" : studentInfo.mapString!,
            "mediaURL"  : studentInfo.mediaURL!,
            "latitude"  : studentInfo.latitude!,
            "longitude" : studentInfo.longitude!
        ]
        
        taskForPOSTMethod(site, method: method, parameters: parameters, jsonBody: jsonBody) { jsonResult, error in
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Post Student Location Failed.(\(error.localizedDescription))")
            } else {
                if let createdAt = jsonResult.objectForKey("createdAt") as? String {
                    completionHandler(success: true, errorString: nil)
                    print("Post the student location successful(createdAt: \(createdAt)).")
                } else {
                    print("No createdAt time returned from postStudentLocation Function. See errors in (jsonResult)")
                    completionHandler(success: false, errorString: "No createdAt time returned from postStudentLocation Function.")
                }
            }
        }
    }
    
    func updateStudentLocation(studentInfo: StudentInformation, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let site = "Parse"
        let objectId : String = studentInfo.objectId!
        var mutableMethod : String = OTMClient.Methods.UpdateStudentLocation
        mutableMethod = OTMClient.subtituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.ObjectID, value: objectId)!
        let parameters = [String: AnyObject]()
        let jsonBody : [String: AnyObject] = [
            "uniqueKey" : studentInfo.uniqueKey!,
            "firstName" : studentInfo.firstName!,
            "lastName"  : studentInfo.lastName!,
            "mapString" : studentInfo.mapString!,
            "mediaURL"  : studentInfo.mediaURL!,
            "latitude"  : studentInfo.latitude!,
            "longitude" : studentInfo.longitude!
        ]
        
        taskForPUTMethod(site, method: mutableMethod, parameters: parameters, jsonBody: jsonBody) { jsonResult, error in
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Update Student Location Failed.(\(error.localizedDescription))")
            } else {
                if let updatedAt = jsonResult.objectForKey("updatedAt") as? String {
                    completionHandler(success: true, errorString: nil)
                    print("Update the student location successful(updatedAt: \(updatedAt)).")
                } else {
                    print("Update Student Location Failed. See the errors in \(jsonResult)")
                    completionHandler(success: false, errorString: "No updatedAt time returned from the updateStudentLocation function.")
                }
            }
        }
    }
    
    func getUserData(userID: String, completionHandler: (success: Bool, firstName: String?, lastName: String?, errorString: String?) -> Void) {
        let site = "Udacity"
        var mutableMethod: String = OTMClient.Methods.Users
        mutableMethod = OTMClient.subtituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.UserID, value: userID)!
        let parameters = [String: AnyObject]()
        
        taskForGETMethod(site, method: mutableMethod, parameters: parameters) { (jsonResult, error) in
            if let error = error {
                print(error)
                completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Get User Data Failed.(\(error.localizedDescription))")
            } else {
                if let user = jsonResult["user"] as? [String : AnyObject] {
                    let firstName = user["first_name"] as? String
                    let lastName = user["last_name"] as? String
                    completionHandler(success: true, firstName: firstName, lastName: lastName, errorString: nil)
                } else {
                    print("Cannot find key 'user' in \(jsonResult)")
                    completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Cannot find key 'user' in the response data.")
                }
            }
        }
    }
    
    func checkStudentID(userID: String, completionHandler: (success: Bool, locations: [StudentInformation], errorString: String?) -> Void) {
        let site = "Parse"
        let method = OTMClient.Methods.StudentLocation
        let parameters = ["where" : "{\"uniqueKey\":\"\(userID)\"}"]
        
        taskForGETMethod(site, method: method, parameters: parameters) { (jsonResult, error) in
            if let error = error {
                print(error)
                completionHandler(success: false, locations: [StudentInformation](), errorString: "Get Student(ID: \(userID) Location Data Failed.(\(error.localizedDescription))")
            } else {
                if let results = jsonResult["results"] as? [[String : AnyObject]] {
                    var locations: [StudentInformation] = [StudentInformation]()
                    locations = StudentInformation.studentInformationFromResults(results)
                    completionHandler(success: true, locations: locations, errorString: nil)
                } else {
                    print("Cannot find key 'results' in \(jsonResult)")
                    completionHandler(success: false, locations: [StudentInformation](), errorString: "Cannot find key 'results' in the response data.")
                }
            }
        }
    }
    
    func updateLocation(hostViewController: UIViewController) {
        let id = userID
        
        checkStudentID(id!) { (success, locations, errorString) in
            
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if !locations.isEmpty {
                        let alertController = UIAlertController(title: "", message: "User \"\(locations[0].firstName!) \(locations[0].lastName!) has already posted a student location. Would you like to overwrite the location?", preferredStyle: .Alert)
                        let overwrite = UIAlertAction(title: "OverWrite", style: .Default, handler: { (action) -> Void in
                            // Do whatever you want with inputTextField?.text
                            let controller = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("InfoPost")
                            hostViewController.presentViewController(controller, animated: true, completion: nil)
                        })
                        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
                        alertController.addAction(overwrite)
                        alertController.addAction(cancel)
                        hostViewController.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        let controller = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("InfoPost")
                        hostViewController.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            } else {
                self.displayAlert(hostViewController, alertString: errorString)
                print(errorString)
            }
        }
    }
    
    func displayAlert(hostViewController: UIViewController, alertString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let alertString = alertString {
                let alertController = UIAlertController(title: "", message: "\(alertString)", preferredStyle: .Alert)
                let dismiss = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) -> Void in }
                alertController.addAction(dismiss)
                hostViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
}

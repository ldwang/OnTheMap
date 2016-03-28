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
    
    func loginWithUserName(username: String, password: String, completionHandler: (success: Bool, userID: Int?, sessionID: String?, errorString: String?) -> Void ) {
        
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
                print(error)
                completionHandler(success: false, userID: nil, sessionID: nil, errorString: "Login Udacity Failed.")
            } else {
                
                //Did the Udacity Authentication return an error?
                if jsonResult.objectForKey("account")!["registered"] as! Bool {
                    
                    if let accountKey = jsonResult.objectForKey("account")!["key"] as? String {
                        
                        if let sessionID = jsonResult.objectForKey("session")!["id"] as? String {
                            
                            completionHandler(success: true, userID: Int(accountKey), sessionID: sessionID, errorString: nil)
                            
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
    
    func logoutUdacity(){
        
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
                
                return
                
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
        }
        
        task.resume()
        
    }
    
    func getStudentsLocation(completionHandler: (success: Bool, locations: [StudentInformation], errorString: String?) -> Void) {
        let site = "Parse"
        let method = OTMClient.Methods.StudentLocation
        let parameters = [
            "limit" : 100,
            "order" : "updatedAt"]
        taskForGETMethod(site, method: method, parameters: parameters) { (jsonResult, error) in
            if let error = error {
                print(error)
                completionHandler(success: false, locations: [StudentInformation](), errorString: "Get Students Location Data Failed.")
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
    
    func checkStudentID(id: Int, completionHandler: (success: Bool, locations: [StudentInformation], errorString: String?) -> Void) {
        let site = "Parse"
        let method = OTMClient.Methods.StudentLocation
        let userID = String(id)
        
        let parameters = [
            //"where" : "{\"uniqueKey\":\"1111222333444555\"}"]
            "where" : "{\"uniqueKey\":\"\(userID)\"}"]
        
        taskForGETMethod(site, method: method, parameters: parameters) { (jsonResult, error) in
            if let error = error {
                print(error)
                
                completionHandler(success: false, locations: [StudentInformation](), errorString: "Get Student(ID: \(userID) Location Data Failed.")
            } else {
                //print(jsonResult)
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
}

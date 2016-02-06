//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Long Wang on 2016-01-26.
//  Copyright © 2016 Long Wang. All rights reserved.
//

//import Foundation
extension OTMClient {
    
    struct Constants {
        
        //MARK: Parse API Key and Application ID
        static let ParseAPIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApplicationID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        //MARK: URLs
        static let UdacityBaseURLSecure : String = "https://www.udacity.com/api/"
        static let ParseBaseURLSecure: String =  "https://api.parse.com/1/classes/"
    }
    struct Methods {
        //MARK: Udacity Session and User Data
        static let Session = "session"
        static let Users = "users/{id}"
        
        //MARK: Parse Student Locations
        static let StudentLocation = "StudentLocation"
        static let UpdateStudentLocation = "StudentLocation/{objectid}"
    }
    
    //MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
        static let ObjectID = "objectid"
    }
    
    //MARK: Parameter Keys
//    
//    struct ParameterKeys {
//        static let
//    }
}
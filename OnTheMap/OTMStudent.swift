//
//  OTMStudent.swift
//  OnTheMap
//
//  Created by Long Wang on 2016-02-05.
//  Copyright © 2016 Long Wang. All rights reserved.
//

//MARK: - OTMStudent

struct StudentInformation {
    
    //MARK: Properties
    //var createdAt: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var latitude: Float? = nil
    var longitude: Float? = nil
    //var mapString: String? = nil
    var mediaURL: String? = nil
    var objectID: String? = nil
    var uniqueKey: Int? = nil
    //var updateAt: String? = nil
    
    //MARK Initializers
    
    //Constuct a OTMStudent from a dictionary
    
    init(dictionary: [String: AnyObject]) {
        
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        latitude = dictionary["latitude"] as? Float
        longitude = dictionary["longitude"] as? Float
        mediaURL = dictionary["mediaURL"] as? String
        objectID = dictionary["objectID"] as? String
        uniqueKey = dictionary["uniqueKey"] as? Int
        
    }
        
    /* Helper: Given an array of dictionaries, convert them to an array of StudentInformation objects */
    static func studentInformationFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
            
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        //print(students)
        return students
    }

}

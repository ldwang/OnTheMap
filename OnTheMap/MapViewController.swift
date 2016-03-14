//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Long Wang on 2016-01-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//


import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logutButton: UIBarButtonItem!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    //var locations: [StudentInformation] = [StudentInformation]()
    
    var session: NSURLSession!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Get the shared URL Session
        session = NSURLSession.sharedSession()
        
        //Get the last top 100 student locations
        refreshMap()
    
    }
   
    @IBAction func logoutButtonTouchUpInside(sender: AnyObject) {
        OTMClient.sharedInstance().logoutUdacity()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pinButtonTouchUpInside(sender: AnyObject) {
        checkStudentID()
    }
 
    @IBAction func refreshButtonTouchUpInside(sender: AnyObject) {
        self.mapView.removeAnnotations(mapView.annotations)
        refreshMap()
    }
    
    
    func refreshMap() {
        OTMClient.sharedInstance().getStudentsLocation { (success, locations, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showStudentLocations(locations)
                    //print(locations)
                }
            } else {
                print(errorString)
            }
        }
    }
    
    func showStudentLocations(locations: [StudentInformation]) {
        
        var annotations = [MKPointAnnotation]()
        
        for location  in locations  {
            
            let lat = CLLocationDegrees(location.latitude! )
            let long = CLLocationDegrees(location.longitude!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName! as String
            let last = location.lastName! as String
            let mediaURL = location.mediaURL! as String
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    func checkStudentID() {
        let id = String(OTMClient.sharedInstance().userID!)
        print(id)
        let urlString = OTMClient.Constants.ParseBaseURLSecure + OTMClient.Methods.StudentLocation + "?where=%7B%22uniqueKey%22%3A%22\(id)%22%7D"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(OTMClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        //let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
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
            
            print(response)
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                
            } catch {
                parsedResult = nil
                return
            }
            
            print(parsedResult)
            /* GUARD: Is the "results" key in parsedResult? */
            guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                print("Cannot find key 'results' in \(parsedResult)")
                return
            }
            
            /* 6. Use the data! */
            dispatch_async(dispatch_get_main_queue()) {
                var locations: [StudentInformation] = [StudentInformation]()
                locations = StudentInformation.studentInformationFromResults(results)
                //self.showStudentLocations(locations)
                print(locations)
            }
            
        }
        
        task.resume()
    
    }
    

    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }


}
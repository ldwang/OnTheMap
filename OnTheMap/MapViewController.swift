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
        updateLocation()
    }
 
    @IBAction func refreshButtonTouchUpInside(sender: AnyObject) {
        self.mapView.removeAnnotations(mapView.annotations)
        refreshMap()
    }
    
    func updateLocation() {
        
        let id = OTMClient.sharedInstance().userID
        OTMClient.sharedInstance().checkStudentID(id!) { (success, locations, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    //print(locations)
                    if !locations.isEmpty {
                    
                    let alertController = UIAlertController(title: "", message: "User \"\(locations[0].firstName!) \(locations[0].lastName!) has already posted a student location. Would you like to overwrite the location?", preferredStyle: .Alert)
                    let overwrite = UIAlertAction(title: "OverWrite", style: .Default, handler: { (action) -> Void in
                        // Do whatever you want with inputTextField?.text
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPost") 
                        self.presentViewController(controller, animated: true, completion: nil)
                    })
                    let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
                    
                    alertController.addAction(overwrite)
                    alertController.addAction(cancel)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPost")
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            } else {
                print(errorString)
            }
        }
        
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
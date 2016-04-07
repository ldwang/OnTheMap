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
        OTMClient.sharedInstance().logoutUdacity(self) { success, errorString in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                OTMClient.sharedInstance().displayAlert(self, alertString: errorString)
            }
        }
        
    }
    
    @IBAction func pinButtonTouchUpInside(sender: AnyObject) {
        OTMClient.sharedInstance().updateLocation(self)
    }
 
    @IBAction func refreshButtonTouchUpInside(sender: AnyObject) {
        self.mapView.removeAnnotations(mapView.annotations)
        refreshMap()
    }
    
        
    
    func refreshMap() {
        
        OTMClient.sharedInstance().getStudentLocations { (success, locations, errorString) in
            if success {
                OTMClient.sharedInstance().studentLocations = locations
                dispatch_async(dispatch_get_main_queue()) {
                    self.showStudentLocations(OTMClient.sharedInstance().studentLocations)
                    //print(locations)
                }
            } else {
                OTMClient.sharedInstance().displayAlert(self, alertString: errorString)
                print(errorString!)
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
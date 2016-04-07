//
//  InfoPostViewController.swift
//  OnTheMap
//
//  Created by Long Wang on 2016-03-10.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class InfoPostViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var topLabel1: UILabel!
    @IBOutlet weak var topLabel2: UILabel!
    @IBOutlet weak var topLabel3: UILabel!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var promptMiddleView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var state = 0 //0 - prompt state for location input; 1 - Sumbit state for showing map and URL
    var location: CLLocation? = nil

    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIForState(state)
        locationTextField.delegate = self
        urlTextField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InfoPostViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        activityIndicator.hidden = true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func cancelButtonTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func findButtonTouch(sender: AnyObject) {
        if locationTextField.text!.isEmpty || locationTextField.text!=="Enter The Location Here" {
            OTMClient.sharedInstance().displayAlert(self, alertString:"Must Entr a Location.")
        } else {
            
            enableActivityIndicator()
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(locationTextField.text!) {(placemarks, error) in
            
                guard error == nil else {
                    self.disableActivityIndicator()
                    OTMClient.sharedInstance().displayAlert(self, alertString:"Could Not Geocode the String.")
                    return
                }
                
                guard placemarks?.count > 0 else {
                    self.disableActivityIndicator()
                    OTMClient.sharedInstance().displayAlert(self, alertString:"Could Not Geocode the String.")
                    return
                }
                
                self.disableActivityIndicator()
                let placemark = placemarks![0]
                self.location = placemark.location
                let annotation = MKPointAnnotation()
                annotation.coordinate = placemark.location!.coordinate
                //Setup the region
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                //Add and show the annotation on the map
                self.mapView.addAnnotation(annotation)
                self.state = 1
                self.configureUIForState(self.state)
               
            }
        }
    }

    @IBAction func submitButtonTouch(sender: AnyObject) {
        if urlTextField.text!.isEmpty || urlTextField.text!=="Enter a Link to Share Here" {
            OTMClient.sharedInstance().displayAlert(self, alertString:"Must Enter a URL Link.")
        } else {
            let id = OTMClient.sharedInstance().userID
            OTMClient.sharedInstance().checkStudentID(id!) { (success, studentInformations, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        if !studentInformations.isEmpty {
                            
                            let studentInfomation = studentInformations[0]
                            print(studentInfomation)
            
                            let dict = [
                                "uniqueKey" : id!,
                                "firstName" : studentInfomation.firstName!,
                                "lastName"  : studentInfomation.lastName!,
                                "mapString" : self.locationTextField.text!,
                                "mediaURL"  : self.urlTextField.text!,
                                "latitude"  : (self.location?.coordinate.latitude)!,
                                "longitude" : (self.location?.coordinate.longitude)!,
                                "objectId"  : studentInfomation.objectId!
                            ]
                            let info = StudentInformation(dictionary: dict as! [String : AnyObject])
                            
                            //print(info)
                            OTMClient.sharedInstance().updateStudentLocation(info) { success, error in
                             
                                if success {
                                    print("Successfully Update Student Location.")
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    } else {
                                        OTMClient.sharedInstance().displayAlert(self, alertString:"Update Student Location failed.(\(error))")
                                    }
                            }
                        } else {
                            OTMClient.sharedInstance().getUserData(id!) { success, firstName, lastName, error in
                                if success {
                                    let dict = [
                                        "uniqueKey" : id!,
                                        "firstName" : firstName!,
                                        "lastName"  : lastName!,
                                        "mapString" : self.locationTextField.text!,
                                        "mediaURL"  : self.urlTextField.text!,
                                        "latitude"  : (self.location?.coordinate.latitude)!,
                                        "longitude" : (self.location?.coordinate.longitude)!
                                    ]
                                    let info = StudentInformation(dictionary: dict as! [String : AnyObject])
                                    
                                    OTMClient.sharedInstance().postStudentLocation(info) { success, error in
                                        if success {
                                            print("Successfully Create Student Location.")
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        } else {
                                            OTMClient.sharedInstance().displayAlert(self, alertString: "Create Student Location failed.(\(error))")
                                        }
                                    }
                                } else {
                                    OTMClient.sharedInstance().displayAlert(self, alertString:"Get User Data Failed.")
                                }
                            }
                        }
                    }
                } else {
                    OTMClient.sharedInstance().displayAlert(self, alertString:"Check Student Location by ID Failed.")
                }
            }
        }
    }
    
    //Text Field Delegate Methods
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text!.isEmpty && textField == locationTextField {
            locationTextField.text = "Enter The Location Here"
        } else if textField.text!.isEmpty && textField == urlTextField {
            urlTextField.text = "Enter a Link to Share Here"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Change the UI states
    func configureUIForState(state: Int) {
        if state == 0 {
            topLabel1.hidden = false
            topLabel2.hidden = false
            topLabel3.hidden = false
            findButton.hidden = false
            locationTextField.hidden = false
            submitButton.hidden = true
            urlTextField.hidden = true
            mapView.hidden = true
            promptMiddleView.hidden = false
            view.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)

        } else {
            topLabel1.hidden = true
            topLabel2.hidden = true
            topLabel3.hidden = true
            findButton.hidden = true
            locationTextField.hidden = true
            urlTextField.hidden = false
            mapView.hidden = false
            promptMiddleView.hidden = true
            submitButton.hidden = false
            cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            view.backgroundColor = UIColor(red:0.0, green:0.25, blue:0.5, alpha:1.0)
        }
        
    }
    
    
    func enableActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        self.view.alpha = 0.5
    }
    
    func disableActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        self.view.alpha = 1
    }

}


//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Long Wang on 2016-01-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import UIKit

class ListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource  {
    

    @IBOutlet weak var tableView: UITableView!

    
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if OTMClient.sharedInstance().studentLocations.isEmpty {
            
            OTMClient.sharedInstance().getStudentLocations { (success, locations, errorString) in
                if success {
                    OTMClient.sharedInstance().studentLocations = locations
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                } else {
                    print(errorString)
                }
            }
                
        } else {
            self.tableView.reloadData()
        }

    }

    
    @IBAction func logoutButtonTouchUpInside(sender: AnyObject) {
    
        OTMClient.sharedInstance().logoutUdacity()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pinButtonTouchUpInside(sender: AnyObject) {
       
        OTMClient.sharedInstance().updateLocation(self)
        
    }
    
    @IBAction func refreshButtonTouchUpInside(sender: AnyObject) {
        
        OTMClient.sharedInstance().getStudentLocations { (success, locations, errorString) in
            if success {
                OTMClient.sharedInstance().studentLocations = locations
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            } else {
                print(errorString)
            }
        }

    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTMClient.sharedInstance().studentLocations.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get cell type
        let cellReuseIdentifier = "ListCell"
        let location = OTMClient.sharedInstance().studentLocations[indexPath.row]
        //print(location)
        let cell = tableView.dequeueReusableCellWithIdentifier( cellReuseIdentifier, forIndexPath: indexPath) as UITableViewCell!
        
        // Configure the cell...
        
        cell.textLabel?.text = location.firstName! + " " + location.lastName!
        cell.detailTextLabel?.text = location.mediaURL!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = OTMClient.sharedInstance().studentLocations[indexPath.row]
        let app = UIApplication.sharedApplication()
        if let toOpen = location.mediaURL {
            app.openURL(NSURL(string: toOpen)!)
        }
    }
    
}
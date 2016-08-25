//
//  DashboardViewController.swift
//  WeatherApp
//
//  Created by Nithin Reddy Gaddam on 8/24/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

var arrLocations:[String] = []
var arrState:[String] = []

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var strTitle: String = "Dashboard"
    var arrTemp:[String] = []
    var arrCondition:[String] = []
    var index = 0
    var rightButton : UIBarButtonItem!
    
    @IBOutlet weak var tblView: UITableView!
    
    var configurationOK = false
    let reuseIdentifier = "idCellDashboard"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rightButton = UIBarButtonItem(image: UIImage(named:"plus-simple-7.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(askLocation))
        self.navigationItem.rightBarButtonItem = rightButton
        
        if !configurationOK {
            configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
        
    }
    
    func askLocation(){
        
        let alertController = UIAlertController(title: "Add Location", message: "Please enter a Location and State code or Country if outside US ( San Diego:CA || Paris:France)  : ", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let OKAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 || textfield.text?.lowercaseString == loggedUser.username {
                self.askLocation()
            }
            else {
                let address = textfield.text!.characters.split{$0 == ":"}.map(String.init)
                
                arrLocations.append(address[0].stringByReplacingOccurrencesOfString(" ", withString: "_"))
                arrState.append(address[1].stringByReplacingOccurrencesOfString(" ", withString: "_"))
                
                self.fetchData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.locationManager.stopUpdatingLocation()
                let location = pm.locality!
                var state: String?
                
                if pm.country != "United States"{
                    state = pm.administrativeArea!
                }
                else{
                    state = pm.country!
                }
                
                if arrLocations.count > 0{
                    arrLocations.insert(location, atIndex: 0)
                    arrState.insert(state!, atIndex: 0)
                }
                else{
                    arrLocations.append(location)
                    arrState.append(state!)
                }
                
                self.fetchData()
                
                
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func fetchData() {
        
        let path = NSBundle.mainBundle().pathForResource("Property List", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        let key = dict!.objectForKey("APIKey") as! String
        
        for i in 0 ..< arrLocations.count  {
            
            let location = arrLocations[i].stringByReplacingOccurrencesOfString(" ", withString: "_")
            let state = arrState[i].stringByReplacingOccurrencesOfString(" ", withString: "_")
            
            Alamofire.request(.GET, "http://api.wunderground.com/api/" + key + "/conditions/q/" + state + "/" + location + ".json")
                .responseJSON { response in
                    
                    switch response.result {
                    case .Success:
                        let json = JSON(data: response.data!)
                        
                        print(json)
                        
                        if self.arrTemp.count > 0{
                            self.arrTemp.insert(String(json["temp_f"]), atIndex: 0)
                            self.arrCondition.insert(String(json["condition"]).stringByReplacingOccurrencesOfString(" ", withString: ""), atIndex: 0)
                        }
                        else{
                            self.arrTemp.append(String(json["temp_f"]))
                            self.arrCondition.append((String(json["weather"]).stringByReplacingOccurrencesOfString(" ", withString: "")).lowercaseString)
                        }
                        
                        
                    case .Failure(let error):
                        self.arrTemp.append("n/a")
                        print(error)
                    }
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tblView.reloadData()
            self.tblView.hidden = false
        })

        
    }
    
    func configureNavigationBar() {
        navigationItem.title = strTitle
    }
    
    
    func configureTableView() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.registerNib(UINib(nibName: "DashboardCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tblView.estimatedRowHeight = 80.0
        tblView.rowHeight = UITableViewAutomaticDimension
        tblView.tableFooterView = UIView(frame: CGRectZero)
        tblView.hidden = true
        
    }
    
    
    // MARK: UITableView Delegate and Datasource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocations.count
    }
    
    //displays user's information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

            let cell:DashboardCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! DashboardCell
            cell.Location.text = arrLocations[indexPath.row]
            cell.Time.text = arrState[indexPath.row]
            cell.Temperature.text = arrTemp[indexPath.row]
            cell.url = "http://icons.wxug.com/i/c/k/" + arrCondition[indexPath.row] + ".gif"
        
            return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        self.performSegueWithIdentifier("detailSegue", sender: nil)
//        index = indexPath.row
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "detailSegue" {
//                let detailWeatherViewController = segue.destinationViewController as! DetailWeatherViewController
//                                detailWeatherViewController.index = index
            }
        }
    }
    
    
}


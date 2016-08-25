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
import SimpleKeychain


class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var myGroup = dispatch_group_create()
    var strTitle: String = "Dashboard"
    var arrTemp:[String] = []
    var arrCondition:[String] = []
    var arrTime:[String] = []
    var index = 0
    var rightButton : UIBarButtonItem!
    var leftButton : UIBarButtonItem!
    var arrLocations:[String] = []
    var arrState:[String] = []
    
    @IBOutlet weak var tblView: UITableView!
    
    var configurationOK = false
    let reuseIdentifier = "idCellDashboard"
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DashboardViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.hidesNavigationBarHairline = false
        
        self.tblView.addSubview(self.refreshControl)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        leftButton = UIBarButtonItem(image: UIImage(named:"plus-simple-7.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(askLocation))
        rightButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(logOut))
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
//        self.navigationItem.title = loggedUser.fName! + " " + loggedUser.lName!

        
        if !configurationOK {
            configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
        
    }
    
    func logOut(){
        A0SimpleKeychain().deleteEntryForKey("user-jwt")
        
        loggedUser = User()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(loggedUser)
        userDefaults.setObject(encodedData, forKey: "loggedUser")
        userDefaults.synchronize()
        
        let vc : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginView") as UIViewController!;
        self.presentViewController(vc, animated: true, completion: nil)
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
                
                if( address.count > 0){
                    self.arrLocations.append(address[0].stringByReplacingOccurrencesOfString(" ", withString: "_"))
                    self.arrState.append(address[1].stringByReplacingOccurrencesOfString(" ", withString: "_"))
                    
                }
                
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
                
                if self.arrLocations.count > 0{
                    self.arrLocations.insert(location, atIndex: 0)
                    self.arrState.insert(state!, atIndex: 0)
                }
                else{
                    self.arrLocations.append(location)
                    self.arrState.append(state!)
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
        
        self.arrTemp = []
        self.arrTime = []
        self.arrCondition = []
        
        for i in 0 ..< self.arrLocations.count  {
            dispatch_group_enter(myGroup)
            
            Alamofire.request(.GET, "http://api.wunderground.com/api/" + key + "/conditions/q/" + self.arrState[i].stringByReplacingOccurrencesOfString(" ", withString: "_") + "/" + self.arrLocations[i].stringByReplacingOccurrencesOfString(" ", withString: "_") + ".json")
                .responseJSON { response in
                    
                    let json = JSON(data: response.data!)
                    
                    print(json["current_observation"]["temp_f"])
                    
                    if  json["current_observation"]["temp_f"] != nil{
                        
                        self.arrTemp.append(String(json["current_observation"]["temp_f"]))
                        self.arrCondition.append(String(json["current_observation"]["icon_url"]))
                        
                        let time = String(json["current_observation"]["local_time_rfc822"]).characters.split{$0 == " "}.map(String.init)
                        self.arrTime.append(time[4])
                        
                    }
                    else{
                        self.arrTemp.append("n/a")
                        self.arrTime.append("n/a")
                        self.arrCondition.append("n/a")
                    }
                    
                    dispatch_group_leave(self.myGroup)
                    
            }
            
            dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
                self.reloadTable()
            })
            
        }
    }
    
    
    func reloadTable(){
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
        return self.arrLocations.count
    }
    
    //displays user's information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:DashboardCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! DashboardCell
        cell.Location.text = self.arrLocations[indexPath.row]
        cell.Time.text = self.arrTime[indexPath.row]
        cell.Temperature.text = self.arrTemp[indexPath.row]
        
        if let url = NSURL(string: self.arrCondition[indexPath.row]) {
            if let data = NSData(contentsOfURL: url) {
                cell.Img.image = UIImage(data: data)
            }
        }
            
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
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        fetchData()
        refreshControl.endRefreshing()
    }
    
    
}


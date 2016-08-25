//
//  LoginViewController.swift
//  WeatherApp
//
//  Created by Nithin Reddy Gaddam on 8/24/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import ChameleonFramework
import ARSLineProgress
import Alamofire
import SwiftyJSON
import SimpleKeychain
import SkyFloatingLabelTextField

var loggedUser = User();

class LoginViewController: UIViewController {
    
    //Variables
    
    var username = SkyFloatingLabelTextField()
    var password = SkyFloatingLabelTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        // setting the floating labels on Login Screen
        username = SkyFloatingLabelTextField(frame: CGRectMake(screenSize.midX - 95, screenSize.midY - 140, 200, 45))
        password = SkyFloatingLabelTextField(frame: CGRectMake(screenSize.midX - 95, screenSize.midY - 90, 200, 45))
        
        username.placeholder = "Username"
        username.title = "Username"
        username.autocapitalizationType = .None
        self.view.addSubview(username)
        
        // the color of the blinking cursor
        username.tintColor = UIColor.flatSkyBlueColorDark()
        username.textColor = UIColor.flatYellowColor()
        username.placeholderColor = UIColor.flatYellowColor()
        username.lineColor = UIColor.flatYellowColor()
        username.selectedTitleColor = UIColor.flatSkyBlueColor()
        username.selectedLineColor = UIColor.flatSkyBlueColor()
        
        password.placeholder = "Password"
        password.title = "Password"
        password.secureTextEntry = true
        self.view.addSubview(password)
        
        password.tintColor = UIColor.flatSkyBlueColorDark()
        password.textColor = UIColor.flatYellowColor()
        password.placeholderColor = UIColor.flatYellowColor()
        password.lineColor = UIColor.flatYellowColor()
        password.selectedTitleColor = UIColor.flatSkyBlueColor()
        password.selectedLineColor = UIColor.flatSkyBlueColor()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // check if user is already logged in
        let jwt = A0SimpleKeychain().stringForKey("user-jwt") as String?
        
        if(jwt != nil && loggedUser.id != nil){
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func IBLogin(sender: AnyObject) {
        
//        view.endEditing(true) //dismiss keyboard
//        
//        if(self.username.text != nil && self.password.text != nil){
//            
//            let path = NSBundle.mainBundle().pathForResource("PropertyList", ofType: "plist")
//            let dict = NSDictionary(contentsOfFile: path!)
//            let url = dict!.objectForKey("awsURL") as! String
//            
//            Alamofire.request(.POST, "http://" + url + "/login", parameters: ["username": self.username.text!, "password": self.password.text!])
//                .responseJSON { response in
//                    
//                    let json = JSON(data: response.data!)
//                    
//                    if json["user"]["_id"] != nil {
//                        
//                        let jwt = json["token"].string
//                        A0SimpleKeychain().setString(jwt!, forKey:"user-jwt")
//                        
//                        if ARSLineProgress.shown { return }
//                        
//                        progressObject = NSProgress(totalUnitCount: 30)
//                        ARSLineProgress.showWithProgressObject(progressObject!, completionBlock: {
//                            
//                            loggedUser = User(id: json["user"]["_id"].string!, username: json["user"]["username"].string!, fName: json["user"]            ["firstName"].string!, lName: json["user"]["lastName"].string!, eMail: json["user"]["email"].string!)
//                            
//                            let userDefaults = NSUserDefaults.standardUserDefaults()
//                            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(loggedUser)
//                            userDefaults.setObject(encodedData, forKey: "loggedUser")
//                            userDefaults.synchronize()
//                            
//                            self.performSegueWithIdentifier("loginSegue", sender: nil)
//                            
//                        })
//                        
//                        self.progressDemoHelper(success: true)
//                        
//                    }
//                    else{
//                        if ARSLineProgress.shown { return }
//                        
//                        progressObject = NSProgress(totalUnitCount: 30)
//                        ARSLineProgress.showWithProgressObject(progressObject!, completionBlock: {
//                            print("This copmletion block is going to be overriden by cancel completion block in launchTimer() method.")
//                        })
//                        
//                        self.progressDemoHelper(success: false)
//                    }
//            }
//        }
        
        self.performSegueWithIdentifier("loginSegue", sender: nil)
    }
}


private var progress: CGFloat = 0.0
private var progressObject: NSProgress?
private var isSuccess: Bool?

extension LoginViewController {
    
    private func progressDemoHelper(success success: Bool) {
        isSuccess = success
        launchTimer()
    }
    
    private func launchTimer() {
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)));
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            progressObject!.completedUnitCount += Int64(arc4random_uniform(30))
            
            if isSuccess == false && progressObject?.fractionCompleted >= 0.7 {
                ARSLineProgress.cancelPorgressWithFailAnimation(true, completionBlock: {
                    print("Hidden with completion block")
                })
                return
            } else {
                if progressObject?.fractionCompleted >= 1.0 { return }
            }
            
            self.launchTimer()
        })
    }
    
    
    
}


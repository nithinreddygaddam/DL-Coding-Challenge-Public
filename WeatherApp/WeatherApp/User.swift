//
//  User.swift
//  WeatherApp
//
//  Created by Nithin Reddy Gaddam on 8/24/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    var id      : String?
    var username : String?
    var fName   : String?
    var lName   : String?
    var eMail   : String?
    
    init(   id      : String,
            username : String,
            fName   : String,
            lName   : String,
            eMail   : String){
        
        super.init()
        self.id         = id
        self.username   = username
        self.fName      = fName
        self.lName      = lName
        self.eMail      = eMail
    }
    
    override init(){
        self.id         = nil
        self.username   = nil
        self.fName      = nil
        self.lName      = nil
        self.eMail      = nil
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObjectForKey("id") as! String?
        let username = aDecoder.decodeObjectForKey("username") as! String?
        let fName = aDecoder.decodeObjectForKey("fName") as! String?
        let lName = aDecoder.decodeObjectForKey("lName") as! String?
        let eMail = aDecoder.decodeObjectForKey("eMail") as! String?
        if(id != nil ){
            self.init(id: id!, username: username!, fName: fName!, lName: lName!, eMail: eMail!)
        }
        else{
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.fName, forKey: "fName")
        aCoder.encodeObject(self.lName, forKey: "lName")
        aCoder.encodeObject(self.eMail, forKey: "eMail")
    }
    
    func isEmpty() -> Bool {
        if self.id == nil{
            return true
        }
        else{
            return false
        }
        
    }
    
}
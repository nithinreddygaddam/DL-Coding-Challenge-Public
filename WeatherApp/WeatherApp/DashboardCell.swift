//
//  UserCell.swift
//  weebyChat
//
//  Created by Nithin Reddy Gaddam on 5/13/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class DashboardCell: UITableViewCell {

    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Temperature: UILabel!
    @IBOutlet weak var Img: UIImageView!
    
    var url: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        if let url = NSURL(string: url!) {
//            if let data = NSData(contentsOfURL: url) {
//                Img.image = UIImage(data: data)
//            }        
//        }
       
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}

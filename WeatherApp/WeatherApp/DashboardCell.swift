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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}

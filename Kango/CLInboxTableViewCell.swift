//
//  CLInboxTableCellView.swift
//  Kango
//
//  Created by James Majidian on 12/21/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class CLInboxTableViewCell : UITableViewCell
{
    @IBOutlet weak var imgUser: UIImageView!;
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!;
    
    func bind(msg: InboxMessage)
    {
        self.imgUser.image = UIImage(named: "no_image");
        self.lblUserName.text = msg.fromUser;
        self.lblTime.text = msg.timeAgo;
        
        //self.lblMessage.text = msg.media.title;
        if(!msg.isRead)
        {
            self.backgroundColor = UIColor.lightGray;
        }
        else
        {
            self.backgroundColor = UIColor.white;
        }
        
        self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        // Configure the view for the selected state
    }
}

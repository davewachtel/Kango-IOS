//
//  CLShareView.swift
//  Kango
//
//  Created by James Majidian on 12/25/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class CLShareView : UITableView
{
    @IBOutlet weak var btnCancel : UIButton?;
    @IBOutlet weak var btnShare : UIButton?;
    
    var navBar: UINavigationBar?;
    
    var shareDelegate: CLShareViewDelegate?;
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        if(navBar != nil)
        {
            self.navBar?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: 44);
        }
    }
    
    @IBAction func cancel(AnyObject)
    {
        self.shareDelegate?.cancel();
    }
    
    @IBAction func share(AnyObject)
    {
        self.shareDelegate?.share();
    }
    
}
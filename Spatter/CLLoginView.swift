//
//  CLLoginView.swift
//  Kango
//
//  Created by James Majidian on 11/15/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class CLLoginView : UIView
{
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!;
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    @IBAction func buttonTapped(AnyObject) {
        
        spinner.startAnimating();
        
        
        
    }
    
    
}
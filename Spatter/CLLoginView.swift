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
    
    var delegate: CLLoginViewDelegate!;
    
    @IBAction func buttonTapped(AnyObject) {
        
        spinner.startAnimating();
        spinner.hidden = false;
        
        self.delegate.authenticate(txtUsername.text, password: txtPassword.text, completion: { () in
            self.spinner.stopAnimating();
            self.spinner.hidden = true;
        });
    }
}
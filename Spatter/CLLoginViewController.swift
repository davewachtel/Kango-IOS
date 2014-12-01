//
//  CLLandingController.swift
//  Kango
//
//  Created by James Majidian on 11/15/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

protocol CLLoginViewDelegate {
    func authenticate(username: String, password: String, completion: () -> Void);
}

class CLLoginViewController : GAITrackedViewController, CLLoginViewDelegate
{
    var api = LoginApiController();
    var authToken: Token?;
    
    func authenticate(username: String, password: String, completion: () -> Void) {
        
        api.login(username
            , password: password
            , success: {
                (token: Token) -> () in
                    self.login_success(token);
                    completion();
                
            },
            error: {
                (message: String?) -> () in
                    self.login_failed(message);
                    completion();
        });
        
        NSLog("authenticate");
    }
    
    func login_success(token: Token) -> Void
    {
        var success = token.saveToken();
        self.authToken = token;
        
        self.performSegueWithIdentifier("LoginSuccessSegue", sender: self);
    }
    
    func login_failed(message: String?) -> Void
    {
        var msg: String = "Your login was incorrect.  Please try again.";
        if(message != nil)
        {
            msg = message!;
        }
        
        var alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var loginView = self.view as CLLoginView;
        loginView.delegate = self;
        
        var token = Token.loadValidToken();
        if(token != nil)
        {
            self.login_success(token!);
            
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender);
        
        if(segue.identifier == "LoginSuccessSegue")
        {
            var mediaVC = segue.destinationViewController as CLPlaygroundViewController;
            mediaVC.authToken = self.authToken;
        }
    }

}
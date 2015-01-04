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
    }
    
    func login_success(token: Token) -> Void
    {
        var success = token.saveToken();
        CLInstance.sharedInstance.authToken = token;
        
        if(NSThread.isMainThread())
        {
             self.performSegueWithIdentifier("LoginSuccessSegue", sender: self);
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("LoginSuccessSegue", sender: self);
            });
        }
        
    }
    
    func login_failed(message: String?) -> Void
    {
        var msg: String = "Your login was incorrect.  Please try again.";
        if(message != nil)
        {
            msg = message!;
        }
        
        dispatch_sync(dispatch_get_main_queue(), {
            
            /* Do UI work here */
            var alert = SCLAlertView(parent: self.view);
            alert.showError("Oops!", subTitle: msg, closeButtonTitle: "OK", duration: NSTimeInterval(3));
            
        });
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //Track Screen
        self.screenName = "Login";
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var loginView = self.view as CLLoginView;
        loginView.delegate = self;
        
        
        var token = Token.loadValidToken();
        if(token != nil)
        {
            var alert = SCLAlertView(parent: self.view);
            alert.addButton("Do it!") {
                self.login_success(token!);
            }
            
            alert.addButton("No, thanks...") {
                Token.clearToken();
                self.navigationController?.popViewControllerAnimated(true);
            };
            var username = token!.getUsername();
            alert.showTitle("Login", subTitle: "Would you like to login as " + username + "?", duration: NSTimeInterval(10), completeText: nil, style: SCLAlertViewStyle.Info);
        }
    }
    
    
    
    override func supportedInterfaceOrientations() -> Int {
        
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender);
        
        if(segue.identifier == "LoginSuccessSegue")
        {
            
        }
    }

}
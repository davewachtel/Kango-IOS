//
//  CLLandingController.swift
//  Kango
//
//  Created by James Majidian on 11/15/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

protocol CLLoginViewDelegate {
    func authenticate(username: String, password: String, completion: @escaping () -> Void);
    func BackBTn();
    func ShowError(string : String,heading : String);
}

class CLLoginViewController : GAITrackedViewController, CLLoginViewDelegate
{
    var api = LoginApiController();
    
    func authenticate(username: String, password: String, completion: @escaping () -> Void) {
        
        let loginView = self.view as! CLLoginView;
        loginView.heightError.constant = 0.0
        loginView.btnCross.isHidden = true
        
        api.login(username: username as NSString
            , password: password as NSString
            , success: {
                (token: Token) -> () in
//
//                DispatchQueue.main.async(execute: {
//                    token.setPassword(password: password)
                    _ = token.saveToken()
//                })
                    self.login_success(token: token);
                    completion();
                
            },
            error: {
                (message: String?) -> () in
                    self.login_failed(message: message);
                    completion();
        });
    }
    
    
    static func authenticateAccount(username: String, password: String, completion: @escaping () -> Void) {
       
        let api = LoginApiController();
        
        api.login(username: username as NSString
            , password: password as NSString
            , success: {
                (token: Token) -> () in
                
//                DispatchQueue.main.async( execute:{
//                    token.setPassword(password: password)
                    _ = token.saveToken()

//                })

                completion();
                
        },
              error: {
                (message: String?) -> () in
                completion();
        });
    }
    
    func BackBTn()
    {
     _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func login_success(token: Token) -> Void
    {
        CLInstance.sharedInstance.authToken = token;
        
        if(Thread.isMainThread)
        {
             self.performSegue(withIdentifier: "LoginSuccessSegue", sender: self);
        }
        else
        {
            DispatchQueue.main.sync(execute: {
                self.performSegue(withIdentifier: "LoginSuccessSegue", sender: self);
            });
        }
        
    }
    
    func login_failed(message: String?) -> Void
    {
        print("=============>  login_failed")
        
        DispatchQueue.main.sync(execute: {
            let loginView = self.view as! CLLoginView;
            loginView.heightError.constant = 35.0
            loginView.btnCross.isHidden = false
            
            loginView.txtPassword.inputAccessoryView = nil;
            loginView.txtUsername.inputAccessoryView = nil;
            loginView.txtUsername.reloadInputViews()
            loginView.txtPassword.reloadInputViews()
            
        });
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let loginView = self.view as! CLLoginView;
        
        loginView.txtPassword.DrawLine()
        loginView.txtUsername.DrawLine()
        loginView.CustomAccessoryView(textField: loginView.txtPassword)
        loginView.CustomAccessoryView(textField: loginView.txtUsername)
        loginView.txtUsername.becomeFirstResponder()
        loginView.spinner.isHidden = true
    }
       
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let loginView = self.view as! CLLoginView;
        loginView.heightError.constant = 0.0
        loginView.btnCross.isHidden = true
        
        self.screenName = "Login";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let loginView = self.view as! CLLoginView;
        loginView.delegate = self;
        loginView.spinner.isHidden = true
        
        self.navigationController?.isNavigationBarHidden = true
        
    }

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepare(for: segue, sender: sender);
        
        if(segue.identifier == "LoginSuccessSegue")
        {
            
        }
    }
    
    
    func ShowError(string : String,heading : String) {
        let alertController = UIAlertController(title: heading, message: string, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
    }

}

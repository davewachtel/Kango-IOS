//
//  LoginController.swift
//  Kango
//
//  Created by James Majidian on 11/22/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

protocol LoginControllerProtocol
{
    func success(token: NSString);
    func failed(message: NSString);
}

class LoginController
{
    var delegate: LoginControllerProtocol;
    
    init(delegate: LoginControllerProtocol) {
        self.delegate = delegate
    }
    
    let request: CLRequestController = CLRequestController();
    
    func login(username: NSString, password: NSString)
    {
        let request: CLRequestController = CLRequestController();
        request.post(["grant_type" : "password", "username": username, "password" : password], url: "api/Login", method: "POST", postCompleted: { (succeeded: Bool, data: NSDictionary) -> () in
            
            if(succeeded)
            {
                var defaults =  NSUserDefaults.standardUserDefaults();
                defaults.setObject(data, forKey: "access_token");
                defaults.synchronize();
                
                self.delegate.success(data.objectForKey("access_token") as NSString!);
            }
            else
            {
                
                var msg = data.objectForKey("error_description") as NSString?;
                if(msg == nil)
                {
                    msg = "";
                }
                
                self.delegate.failed(msg!);
            }
        });
    }
    
    func hasValidToken() -> Bool
    {
        var defaults =  NSUserDefaults.standardUserDefaults();
        var data = defaults.objectForKey("access_token") as NSDictionary?;
        if(data != nil)
        {
            var token = Token(data: data!);
            return token.isExpired();
        }
        
        return false;
    }
}
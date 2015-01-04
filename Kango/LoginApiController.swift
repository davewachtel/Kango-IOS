//
//  LoginController.swift
//  Kango
//
//  Created by James Majidian on 11/22/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class LoginApiController
{
    func login(username: NSString, password: NSString, success:(token: Token) -> Void, error:(message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(["grant_type" : "password", "username": username, "password" : password], isJSON: false, url: HelperApiController.BaseUrl() + "oauth/token", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            if(succeeded)
            {
                var token = Token(data: data);
                success(token: token);
            }
            else
            {
                
                error(message: nil);
            }
        });
    }
}
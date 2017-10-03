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
    func login(username: NSString, password: NSString, success:@escaping (_ token: Token) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        
        
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "username": username, "password" : password,"device_token":app.deviceToekn as String as AnyObject], isJSON: false, url: HelperApiController.BaseUrl() + "oauth/token", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                let token = Token(data: data as! Dictionary<String, Any> );
                success(token);
            }
            else
            {
                print("=============> login_failed API")
                error(nil);
            }
        });
    }
    
    func CheckEmail(email: String, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "email": email as AnyObject], isJSON: false, url: HelperApiController.BaseUrl() + "api/Account/checkemail", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            print(succeeded)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                    
                }
                error(nil);
            }
        });
    }

    
    func Signup(username: NSString, Phonenumber: NSString, password: NSString, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "username": username, "password" : password, "PhoneNumber":Phonenumber], isJSON: false, url: HelperApiController.BaseUrl() + "api/Account/register", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                    
                }
                error(nil);
            }
        });
    }

    
    func GettingProfile(username: NSString, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        
        request.post(params: ["grant_type" : "password" as AnyObject, "Id": username ], isJSON: false, url: HelperApiController.BaseUrl() + "api/Account/profile", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                    
                }
                error(nil);
            }
        });
    }
    
    
    func UpdateProfile(username: NSString, Phonenumber: NSString, noti: Bool, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "Id": username,"Phonenumber": Phonenumber , "noti" : noti.description as AnyObject], isJSON: false, url: HelperApiController.BaseUrl() + "api/Account/updateprofile", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                }
                error(nil);
            }
        });
    }

    func ShowAllFriends(pagenumber: NSString, pagesize: NSString, UserId: NSString, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "UserId": UserId, "pagesize": pagesize,"pagenumber": pagenumber ], isJSON: false, url: HelperApiController.BaseUrl() + "api/Friends/getFriend", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                    
                }
                error(nil);
            }
        });
    }

    
    func AddFriend(Userto: NSString, Userfrom: NSString, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "Userto": Userto,"Userfrom": Userfrom], isJSON: false, url: HelperApiController.BaseUrl() + "api/Friends/addFriend", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                }
                error(nil);
            }
        });
    }
    
    func GetAllusers(pagenumber: NSString, pagesize: NSString, UserId: NSString, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "pagenumber": pagenumber,"pagesize": pagesize ,"UserId":UserId], isJSON: false, url: HelperApiController.BaseUrl() + "api/Friends/AllUsers", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                    
                }
                error(nil);
            }
        });
    }

    func RemoveFriend(Userto: NSString, Userfrom: NSString, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let request: HelperApiController = HelperApiController();
        request.post(params: ["grant_type" : "password" as AnyObject, "User_to": Userto,"User_from": Userfrom ], isJSON: false, url: HelperApiController.BaseUrl() + "api/Friends/deleteFriend", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                    
                }
                error(nil);
            }
        });
    }

    
    func checkFriend(User: NSString,UserList:[String], success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        
        var dataDict = Dictionary<String, AnyObject>()
        
        dataDict["grant_type"]  = "password" as AnyObject
        dataDict["Id"]          = User as AnyObject
        
        for index in 0..<UserList.count{
            let stringParam  = "PhoneNumber[" + String(index) + "]"
            dataDict[stringParam]          = UserList[index] as AnyObject?
        }
        
        print(dataDict)
        let request: HelperApiController = HelperApiController();
         request.post(params: dataDict, isJSON: false, url: HelperApiController.BaseUrl() + "api/Account/checkUsers", done: { (succeeded: Bool, data: NSDictionary) -> () in
            
            print(data)
            if(succeeded)
            {
                success(data);
            }
            else
            {
                
                if (data != nil)
                {
                    if (data["message"] != nil)
                    {
                        error(data["message"] as? String);
                    }
                    
                }
                error(nil);
            }
        });
    }

}

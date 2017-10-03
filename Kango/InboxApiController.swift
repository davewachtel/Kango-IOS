//
//  InboxApiController.swift
//  Kango
//
//  Created by James Majidian on 12/23/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation


class InboxApiController {
    
    /*
    var pageNum: Int = 1;
    var size:Int = 5;
    
    var totalCount: Int = 0;
    var hasPulled = false;
    var isInProgress = false;
    */
    
    var authToken: Token;
    
    init(token: Token) {
        self.authToken = token;
    }
    
    func getInbox(userId: String, success:@escaping (_ msgArray: [InboxMessage]) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let path = HelperApiController.BaseUrl() + "api/user/" + userId + "/inbox";
        
        let helper = HelperApiController();
        helper.get(params: nil, url: path, done: { (succeeded, data) -> () in
            if(succeeded)
            {
                let results: NSArray = data["data"] as! NSArray;
                let msgArr = InboxMessage.toMessage(allResults: results);
                success(msgArr);
                
                //success
            }
            else
            {
                error("message: The system is unable to retrieve your Inbox.");
            }
        });
    }
    
    func MarkMessage(userId: String,MessageID: String,  success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let path = HelperApiController.BaseUrl() + "api/user/" + userId + "/inbox";
        
        let helper = HelperApiController();
        helper.post(params: ["MessageId" : MessageID as AnyObject, "read": "1" as AnyObject], isJSON: false, url: path, done: { (succeeded: Bool, data: NSDictionary) -> () in
            
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
    
}

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
    
    func getInbox(userId: String, success:(msgArray: [InboxMessage]) -> Void, error:(message: String?) -> Void)
    {
        let path = HelperApiController.BaseUrl() + "api/user/" + userId + "/inbox";
        
        var helper = HelperApiController();
        helper.get(nil, url: path, { (succeeded, data) -> () in
            if(succeeded)
            {
                let results: NSArray = data["data"] as NSArray;
                let msgArr = InboxMessage.toMessage(results);
                success(msgArray: msgArr);
                
                //success
            }
            else
            {
                error(message: "message: The system is unable to retrieve your Inbox.");
            }
        });
    }
}
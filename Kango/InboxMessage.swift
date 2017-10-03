//
//  InboxMessage.swift
//  Kango
//
//  Created by James Majidian on 12/15/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class InboxMessage
{
    var assetId: Int;
    var fromUser: String;
    var phoneNumber: String;
    var msg: String;
    var timeAgo: String;
    var msgID: String;
    var isRead : Bool;
    
    init(assetId: Int, fromUser: String, phoneNumber: String, msg: String, timeAgo: String, isRead: Bool, MessageID: String)
    {
        self.assetId = assetId;
        self.fromUser = fromUser;
        self.phoneNumber = phoneNumber;
        self.msg = msg;
        self.timeAgo = timeAgo;
        self.isRead = isRead;
        self.msgID = MessageID;
    }
    
    
    class func toMessage(allResults: NSArray) -> [InboxMessage] {
        
        // Create an empty array of Albums to append to from this list
        var messages = [InboxMessage]()
        
        // Store the results in our table data array
        if allResults.count > 0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                
                let resultData = result as! NSDictionary
                
                let assetId = resultData["assetid"] as! Int;
                let fromUser = resultData["fromuser"] as! String;
                
                var phoneNumber = ""
                
                if let phone = resultData["phone"] as? String
                {
                    phoneNumber = phone
                }
                
                let message = "";
                let timeago = resultData["timeago"] as! String;
                let idMessage = Int((resultData["messageid"] as AnyObject) as! NSNumber)
                let messageID = String(idMessage);
                let isRead = resultData["isread"] as! Bool;

                let msg = InboxMessage(assetId: assetId, fromUser: fromUser, phoneNumber: phoneNumber, msg: message, timeAgo: timeago, isRead: isRead , MessageID : messageID)
                messages.append(msg)
            }
        }
        return messages;
    }
}

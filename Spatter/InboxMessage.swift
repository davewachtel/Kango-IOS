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
    var msg: String;
    var timeAgo: String;
    var isRead : Bool;
    
    init(assetId: Int, fromUser: String, msg: String, timeAgo: String, isRead: Bool)
    {
        self.assetId = assetId;
        self.fromUser = fromUser;
        self.msg = msg;
        self.timeAgo = timeAgo;
        self.isRead = isRead;
    }
    
    
    class func toMessage(allResults: NSArray) -> [InboxMessage] {
        
        // Create an empty array of Albums to append to from this list
        var messages = [InboxMessage]()
        
        // Store the results in our table data array
        if allResults.count > 0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                let assetId = result["assetid"] as Int;
                let fromUser = result["fromuser"] as String;
                let message = "";
                let timeago = result["timeago"] as String;
                let isRead = result["isread"] as Bool;
                
                var msg = InboxMessage(assetId: assetId, fromUser: fromUser, msg: message, timeAgo: timeago, isRead: isRead);
                messages.append(msg)
            }
        }
        return messages;
    }
}
//
//  ContactApiController.swift
//  Kango
//
//  Created by James Majidian on 12/25/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation


class ShareApiController
{
    var pageNum: Int = 1;
    var size:Int = 5;
    
    var totalCount: Int = 0;
    var hasPulled = false;
    var isInProgress = false;
    
    var authToken: Token;
    init(token: Token) {
        self.authToken = token;
    }
    
    func getContacts(success:(result: [Contact]) -> Void, error:(message: String?) -> Void)
    {
        var msg: String = "[{ \"id\": \"618e033c-b399-4ff6-9dd2-3728b5af924a\", \"firstName\": \"David\", \"lastName\": \"Wachtel\" }";
        msg += ", { \"id\": \"84a94f6f-5667-48fc-b3c5-a5803dd826e2\", \"firstName\": \"James\", \"lastName\": \"Majidian\" }";
        msg += ", { \"id\": \"d089edfd-563c-41ed-9dab-aa9057403c89\", \"firstName\": \"Bryan\", \"lastName\": \"McCauley\" }]";
        
        
        let data: NSData = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!;
        
        var err: NSError?;
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSArray;
        
        var contactArr = Contact.toContact(json!);
        contactArr.sort({ $0.lastName < $1.lastName });
        
        success(result: contactArr);
    }
    
    func shareAsset(assetId: Int, userIds: [String], success:() -> Void, error:(message: String?) -> Void)
    {
        let path = HelperApiController.BaseUrl() + "api/share";
        let helper = HelperApiController();
        
        var params: Dictionary<String, AnyObject> = ["AssetId" : assetId, "ToUserId" : userIds, "Message" : ""];
        helper.post(params, isJSON: true, url: path, done: { (succeeded, data) -> () in
            if(succeeded)
            {
                success();
            }
            else
            {
                error(message: "The system could not share.");
            }
        });
    }
}
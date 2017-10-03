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

    func getContacts(pagenumber: NSString, pagesize: NSString, UserId: NSString, success:@escaping (_ token: NSDictionary) -> Void, error:@escaping (_ message: String?) -> Void)
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
    
    func shareAsset(assetId: Int, userIds: [String], success:@escaping () -> Void, error:@escaping (_ message: String?) -> Void)
    {
        let path = HelperApiController.BaseUrl() + "api/share";
        let helper = HelperApiController();
        
        let params: Dictionary<String, AnyObject> = ["AssetId" : assetId as AnyObject, "ToUserId" : userIds as AnyObject, "Message" : "" as AnyObject];
        helper.post(params: params, isJSON: true, url: path, done: { (succeeded, data) -> () in
            if(succeeded)
            {
                success();
            }
            else
            {
                error("The system could not share.");
            }
        });
    }
}

//
//  Token.swift
//  Kango
//
//  Created by James Majidian on 11/23/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

/*
{
"access_token": "i9qSMCZl2zeM_wBdHQt4eXqaqRFa_uRpruDHzHiTMV5cGlLQDKBB4L8ddm_6kh8g92cMsboBy5nzZn2UeyYqTPOnkVyMzoAhhTCnVhIXqssn9lRtfvsMXXM07CYfb9OPd3StCAMsj5rlih5XIVaVrv4Lpt_xNAH-EozsiOi45_XtrcYFtzAHS7i6arP8V9aM52SDQC-5RqdKSJK_cn-pnkJnhMzmWIM9ocW5S_QZnCIApQZoyI5KzSrc8NrB3ALIuKCa7vzDXqslcfe85YLEczEhXexQhr2KUsF5OzKTAgYWG-HqPbckflzvDNNNb8pN9xru3ClJIAE00jdYWnvEhCZDML9h3VnQeLQCjVPScuUBsuPtmqhznCyrHUZchiMdNzWKyYkR_8MPRGjBfYdQfzYmZ0ZgNoPivt28Gz8N8xwE57ZOlsTjM4hKe4cDobia009PEvWB69Gw83tmFHC_CE2rTPh496lSgZv3cVonO6Fxnd2B",
"token_type": "bearer",
"expires_in": 1209599,
"userName": "jmajidian@gmail.com",
".issued": "Sun, 23 Nov 2014 08:01:57 GMT",
".expires": "Sun, 07 Dec 2014 08:01:57 GMT"
}
*/

class Token {
    
    var dicData: NSDictionary;
    
    init(data: NSDictionary)  {
        self.dicData = data;
    }
    
    func getToken() -> String
    {
            return self.dicData.objectForKey("access_token") as String;
    }
    func getUsername() -> String
    {
        return self.dicData.objectForKey("userName") as String;
    }
    func getType() -> String
    {
        return self.dicData.objectForKey("token_type") as String;
    }
    
    func isExpired() -> Bool
    {
        var strExpires = self.dicData.objectForKey(".expires") as String;
        var date: NSDate = parseDate(strExpires);
        var utc: NSDate = NSDate();
        if(date.compare(utc) == NSComparisonResult.OrderedDescending)
        {
            return false;
        }
        
        return true;
    }
    
    func parseDate(strDate: String) -> NSDate
    {
        var formatter = NSDateFormatter();
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0);
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss z";
        
        var date = formatter.dateFromString(strDate);
        return date!;
    }
    
    class func loadValidToken() -> Token?
    {
        var defaults =  NSUserDefaults.standardUserDefaults();
        var jsonStr = defaults.objectForKey("token") as NSDictionary;
        
        var token = Token(data: jsonStr);
        if(token.isExpired())
        {
            Token.clearToken();
            return nil;
        }
        
        return token;
    }
    
    class func clearToken() -> Void
    {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token");
    }
    
    func saveToken() -> Bool
    {
        var defaults =  NSUserDefaults.standardUserDefaults();
        defaults.setObject(self.dicData, forKey: "token");
        
        return defaults.synchronize();
    }
}
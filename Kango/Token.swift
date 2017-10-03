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
    
    var dicData: Dictionary<String, Any>;

    init(data: Dictionary<String, Any>)  {
        self.dicData = data;
    }
    
//    func setPassword(password: String)
//    {
//        return self.dicData["password"] = password//.object(forKey: "access_token") as! String;
//    }

    
    func getToken() -> String
    {
//            return self.dicData.object(forKey: "access_token") as! String;
        return self.dicData["access_token"] as! String
    }
    
    func getUserId() -> String
    {
          return self.dicData["userId"] as! String
//        return self.dicData.object(forKey: "userId") as! String;
    }
    
    func getUsername() -> String
    {
          return self.dicData["userName"] as! String
//        return self.dicData.object(forKey: "userName") as! String;
    }
    
    func getPassword() -> String?
    {
          return self.dicData["password"] as? String
//        return self.dicData.object(forKey: "password") as! String;
    }
    
    func getType() -> String
    {
          return self.dicData["token_type"] as! String
//        return self.dicData.object(forKey: "token_type") as! String;
    }
    
    func isExpired() -> Bool
    {
  
        let strExpires = self.dicData[".expires"] as! String
//self.dicData.object(forKey: ".expires") as! String;
        let date: NSDate = parseDate(strDate: strExpires);
        let utc: NSDate = NSDate();
        if(date.compare(utc as Date) == ComparisonResult.orderedDescending)
        {
            return false;
        }
        
        return true;
    }
    
    func parseDate(strDate: String) -> NSDate
    {
        let formatter = DateFormatter();
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!;
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss z";
        
        let date = formatter.date(from: strDate);
        return date! as NSDate;
    }
    
    class func loadValidToken() -> Token?
    {
        let defaults =  UserDefaults.standard;
        let obj: AnyObject? = defaults.object(forKey: "token") as AnyObject?;
        
        if(obj != nil)
        {
            let jsonStr = obj as! NSDictionary;
        
//              return self.dicData["userId"] as! String
            
            let token = Token(data: jsonStr as! Dictionary<String, Any> )// as! NSMutableDictionary);
            if(token.isExpired())
            {
                Token.clearToken();
                return nil;
            }
        
            return token;
        }
        
        return nil;
    }
    
    class func clearToken() -> Void
    {
        UserDefaults.standard.removeObject(forKey: "token");
    }
    
    func saveToken() -> Bool
    {
        let defaults =  UserDefaults.standard;
        defaults.set(self.dicData, forKey: "token");
        
        return defaults.synchronize();
    }
}

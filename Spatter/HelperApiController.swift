//
//  CLRequestController.swift
//  Kango
//
//  Created by James Majidian on 11/22/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class HelperApiController
{
    //let baseUrl: NSString = "http://cornicelabsservices.cloudapp.net/";
    class func BaseUrl() -> String {
        
        return "http://8f9f244be27e4e29b1e963b9c764ada4.cloudapp.net/";
    }
    
    func post(params : Dictionary<String, String>, isJSON: Bool, url : String, method: String, postCompleted : (succeeded: Bool, data: NSDictionary) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = method;
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var err: NSError?
        
        if(isJSON)
        {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err);
            request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        }
        else
        {
            let strParams = self.getParamsString(params);
            
            var requestBodyData = strParams.dataUsingEncoding(NSUTF8StringEncoding)
            request.HTTPBody = requestBodyData;
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type");
        }
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding);
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'");
                
                postCompleted(succeeded: false, data: NSDictionary());
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    
                    if(response.isKindOfClass(NSHTTPURLResponse))
                    {
                        let hResponse = response as NSHTTPURLResponse;
                        var statusCode = hResponse.statusCode;
                        if(statusCode >= 200 && statusCode < 300)
                        {
                            postCompleted(succeeded: true, data: parseJSON);
                        }
                        else
                        {
                            postCompleted(succeeded: false, data: NSDictionary());
                        }
                    }
                    else
                    {
                        
                        postCompleted(succeeded: false, data: NSDictionary());
                    }
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding);
                    println("Error could not parse JSON: \(jsonStr)");
                    
                    postCompleted(succeeded: false, data: NSDictionary());
                }
            }
        });
        
        task.resume()
    }
    
    func getParamsString(parameters: NSDictionary) -> String {
        var firstPass = true
        var result: String = "";
        
        for (key, value) in parameters {
            let encodedKey: NSString = key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let encodedValue: NSString = value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            result += firstPass ? "\(encodedKey)=\(encodedValue)" : "&\(encodedKey)=\(encodedValue)"
            firstPass = false;
        }
        
        return result
    }
    
}
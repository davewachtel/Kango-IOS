//
//  CLRequestController.swift
//  Kango
//
//  Created by James Majidian on 11/22/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class CLRequestController
{
    let baseUrl: NSString = "http://cornicelabsservices.cloudapp.net/";
    
    func post(params : Dictionary<String, String>, url : String, method: String, postCompleted : (succeeded: Bool, data: NSDictionary) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: baseUrl + url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = method;
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
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
                    
                    postCompleted(succeeded: true, data: parseJSON)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding);
                    println("Error could not parse JSON: \(jsonStr)");
                    
                    postCompleted(succeeded: false, data: NSDictionary());
                }
            }
        })
        
        task.resume()
    }
    
}
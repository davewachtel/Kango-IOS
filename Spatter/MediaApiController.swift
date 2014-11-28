//
//  ApiController.swift
//  Spatter
//
//  Created by James Majidian on 10/7/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

protocol MediaApiControllerProtocol {
    func didReceiveAPIResults(data: NSArray)
}

class MediaApiController {
    
    
    var pageNum: Int = 1;
    var size:Int = 5;
    
    var totalCount: Int = 0;
    var hasPulled = false;
    var isInProgress = false;
    
    var authToken: Token;
    
    var delegate: MediaApiControllerProtocol;
    
    init(delegate: MediaApiControllerProtocol, token: Token) {
        self.delegate = delegate;
        self.authToken = token;
    }
    
    func get(path: String) {
        if(self.isInProgress){
            return;
        }
        
        self.isInProgress = true;
        if(self.hasPulled)
        {
            if(self.pageNum * self.size < self.totalCount)
            {
                self.pageNum += 1;
            }
            else{
                return ;
            }
        }
        
        self.hasPulled = true;
        
        var helper = HelperApiController();
        
        let url = NSURL(string: path);
        let session = NSURLSession.sharedSession();
        var request = NSMutableURLRequest(URL: url!);
        
        request.HTTPMethod = "GET";
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        let strAuth = NSString(format: "%@ %@", self.authToken.getType(), self.authToken.getToken());
        request.addValue(strAuth,  forHTTPHeaderField: "Authorization");
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            self.isInProgress = false;
            
            var err: NSError?
            if(data.length > 0)
            {
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            self.totalCount = jsonResult["totalcount"] as Int;
            let results: NSArray = jsonResult["data"] as NSArray;
                
                self.delegate.didReceiveAPIResults(results) // THIS IS THE NEW LINE!!
            }
            
            
        })
        
        task.resume()
    }
    
    func getNextContent() {
        let urlPath = HelperApiController.BaseUrl() + "api/media?page=\(self.pageNum)&size=\(self.size)";
        get(urlPath)
    }
    
}
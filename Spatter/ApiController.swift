//
//  ApiController.swift
//  Spatter
//
//  Created by James Majidian on 10/7/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(data: NSArray)
}

class APIController {
    
    var pageNum: Int = 1;
    var size:Int = 5;
    
    var totalCount: Int = 0;
    var hasPulled = false;
    var isInProgress = false;
    
    var delegate: APIControllerProtocol;
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
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
        
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
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
        let urlPath = "http://cornicelabsservices.cloudapp.net/api/media?page=\(self.pageNum)&size=\(self.size)";
        get(urlPath)
    }
    
}
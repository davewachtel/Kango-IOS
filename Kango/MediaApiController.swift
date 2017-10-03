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
        print(token)
        
        self.delegate = delegate;
        self.authToken = token;
    }
    
    func markViewed(media: Media, wasLiked: Bool)
    {
        let path = HelperApiController.BaseUrl() + "api/view";

//        _ = HelperApiController();
        
        let url = NSURL(string: path);
        let session = URLSession.shared;
        let request = NSMutableURLRequest(url: url! as URL);

        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        let strAuth = NSString(format: "%@ %@", self.authToken.getType(), self.authToken.getToken());
        request.addValue(strAuth as String,  forHTTPHeaderField: "Authorization");
        
        let data = View(assetId: media.id, duration: 99, isLiked: wasLiked);
        
        
        var error : NSError?;
        
        let dic = ["assetId": data.assetId, "duration": data.duration, "isLiked": data.isLiked] as [String : Any];
        let json: NSData?
        do {
            json = try JSONSerialization.data(withJSONObject: dic, options: []) as NSData?
        } catch var error1 as NSError {
            error = error1
            json = nil
        }
        request.httpBody = json as Data?
        
        let task = session.dataTask(with: request as URLRequest);
        task.resume()
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
        
//        var helper = HelperApiController();
        
        let url = NSURL(string: path);
        let session = URLSession.shared;
        let request = NSMutableURLRequest(url: url! as URL);
        
        request.httpMethod = "GET";
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        
        print("URL:\(url)")
        
        print("session:\(URLSession.shared)")
        print("request:\(NSMutableURLRequest(url: url! as URL))")
        print("request:\( NSString(format: "%@ %@", self.authToken.getType(), self.authToken.getToken()))")
        
        
        
        let strAuth = NSString(format: "%@ %@", self.authToken.getType(), self.authToken.getToken());
        request.addValue(strAuth as String,  forHTTPHeaderField: "Authorization");
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            self.isInProgress = false;
            
//            var err: NSError?
            print(data)
            
            
            if (data != nil){
                if(data!.count > 0)
                {
                    
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        self.totalCount = jsonResult["totalcount"] as! Int;
                        let results: NSArray = jsonResult["data"]   as! NSArray;
                        
                        self.delegate.didReceiveAPIResults(data: results) // THIS IS THE NEW LINE!!
                    } catch {
                        
                    }
                    
                    //            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error:err) as NSDictionary
                    //            if(err != nil) {
                    //                // If there is an error parsing JSON, print it to the console
                    //                print("JSON Error \(err!.localizedDescription)")
                    //            }
                    
                }
            }else {
                print("Call === > get")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowError"), object: nil)
            }
            
        })
        
        task.resume()
    }
    
    class func getMedia(assetId: Int, success:@escaping (Media) -> Void, error: @escaping () -> Void)
    {
        let path = HelperApiController.BaseUrl() + "api/media/" + String(assetId);
        let helper = HelperApiController();
        
        helper.get(params: nil, url: path) { (succeeded, data) -> () in
            if(succeeded)
            {
                let mediaArray: [Media] = Media.mediaWithJSON(allResults: [data]);
                let media = mediaArray[0];
                
                success(media);
            }
            else
            {
                error();
            }
        }
    }
    
    class func downloadMedia(media: Media, success:@escaping (_ media: Media, _ img: UIImage) -> Void, error:@escaping () -> Void)
    {
        if(media.url.isEmpty)
        {
            error();
            return;
        }
        
        let nsUrl = NSURL(string: media.url);
        let request: NSURLRequest = NSURLRequest(url: nsUrl! as URL)
        
        
        
//        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue:OperationQueue.mainQueue, completionHandler: {(response : URLResponse?, data : NSData?, err : NSError?) in
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response, data, err) in
            if (err != nil)
            {
                error();
            }
            
            var img: UIImage?;
            
            switch(media.mediaTypeId)
            {
            case MediaType.Image.rawValue:
                print(data)
                if (data != nil ){
                    img = UIImage(data:data!);
                }
                break;
            case MediaType.Animation.rawValue:
                img = UIImage.animatedImage(withAnimatedGIFData: data);
                break;
            default:
                NSException(name: NSExceptionName(rawValue: "Not Supported"), reason: "This media type is not supported.", userInfo: nil).raise();
                break;
            }
            
            if(img != nil){
                success(media, img!);
            }
        }
    }

    func getNextContent() {
        let urlPath = HelperApiController.BaseUrl() + "api/media?page=\(self.pageNum)&size=\(self.size)";
        get(path: urlPath)
    }
    
}

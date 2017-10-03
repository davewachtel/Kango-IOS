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
        
//        return "http://cornicelabsservices.cloudapp.net/";
        
//        return "http://40.118.173.128/";
        return "http://13.88.184.209/";
        
        //return "http://8f9f244be27e4e29b1e963b9c764ada4.cloudapp.net/";
    }
    
    func processResponse(data: NSData, response: URLResponse, error: NSError?, done : (_ succeeded: Bool, _ data: NSDictionary) -> ())
    {
        if(error != nil)
        {
            return;
        }
        
        print("Response: \(response)")
        
        let stringData = String.init(data: data as Data, encoding: .utf8)
        let strData = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue);
        print("Body: \(strData)")
        print(data)
        
        var err: NSError?
        var json : NSDictionary? = nil;
        if(data.length != 0)
        {
            
            do {
                json = try JSONSerialization.jsonObject(with: data as Data, options: .mutableLeaves) as? NSDictionary
                print(json)
                
            }
            catch _ {
                // Error handling
            }
            
        }
        
        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
        if(err != nil) {
            print(err!.localizedDescription)
            let jsonStr = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
            print("Error could not parse JSON: '\(jsonStr)'");
            
            done(false, NSDictionary());
        }
        else {
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            //if let parseJSON = json {
            
            
            if(response is HTTPURLResponse)
            {
                let hResponse = response as! HTTPURLResponse;
                let statusCode = hResponse.statusCode;
                if(statusCode >= 200 && statusCode < 300)
                {
                    if(json == nil)
                    {
                        done(true, NSDictionary());
                    }
                    else
                    {
                        done(true, json!);
                    }
                }
                else
                {
                    if(json == nil)
                    {
                        done(false, NSDictionary());
                    }
                    else
                    {
                        done(false, json!);
                    }
                    
//                    done(false, NSDictionary());
                }
            }
            else
            {
                
                done(false, NSDictionary());
            }
            //}
            /*
             else {
             // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
             let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding);
             println("Error could not parse JSON: \(jsonStr)");
             
             done(succeeded: false, data: NSDictionary());
             }
             */
        }
    }
    
    func get(params : Dictionary<String, String>?, url : String, done : @escaping (_ succeeded: Bool, _ data: NSDictionary) -> ()) {
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        request.httpMethod = "GET";
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        if(CLInstance.sharedInstance.authToken != nil)
        {
            let strAuth = NSString(format: "%@ %@", CLInstance.sharedInstance.authToken!.getType(), CLInstance.sharedInstance.authToken!.getToken());
            request.addValue(strAuth as String,  forHTTPHeaderField: "Authorization");
        }
        else {
            guard let token = Token.loadValidToken() else {
                
                return
            }
            
            let strAuth = NSString(format: "%@ %@", token.getType(), token.getToken());
            request.addValue(strAuth as String,  forHTTPHeaderField: "Authorization");
        }
        
//        var err: NSError?
        
//        let strParams = self.getParamsString(parameters: params as NSDictionary?);
//        let urlWithParams = url + strParams;
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            self.processResponse(data: data! as NSData, response: response!, error: error as NSError?, done: done);
        });
        
        task.resume()
    }
    
    func post(params : Dictionary<String, AnyObject>, isJSON: Bool, url : String, done : @escaping (_ succeeded: Bool, _ data: NSDictionary) -> ()) {
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        
        let session = URLSession.shared
        request.timeoutInterval = 60.0
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if(CLInstance.sharedInstance.authToken != nil)
        {
            let strAuth = NSString(format: "%@ %@", CLInstance.sharedInstance.authToken!.getType(), CLInstance.sharedInstance.authToken!.getToken());
            request.addValue(strAuth as String,  forHTTPHeaderField: "Authorization");
        }
        
        var err: NSError?
        if(isJSON)
        {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            } catch var error as NSError {
                err = error
                request.httpBody = nil
            };
            request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        }
        else
        {
            let strParams = self.getParamsString(parameters: params as NSDictionary!);
            
            let requestBodyData = strParams.data(using: String.Encoding.utf8)
            request.httpBody = requestBodyData;
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type");
        }
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            print(data)
            print("response")
            print(response)
            print("Error")
            print(error)
            if(data != nil)
            {
                self.processResponse(data: data! as NSData, response: response!, error: error as NSError?, done: done);

            }else {
                done(false, NSDictionary());
//                self.processResponse(data: data! as NSData, response: response!, error: error as NSError?, done: done);

            }
        });
        
        task.resume()
    }
    
    func getParamsString(parameters: NSDictionary?) -> String {
        var firstPass = true
        var result: String = "";
        
        if(parameters != nil)
        {
            for (key, value) in parameters! {

                
                let keyvalue = key as AnyObject
                 let keyvalue2 = value as AnyObject
                
                
                if keyvalue2 is Array<NSString> {
                    print("is NSArray")
                    let encodedKey = keyvalue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    
                    for i in 0 ..< keyvalue2.count {
//                        let phonenumber = keyvalue2[i] as AnyObject
                         let phonenumber = keyvalue2.object(at: i) as AnyObject
                        let encodedValue = phonenumber.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                        result += firstPass ? "\(encodedKey!)=\(encodedValue!)" : "&\(encodedKey!)=\(encodedValue!)"
                    }

                }else {
                    let encodedKey = keyvalue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    let encodedValue = keyvalue2.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    
                    result += firstPass ? "\(encodedKey!)=\(encodedValue!)" : "&\(encodedKey!)=\(encodedValue!)"
                    
                }
             print(result)
                firstPass = false;
            }
        }
        
        return result
    }
    
}

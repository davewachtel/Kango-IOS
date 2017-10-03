//
//  Media.swift
//  Spatter
//
//  Created by James Majidian on 10/7/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

enum MediaType: Int {
    case Image = 1
    case Animation = 2
    case Video = 3
}

class Media {
    var title: String
    var url: String
    var id: Int
    var mediaTypeId: Int
    
    
    init(id: Int, title: String, url: String, mediaTypeId: Int)  {
        self.id = id;
        self.title = title;
        self.url = url;
        self.mediaTypeId = mediaTypeId;
    }
    
    class func mediaWithJSON(allResults: NSArray) -> [Media] {
        
        // Create an empty array of Albums to append to from this list
        var medias = [Media]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                let resultData = result as! NSDictionary
                
                let id = resultData["id"] as! Int;
                let title = resultData["title"] as! String;
                let url = resultData["url"] as! String;
                let mediaTypeId = resultData["mediatype"] as! Int;
                
                let newMedia = Media(id: id, title: title, url: url, mediaTypeId: mediaTypeId);
                medias.append(newMedia)
                
            }
        }
        return medias;
    }
    
}

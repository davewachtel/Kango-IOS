//
//  MediaImage.swift
//  Kango
//
//  Created by James Majidian on 11/30/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class MediaImage
{
    var media: Media?;
    var img : UIImage;
    
    init(media: Media?, img: UIImage)
    {
        self.media = media;
        self.img = img;
    }
}
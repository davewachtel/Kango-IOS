//
//  View.swift
//  Kango
//
//  Created by James Majidian on 11/30/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class View
{
    var assetId : Int;
    var duration: Int;
    var isLiked: Bool;
    
    init(assetId: Int, duration: Int, isLiked: Bool)
    {
        self.assetId = assetId;
        self.duration = duration;
        self.isLiked = isLiked;
    }
}
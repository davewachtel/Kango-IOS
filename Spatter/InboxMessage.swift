//
//  InboxMessage.swift
//  Kango
//
//  Created by James Majidian on 12/15/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class InboxMessage
{
    var media: Media;
    var isRead : Bool;
    
    init(media: Media, isRead: Bool)
    {
        self.media = media;
        self.isRead = isRead;
    }
    
}
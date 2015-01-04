//
//  CLInstance.swift
//  Kango
//
//  Created by James Majidian on 12/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class CLInstance {
    class var sharedInstance : CLInstance {
        struct Static {
            static let instance : CLInstance = CLInstance()
        }
        return Static.instance
    }
    
    var authToken: Token?;
}
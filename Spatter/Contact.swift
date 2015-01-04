//
//  Contact.swift
//  Kango
//
//  Created by James Majidian on 12/25/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation


class Contact
{
    var id: String;
    var firstName: String;
    var lastName: String;
    
    init(id: String, firstName: String, lastName: String)
    {
        self.id = id;
        self.firstName = firstName;
        self.lastName = lastName;
    }
    
    class func toContact(allResults: NSArray) -> [Contact] {
        
        var contacts = [Contact]()
        
        if allResults.count > 0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                let id = result["id"] as String;
                let firstName = result["firstName"] as String;
                let lastName = result["lastName"] as String;
                
                let c = Contact(id: id, firstName: firstName, lastName: lastName);
                contacts.append(c)
            }
        }
        
        return contacts;
    };
}
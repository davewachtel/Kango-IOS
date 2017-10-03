//
//  CommonClass.swift
//  Giveplicity
//
//  Created by Taimoor Ali on 27/05/2016.
//  Copyright © 2016 Waseem shah. All rights reserved.
//

import UIKit


class CommonClass: NSObject {

    
    func ShowAlert( _ stringMessage   : NSString ,  stringTitle   : NSString , parentVC : UIViewController)
    {
        let alertController = UIAlertController(title: stringTitle as String, message: stringMessage as String, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        parentVC.present(alertController, animated: true, completion: nil)
    }
    
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
    }
}

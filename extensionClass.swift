//
//  extensionClass.swift
//  Kango
//
//  Created by Taimoor Ali on 20/10/2016.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit



extension UITextField {
    func DrawLine()  {
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - borderWidth,width:self.frame.size.width, height:self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func RemoveLine()  {
        let border = CALayer()
        let borderWidth = CGFloat(0.0)
        border.borderColor = UIColor.clear.cgColor
        border.frame = CGRect(x:0, y:0,width:0, height:0)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}


//extension String {
//    
//    subscript (i: Int) -> Character {
//        return self[self.startIndex.advancedBy(i)]
//    }
//    
//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }
//    
//    subscript (r: Range<Int>) -> String {
//        let start = startIndex.advancedBy(r.lowerBound)
//        let end = start.advancedBy(r.upperBound - r.lowerBound)
//        return self[Range(start ..< end)]
//    }
//}


//
//  CLOverlayView.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation
import UIKit

enum CLOverlayViewMode: Int {
    case CLOverlayViewModeNone
    case CLOverlayViewModeLeft
    case CLOverlayViewModeRight
}

class CLOverlayView : UIView
{
    var imageView: UIImageView;
    var mode: CLOverlayViewMode;
    
    required init(coder aDecoder: NSCoder) {
        self.imageView = UIImageView(coder: aDecoder);
        self.mode = CLOverlayViewMode.CLOverlayViewModeNone;
        
        super.init(coder: aDecoder);
        
        self.addSubview(self.imageView);
    }
    
    func setMode(mode: CLOverlayViewMode)
    {
        if(self.mode != mode)
        {
            self.mode = mode;
            
            var imgSrc = "";
            if (mode == CLOverlayViewMode.CLOverlayViewModeLeft) {
                imgSrc = "cross_300x300";
            } else {
                imgSrc = "checkmark_300x300";
            }
            
            self.imageView.image = UIImage(named: imgSrc);
            self.imageView.contentMode = UIViewContentMode.ScaleAspectFit;
        }
    }
    
    override func layoutSubviews() {
        self.imageView.frame = self.bounds;
        //self.imageView.frame = CGRectMake(0, 0, 100, 100);
    }
}
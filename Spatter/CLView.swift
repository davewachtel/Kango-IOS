//
//  CLView.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation
import UIKit

class CLView: UIView
{
    var draggableView : CLDraggableView;
    
    required init(coder aDecoder: NSCoder) {
        self.draggableView = CLDraggableView(coder: aDecoder);
        
        super.init(coder: aDecoder);
    }
    
    override init(frame: CGRect)
    {
        self.draggableView = CLDraggableView(frame: frame);
        
        super.init(frame: frame);
        
        self.backgroundColor = UIColor.whiteColor();
        self.addSubview(self.draggableView);
    }
}
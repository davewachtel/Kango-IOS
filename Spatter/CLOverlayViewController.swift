//
//  OverlayViewController.swift
//  Spatter
//
//  Created by James Majidian on 10/12/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

enum CLOverlayViewMode: Int {
    case CLOverlayViewModeNone
    case CLOverlayViewModeLeft
    case CLOverlayViewModeRight
}

class CLOverlayViewController: UIViewController
{
    var imageView: CLView;
    var mode: CLOverlayViewMode;

    
}
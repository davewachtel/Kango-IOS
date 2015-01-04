//
//  CLDraggableView.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation
import UIKit

class CLDraggableView: UIView
{
    var panGestureRecognizer : UIPanGestureRecognizer;
    var originalPoint: CGPoint;
    var overlayView: CLOverlayView;
    var mediaImage: MediaImage?;
    var shareButton: UIButton;
    
    var imageView: UIImageView;
    
    
    var delegate: CLDraggableViewProtocol?;
    
    
    required init(coder aDecoder: NSCoder) {
        
        self.panGestureRecognizer = UIPanGestureRecognizer();
        self.originalPoint = CGPoint();
        self.overlayView = CLOverlayView(coder: aDecoder);
        self.imageView = UIImageView();
        self.shareButton = UIButton();
        
        super.init(coder: aDecoder);
        self.initialize();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        self.overlayView.frame = self.bounds;
        self.imageView.frame = self.bounds;
        
        self.shareButton.frame.origin = self.getShareOrigin();
    }
    
    func getShareOrigin() -> CGPoint
    {
        let x = self.bounds.width  - 70 - 10;
        let y = self.bounds.height - 30 - 10;
        
        return CGPoint(x: x, y: y);
    }
    
    func initialize()
    {
        self.panGestureRecognizer.addTarget(self, action: "dragged:");
        self.addGestureRecognizer(self.panGestureRecognizer);
        
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.imageView.clipsToBounds = true;
        self.addSubview(self.imageView);
        
        self.layer.cornerRadius = 8;
        self.layer.shadowOffset = CGSizeMake(7, 7);
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        self.overlayView.alpha = 0;
        self.addSubview(self.overlayView);
        
        
        self.shareButton.frame = CGRect(origin: self.getShareOrigin(), size: CGSize(width: 70, height: 30));
        self.shareButton.backgroundColor = UIColor.greenColor()
        self.shareButton.setTitle("Share", forState: UIControlState.Normal)
        self.shareButton.addTarget(self, action: "shareAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.shareButton);
    }
    
    func shareAction(sender:UIButton!)
    {
        self.delegate?.share();
    }
    
    func setMedia(media: MediaImage)
    {
        self.shareButton.hidden = false;
        self.mediaImage = media;
        self.imageView.image = media.img;
    }

    func dragged(rec: UIGestureRecognizer)
    {
        
        var xDistance = self.panGestureRecognizer.translationInView(self).x;
        var yDistance = self.panGestureRecognizer.translationInView(self).y;
        
        switch(self.panGestureRecognizer.state)
        {
        case UIGestureRecognizerState.Began:
            self.originalPoint = self.center;
            break;
        case UIGestureRecognizerState.Changed:
            
            var rotationStrength = min(xDistance / 320, 1);
            var rotationAngle = CGFloat(2*M_PI/16) * CGFloat(rotationStrength);
            
            var scaleStrength = 1 - fabsf(Float(rotationStrength)) / 4;
            var scale = max(scaleStrength, 0.93);
            
            var transform = CGAffineTransformMakeRotation(rotationAngle);
            var scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale));
            
            self.transform = scaleTransform;
            self.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
            
            self.updateOverlay(xDistance);
            break;
            
        case UIGestureRecognizerState.Ended:
            self.resetViewPositionAndTransformations(xDistance);
            break;
        case UIGestureRecognizerState.Possible:
            break;
        case UIGestureRecognizerState.Cancelled:
            break;
        case UIGestureRecognizerState.Failed:
            break;
        }
        
    }
    
    func updateOverlay(distance: CGFloat)
    {
        if (distance > 0) {
            self.overlayView.setMode(CLOverlayViewMode.CLOverlayViewModeRight);
        } else if (distance <= 0) {
            self.overlayView.setMode(CLOverlayViewMode.CLOverlayViewModeLeft);
        }
        
        var overlayStrength = self.calculateDragStrength(distance);
        self.overlayView.alpha = CGFloat(overlayStrength);
    }
    
    func removeLastView(wasLiked: Bool)
    {
        self.shareButton.hidden = true;
        self.delegate?.removeCurrentView(wasLiked);
        
        self.setNeedsDisplay();
    }
    
    func resetViewPositionAndTransformations(distance: CGFloat)
    {
        UIView.animateWithDuration(0.2, animations: {
            self.center = self.originalPoint;
            self.transform = CGAffineTransformMakeRotation(0);
            self.overlayView.alpha = 0;
        });
        
        var overlayStrength = self.calculateDragStrength(distance);
        if(overlayStrength >= 0.4)
        {
            var wasLiked: Bool;
            wasLiked = (distance > 0);
            
            self.removeLastView(wasLiked);
        }
    }
    
    func calculateDragStrength(distance: CGFloat) -> Float
    {
        return min(fabsf(Float(distance)) / 100, 0.4);
    }
    
    deinit {
        self.removeGestureRecognizer(self.panGestureRecognizer);
    }
}
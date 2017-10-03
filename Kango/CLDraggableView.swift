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
    
    var sizeHeight : CGFloat =  80.0
    
    var delegate: CLDraggableViewProtocol?;
    
    
    required init?(coder aDecoder: NSCoder) {
        
        self.panGestureRecognizer = UIPanGestureRecognizer();
        self.originalPoint = CGPoint();
        self.overlayView = CLOverlayView(coder: aDecoder)!;
        self.imageView = UIImageView();
        self.shareButton = UIButton();
        
        super.init(coder: aDecoder);
        self.initialize();
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        self.overlayView.frame = self.bounds;
//        self.imageView.frame = self.bounds;
        
        self.imageView.frame = CGRect.init(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width, height: self.bounds.size.height - self.sizeHeight);
        
        self.shareButton.frame.origin = self.getShareOrigin();
        self.shareButton.frame.size = CGSize(width: self.bounds.width, height: self.sizeHeight)
    }
    
//    func getShareOrigin() -> CGPoint
//    {
//        let y = self.bounds.height - self.sizeHeight ;
//        let x = self.bounds.origin.x
//        return CGPoint(x: x, y: y);
//    }
    
    func getShareOrigin() -> CGPoint
    {
        let y = self.bounds.height - 5.0 ;
        let x = self.bounds.origin.x
        print(y)
        print(self.bounds.height)
        return CGPoint(x: x, y: y);
    }

    
    func initialize()
    {
        
//        NotificationCenter.default.addObserver(self, selector: #selector(CLDraggableView.RemoveShareButton), name: NSNotification.Name(rawValue: "RemoveShareButton"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(CLDraggableView.AddShare), name: NSNotification.Name(rawValue: "AddShareButton"), object: nil)

        
        self.panGestureRecognizer.addTarget(self, action: #selector(CLDraggableView.dragged));
        self.addGestureRecognizer(self.panGestureRecognizer);
        
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit;
        self.imageView.clipsToBounds = true;
        self.addSubview(self.imageView);
        
        self.layer.cornerRadius = 8;
        self.layer.shadowOffset = CGSize(width:7,height: 7);
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        self.overlayView.alpha = 0;
        self.addSubview(self.overlayView);
        
        
        self.shareButton.frame = CGRect(origin: self.getShareOrigin(), size: CGSize(width: self.bounds.width, height: 30));

        self.shareButton.backgroundColor = UIColor.init(colorLiteralRed: (63/255), green: (177/255), blue: (255/255), alpha: 1.0)
        self.shareButton.setTitle("Share", for: UIControlState.normal)
        self.shareButton.setImage(UIImage.init(named: "ShareBtn"), for: UIControlState.normal)
        self.shareButton.titleLabel!.font =  UIFont.systemFont(ofSize: 25.0)
        self.shareButton.addTarget(self, action: #selector(CLDraggableView.shareAction), for: UIControlEvents.touchUpInside)
        
      
        
//        self.addSubview(self.shareButton);
    }
    
    
    func AddShare(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        if(shareButton.superview == nil){
            appdelegate.window?.addSubview(self.shareButton)
        }
        
        if(shareButton.superview == nil){
            self.shareButton.removeFromSuperview()
        }
    }
    
    
    func RemoveShareButton(){
        
       // if(shareButton.superview != nil){
            
            self.shareButton.removeFromSuperview()
        //}
    }
    
    func shareAction(sender:UIButton!)
    {
        self.delegate?.share();
    }
    
    func setMedia(media: MediaImage)
    {
        self.shareButton.isHidden = false;
        self.mediaImage = media;
        self.imageView.image = media.img;
//        self.AddShare()
    }

    func dragged(rec: UIGestureRecognizer)
    {
        let xDistance = self.panGestureRecognizer.translation(in: self).x;
        let yDistance = self.panGestureRecognizer.translation(in: self).y;
        
        switch(self.panGestureRecognizer.state)
        {
        case UIGestureRecognizerState.began:
            self.originalPoint = self.center;
            break;
        case UIGestureRecognizerState.changed:
            
            let rotationStrength = min(xDistance / 320, 1);
            let rotationAngle = CGFloat(2*M_PI/16) * CGFloat(rotationStrength);
            
            let scaleStrength = 1 - fabsf(Float(rotationStrength)) / 4;
            let scale = max(scaleStrength, 0.93);
            
            let transform = CGAffineTransform(rotationAngle: rotationAngle);
            let scaleTransform = transform.scaledBy(x: CGFloat(scale), y: CGFloat(scale));
            
            self.transform = scaleTransform;
            self.center = CGPoint(x:self.originalPoint.x + xDistance, y:self.originalPoint.y + yDistance);
            
            self.updateOverlay(distance: xDistance);
            break;
            
        case UIGestureRecognizerState.ended:
            self.resetViewPositionAndTransformations(distance: xDistance);
            break;
        case UIGestureRecognizerState.possible:
            break;
        case UIGestureRecognizerState.cancelled:
            break;
        case UIGestureRecognizerState.failed:
            break;
        }
        
    }
    
    func updateOverlay(distance: CGFloat)
    {
        if (distance > 0) {
            self.overlayView.setMode(mode: CLOverlayViewMode.CLOverlayViewModeRight);
        } else if (distance <= 0) {
            self.overlayView.setMode(mode: CLOverlayViewMode.CLOverlayViewModeLeft);
        }
        
        let overlayStrength = self.calculateDragStrength(distance: distance);
        self.overlayView.alpha = CGFloat(overlayStrength);
    }
    
    func removeLastView(wasLiked: Bool)
    {
        self.shareButton.isHidden = true;
        self.delegate?.removeCurrentView(wasLiked: wasLiked);
        
        self.setNeedsDisplay();
    }
    
    func resetViewPositionAndTransformations(distance: CGFloat)
    {
        UIView.animate(withDuration: 0.2, animations: {
            self.center = self.originalPoint;
            self.transform = CGAffineTransform(rotationAngle: 0);
            self.overlayView.alpha = 0;
        });
        
        let overlayStrength = self.calculateDragStrength(distance: distance);
        if(overlayStrength >= 0.4)
        {
            var wasLiked: Bool;
            wasLiked = (distance > 0);
            
            self.removeLastView(wasLiked: wasLiked);
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

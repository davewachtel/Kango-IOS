//
//  CLDraggableViewController.swift
//  Kango
//
//  Created by James Majidian on 12/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation


protocol CLDraggableViewProtocol {
    func removeCurrentView(wasLiked: Bool);
    func share();
}

class CLDraggableViewController : GAITrackedViewController, CLDraggableViewProtocol
{
    var draggableView: CLDraggableView;
    var activityView: UIActivityIndicatorView;
    
    var notFound:UIImage;
    
    
    required init(coder aDecoder: NSCoder) {
        
        self.draggableView = CLDraggableView(coder: aDecoder);
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge);
        self.notFound = UIImage(named: "404.jpg")!;
        
        super.init(coder: aDecoder);
        
        var vBounds = UIScreen.mainScreen().bounds;
        self.draggableView.bounds = vBounds;
        self.draggableView.frame = vBounds;
        
        self.draggableView.delegate = self;
    }
    
    //Start
    override func loadView() {
        super.loadView();
        
        self.view.backgroundColor = UIColor.blackColor();
        
        self.view = self.draggableView;
        //self.view.addSubview(self.draggableView);
        
        self.activityView.bounds = self.view.frame;
        self.activityView.center = self.view.center;
        self.activityView.startAnimating();
        self.view.addSubview(activityView);
    }
    
    func share()
    {
        self.performSegueWithIdentifier("Share", sender: self);
    }
    
    func removeCurrentView(wasLiked: Bool)
    {
        onRemove(wasLiked);
    }
    
    func onRemove(wasLiked: Bool)
    {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "Share")
        {
            
            var shareVC = segue.destinationViewController as CLShareViewController;
            if(self.draggableView.mediaImage != nil)
            {
                if(self.draggableView.mediaImage!.media != nil)
                {
                    shareVC.title = "Share";
                    shareVC.assetId = self.draggableView.mediaImage!.media!.id;
                }
            }

        }
    }
    
    func setMedia(media: MediaImage?)
    {
        if(media?.media == nil)
        {
            self.draggableView.setMedia(MediaImage(media: nil, img: self.notFound));
        }
        else
        {
            self.draggableView.setMedia(media!);
        }
        
        if(self.activityView.isAnimating())
        {
            self.activityView.stopAnimating();
        }
    }
}
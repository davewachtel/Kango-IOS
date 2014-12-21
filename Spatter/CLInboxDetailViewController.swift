//
//  CLInboxDetailView.swift
//  Kango
//
//  Created by James Majidian on 12/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation


class CLInboxDetailViewController : CLDraggableViewController
{
    var media: Media?;
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.screenName = "Inbox Detail Screen";
    }
    
    override func onRemove(wasLiked: Bool) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if(media != nil)
        {
            self.downloadMedia(media!);
        }
    }
    
    func downloadMedia(media: Media)
    {
        MediaApiController.downloadMedia(media, success: downloadMedia_success, error: downloadMedia_error);
    }
    
    func downloadMedia_success(media: Media, img: UIImage)
    {
        self.setMedia(MediaImage(media: media, img: img));
    }
    
    func downloadMedia_error()
    {
        self.setMedia(nil);
    }
}
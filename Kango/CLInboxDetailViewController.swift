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
    var assetId: Int?;
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.screenName = "Inbox Detail Screen";
    }
    
    override func onRemove(wasLiked: Bool) {
        self.navigationController?.popViewControllerAnimated(true);
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        
        if(assetId != nil)
        {
            MediaApiController.getMedia(self.assetId!, success: { (media: Media) -> Void in
                
                self.downloadMedia(media);
                
            }, error: { () -> Void in
                
            });
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
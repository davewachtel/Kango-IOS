//
//  ViewController.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import UIKit

class CLPlaygroundViewController: CLDraggableViewController, MediaApiControllerProtocol {
    
    var serial_queue: dispatch_queue_t;

    lazy var api : MediaApiController = MediaApiController(delegate: self, token: CLInstance.sharedInstance.authToken!);
    
    var swipeImages: Array<MediaImage> = [];
    
    
    required init(coder aDecoder: NSCoder) {
        
        self.serial_queue =  dispatch_queue_create("serial queue", nil);
        
        super.init(coder: aDecoder);
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //Track Screen
        self.screenName = "Playground Screen";
        
        self.title = "Kango";
    }
    
    //Complete
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.Bordered, target: self, action: "menu_lock");
        item.title = "Menu";
        
        self.navigationItem.rightBarButtonItem = item;
        self.navigationController?.navigationItem.rightBarButtonItem = item;
        
        
        if (self.swipeImages.count == 0) {
            api.getNextContent();
        }
    }
    
    func menu_lock()
    {
        
        if(self.tabBarController != nil)
        {
            (self.tabBarController as CLTabBarController).sidebar.showInViewController(self, animated: true)
        }
        
    }
    
    func downloadMedia(media: Media)
    {
        MediaApiController.downloadMedia(media, success: downloadMedia_success, error: downloadMedia_error);
    }
    
    func downloadMedia_success(media: Media, img: UIImage)
    {
        self.addMedia(MediaImage(media: media, img: img));
    }
    
    func downloadMedia_error()
    {
        
    }
    
    func addMedia(media: MediaImage)
    {
        //dispatch_sync(serial_queue)
        //{
            var arrCount = self.swipeImages.count;
            var isEmpty = (arrCount == 0);
            self.swipeImages.append(media);
            
            if(isEmpty){
                self.setNextImageView();
            }
        
        //}
    }
    
    func setNextImageView()
    {
        //dispatch_sync(serial_queue)
          //  {
        var arrCount = self.swipeImages.count;
        if(arrCount == 0)
        {
            self.setMedia(nil);
        }
        else
        {
            self.setMedia(self.swipeImages[0]);
        }
       // }
    }
    
    override func onRemove(wasLiked: Bool) {
        
        dispatch_sync(serial_queue)
            {
                if(self.swipeImages.count > 0){
                    let mediaImg = self.swipeImages.removeAtIndex(0);
                    if(mediaImg.media != nil){
                        self.api.markViewed(mediaImg.media!, wasLiked: wasLiked);
                    }
                }
        }
        
        self.setNextImageView();
        if(self.swipeImages.count <= 3)
        {
            api.getNextContent();
        }
    }
    
    // MARK: APIControllerProtocol
    func didReceiveAPIResults(data: NSArray) {
        
        var arrMedia = Media.mediaWithJSON(data);
        
        for(var i = 0; i < arrMedia.count; i++)
        {
            self.downloadMedia(arrMedia[i]);
        }
    }
}


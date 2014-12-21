//
//  ViewController.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import UIKit

protocol CLDraggableViewProtocol
{
    //func removeView
}

protocol CLPlaygroundViewProtocol {
    func removeCurrentView(wasLiked: Bool)
}

class CLPlaygroundViewController: GAITrackedViewController, MediaApiControllerProtocol, CLPlaygroundViewProtocol {
    
    var serial_queue: dispatch_queue_t;

    lazy var api : MediaApiController = MediaApiController(delegate: self, token: CLInstance.sharedInstance.authToken!);
    
    var draggableView: CLDraggableView;
    var activityView: UIActivityIndicatorView;
    
    var swipeImages: Array<MediaImage> = [];
    
    var notFound:UIImage;
    
    required init(coder aDecoder: NSCoder) {
        
        self.draggableView = CLDraggableView(coder: aDecoder);
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge);
        self.serial_queue =  dispatch_queue_create("serial queue", nil);
        self.notFound = UIImage(named: "404.jpg")!;
        
        super.init(coder: aDecoder);
        
        var vBounds = UIScreen.mainScreen().bounds;
        
        //self.view.bounds = vBounds;
        //self.view.frame = vBounds;
        
        
        self.draggableView.bounds = vBounds;
        self.draggableView.frame = vBounds;
        
        self.draggableView.delegate = self;
    }
    
    //Start
    override func loadView() {
        super.loadView();
        
        self.view.backgroundColor = UIColor.blackColor();
        
        
        //self.draggableView.setFrames();
        self.view.addSubview(self.draggableView);
        //self.view = self.draggableView;
        
        self.activityView.bounds = self.view.frame;
        self.activityView.center = self.view.center;
        self.activityView.startAnimating();
        self.view.addSubview(activityView);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //Track Screen
        self.screenName = "Playground Screen";
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
        if(!media.url.isEmpty)
        {
        let url = NSURL(string: media.url);
        var request: NSURLRequest = NSURLRequest(URL:url!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler: {(response : NSURLResponse!, data : NSData!, error : NSError!) in
            
            if (error != nil)
            {
                return;
            }
            
            var img:UIImage?;
            
            switch(media.mediaTypeId)
                {
            case MediaType.Image.rawValue:
                img = UIImage(data:data);
                break;
            case MediaType.Animation.rawValue:
                img = UIImage.animatedImageWithAnimatedGIFData(data);
                
                break;
            default:
                NSException(name: "Not Supported", reason: "This media type is not supported.", userInfo: nil).raise();
                break;
            }
            
            if(img != nil){
                self.addMedia(MediaImage(media: media, img: img!));
            }
            });
        }
        
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
            self.draggableView.setMedia(MediaImage(media: nil, img: self.notFound));
        }
        else
        {
            self.draggableView.setMedia(self.swipeImages[0]);
            if(self.activityView.isAnimating())
            {
                self.activityView.stopAnimating();
            }
        }
       // }
    }
    
    func removeCurrentView(wasLiked: Bool)
    {
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


//
//  ViewController.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import UIKit


protocol DraggableViewProtocol {
    func removeCurrentView()
}

class ViewController: GAITrackedViewController, APIControllerProtocol, DraggableViewProtocol {
    
    var serial_queue: dispatch_queue_t;

    lazy var api : APIController = APIController(delegate: self)
    
    var draggableView: CLDraggableView;
    var activityView: UIActivityIndicatorView;
    
    var swipeImages: Array<UIImage> = [];
    
    var notFound:UIImage;
    
    required init(coder aDecoder: NSCoder) {
        
        self.draggableView = CLDraggableView(coder: aDecoder);
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge);
        self.serial_queue =  dispatch_queue_create("serial queue", nil);
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
        
        //self.draggableView.setFrames();
        self.view = self.draggableView;
    
        
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
        
        if (self.swipeImages.count == 0) {
            api.getNextContent();
        }
    }
    
    func downloadMedia(media: Media)
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
                self.addImage(img!);
            }
        });
        
    }
    
    func addImage(img: UIImage)
    {
        //dispatch_sync(serial_queue)
        //{
            var arrCount = self.swipeImages.count;
            var isEmpty = (arrCount == 0);
            self.swipeImages.append(img);
            
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
            self.draggableView.setImage(self.notFound);
        }
        else
        {
            self.draggableView.setImage(self.swipeImages[0]);
            if(self.activityView.isAnimating())
            {
                self.activityView.stopAnimating();
            }
        }
       // }
    }
    
    func removeCurrentView()
    {
        dispatch_sync(serial_queue)
        {
            if(self.swipeImages.count > 0){
                self.swipeImages.removeAtIndex(0);
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


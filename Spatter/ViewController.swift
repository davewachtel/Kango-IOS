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

class ViewController: UIViewController, APIControllerProtocol, DraggableViewProtocol {
    
    lazy var api : APIController = APIController(delegate: self)
    
    var draggableView: CLDraggableView;
    var activityView: UIActivityIndicatorView;
    
    var swipeImages: Array<UIImage> = [];
    
    var notFound:UIImage = UIImage(contentsOfFile: "404");
    
    required init(coder aDecoder: NSCoder) {
        
        self.draggableView = CLDraggableView(coder: aDecoder);
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge);
        
        super.init(coder: aDecoder);
        
        var vBounds = UIScreen.mainScreen().bounds;
        
        self.draggableView.bounds = vBounds;
        self.draggableView.frame = vBounds;
        
        self.draggableView.delegate = self;
    }
    
    //Start
    override func loadView() {
        super.loadView();
        
        self.draggableView.setFrames();
        self.view = self.draggableView;
    
        
        self.activityView.bounds = self.view.frame;
        self.activityView.center = self.view.center;
        self.activityView.startAnimating();
        self.view.addSubview(activityView);
    }
    
    //Complete
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if (self.swipeImages.count == 0) {
            api.getNextContent();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadMedia(media: Media)
    {
        let url = NSURL.URLWithString(media.url);
        var request: NSURLRequest = NSURLRequest(URL:url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler: {(response : NSURLResponse!, data : NSData!, error : NSError!) in
            
            if (error != nil)
            {
                return;
            }
            
            
            var img:UIImage = UIImage();
            
            switch(media.mediaTypeId)
                {
            case MediaType.Image.toRaw():
                img = UIImage(data:data);
                break;
            case MediaType.Animation.toRaw():
                img = UIImage.animatedImageWithAnimatedGIFData(data);
                
                break;
            default:
                NSException(name: "Not Supported", reason: "This media type is not supported.", userInfo: nil).raise();
                break;
            }
            
            var isEmpty = (self.swipeImages.count == 0);
            self.swipeImages.append(img);
            
            if(isEmpty){
                self.draggableView.setImage(img);
                self.activityView.stopAnimating();
            }
        });
        
    }
    
    func removeCurrentView()
    {
        self.draggableView.setImage(self.swipeImages[1]);
        self.swipeImages.removeAtIndex(0);
        
        if(self.swipeImages.count <= (self.api.size / 2))
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


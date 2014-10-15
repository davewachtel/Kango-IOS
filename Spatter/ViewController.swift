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
        
        self.draggableView.delegate = self;
    }
    
    //Start
    override func loadView() {
        super.loadView();
        
        self.view = self.draggableView;
        
        var centerY = self.view.bounds.size.height / 2;
        var centerX = self.view.bounds.size.width / 2;
        
        self.activityView.bounds = self.view.bounds;
        
        self.activityView.center = CGPoint(x: centerX, y: centerY);
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
    
    //func createUIView(media: Media) -> UIImageView
    func createUIView(media: Media) -> UIImage
    {
        let url = NSURL.URLWithString(media.url);
        var err: NSError?
        var imageData :NSData = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err);
        
        if(imageData.length == 0)
        {
            return self.notFound;
        }
        
        var img:UIImage = UIImage();
        
        switch(media.mediaTypeId)
        {
            case MediaType.Image.toRaw():
                img = UIImage(data:imageData);
                
                break;
            case MediaType.Animation.toRaw():
                img = UIImage.animatedImageWithAnimatedGIFData(imageData);
                
                break;
        default:
                NSException(name: "Not Supported", reason: "This media type is not supported.", userInfo: nil).raise();
                break;
        }
        
        //return imgView;
        return img;
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
        dispatch_async(dispatch_get_main_queue(), {
            var arrMedia = Media.mediaWithJSON(data);
            
            var isEmpty = (self.swipeImages.count == 0);
            
            for(var i = 0; i < arrMedia.count; i++)
            {
                var v = self.createUIView(arrMedia[i]);
                self.swipeImages.append(v);
            }
            
            if(isEmpty && self.swipeImages.count > 0)
            {
                self.activityView.stopAnimating();
                self.draggableView.setImage(self.swipeImages[0]);
            }
            

            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

}


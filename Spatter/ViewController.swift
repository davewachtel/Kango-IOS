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
    var swipeImages: Array<UIImage> = [];
    
    required init(coder aDecoder: NSCoder) {
        
        self.draggableView = CLDraggableView(coder: aDecoder);
        super.init(coder: aDecoder);
        
        self.draggableView.delegate = self;
    }
    
    init(frame: CGRect) {
        
        self.draggableView = CLDraggableView(frame: frame);
        super.init();
        
        
        self.draggableView.delegate = self;
        self.view = self.draggableView;
    }
    
    override func loadView() {
        self.view = self.draggableView;
    }
    
    override func viewDidLoad() {
        var width = UIScreen.mainScreen().bounds.width;
        var height = UIScreen.mainScreen().bounds.height;
        
        self.draggableView.imageView.frame = CGRect(x: 0, y: 0, width: width, height: height);
        
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
        var imageData :NSData = NSData.dataWithContentsOfURL(url,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
        
        //var imgView:UIImageView = UIImageView();
        var img:UIImage = UIImage();
        
        switch(media.mediaTypeId)
        {
            case MediaType.Image.toRaw():
                
                //imgView = UIImageView(image: UIImage(data:imageData));
                img = UIImage(data:imageData);
                
                break;
            case MediaType.Animation.toRaw():
                
                var gifImg = UIImage.animatedImageWithAnimatedGIFData(imageData);
                //imgView = UIImageView(image: gifImg);
                img = gifImg;
                
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
        
        //var swpImg = self.swipeImages.removeAtIndex(self.swipeImages.count - 1);
        //swpImg.removeFromSuperview();
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
                //self.draggableView.setImage(self.swipeImages[0]);
                self.draggableView.setImage(self.swipeImages[0]);
            }
            

            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

}


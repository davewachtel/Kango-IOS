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
    
    
    required init?(coder aDecoder: NSCoder) {
        
        self.draggableView = CLDraggableView(coder: aDecoder)!;
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge);
        self.notFound = UIImage(named: "404.png")!;
        
        super.init(coder: aDecoder);
        
        let vBounds = UIScreen.main.bounds;
        self.draggableView.bounds = vBounds;
        self.draggableView.frame = vBounds;
        
        
        self.draggableView.delegate = self;
    }
    
    

    
    //Start
    override func loadView() {
        super.loadView();
        
        
        
//        self.view.backgroundColor = UIColor.black;
        
        self.view = self.draggableView;
        //self.view.addSubview(self.draggableView);
        
        self.activityView.bounds = self.view.frame;
        self.activityView.center = self.view.center;
        self.activityView.startAnimating();
        self.view.addSubview(activityView);
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draggableView.AddShare()
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        
        draggableView.RemoveShareButton()
    }
    
    
    func share()
    {
   
//        if(Thread.isMainThread)
//        {
//             DispatchQueue.main.sync(execute: {
//            self.draggableView.RemoveShareButton()
//            self.performSegue(withIdentifier: "Share", sender: self);
//            }
//        }
//        else
//        {
            DispatchQueue.main.async(execute: {
                self.draggableView.RemoveShareButton()
                self.performSegue(withIdentifier: "Share", sender: self);
            });
//        }

        
//        self.performSegue(withIdentifier: "Share", sender: self);
    }
    
    func removeCurrentView(wasLiked: Bool)
    {
        onRemove(wasLiked: wasLiked);
    }
    
    func onRemove(wasLiked: Bool)
    {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        draggableView.RemoveShareButton()
        
        if(segue.identifier == "Share")
        {
            
            let shareVC = segue.destination as! CLShareViewController;
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
            let filePath = Bundle.main.path(forResource: "LoadingNew", ofType: "gif")
            var gifData = NSData.dataWithContentsOfMappedFile((filePath)!)
            self.draggableView.setMedia(media: MediaImage(media: nil, img: UIImage.animatedImage(withAnimatedGIFData: gifData as! Data!)));
        }
        else
        {
            self.draggableView.setMedia(media: media!);
        }
        
        if(self.activityView.isAnimating)
        {
            self.activityView.stopAnimating();
        }
    }
}

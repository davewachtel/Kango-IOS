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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.screenName = "Inbox Detail Screen";
       
    }
    
    override func onRemove(wasLiked: Bool) {
        self.navigationController?.popViewController(animated: true);
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        if (self.navigationController?.viewControllers.count==1)
        {
            let backItem = UIBarButtonItem()
            backItem.title = "Close"
            
            let backButton = UIBarButtonItem(title: "Close", style:.plain, target: self, action: #selector(CLInboxDetailViewController.pressedClose))
            self.navigationItem.leftBarButtonItem = backButton
            self.navigationController?.navigationBar.barTintColor =   UIColor(red: 253/255, green: 183/255, blue: 9/255, alpha: 1)
            self.navigationController?.navigationBar.isTranslucent = true
            
        }
        
        self.view.backgroundColor = UIColor.black
        if(assetId != nil)
        {
            print(self.assetId!)
            MediaApiController.getMedia(assetId: self.assetId!, success: { (media: Media) -> Void in
        
                self.downloadMedia(media: media);
        
            }, error: { () -> Void in
                print("MediaApiController ======> Error")
        
           });
        }
        
    }
    
    func pressedClose()
    {
    
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
           }
    
    override func viewWillDisappear(_ animated: Bool) {

        self.draggableView.RemoveShareButton()

    }
    func downloadMedia(media: Media)
    {
        MediaApiController.downloadMedia(media: media, success: downloadMedia_success, error: downloadMedia_error);
    }
    
    func downloadMedia_success(media: Media, img: UIImage)
    {
        self.setMedia(media: MediaImage(media: media, img: img));
    }
    
    func downloadMedia_error()
    {
        self.setMedia(media: nil);
    }
}

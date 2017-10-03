//
//  ViewController.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import UIKit

class CLPlaygroundViewController: CLDraggableViewController, MediaApiControllerProtocol {
    
    var serial_queue: DispatchQueue;
    
//        lazy var api : MediaApiController = MediaApiController(delegate: self, token: Token.loadValidToken()!);

    lazy var api : MediaApiController = MediaApiController(delegate: self, token: CLInstance.sharedInstance.authToken!);
    
    var swipeImages: Array<MediaImage> = [];
    
    required init?(coder aDecoder: NSCoder) {
        
        self.serial_queue =  DispatchQueue(label: "serial queue")
        super.init(coder: aDecoder);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        //Track Screen
        self.screenName = "Playground Screen";
        
        self.title = "Kango";
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (255/255), green: (153/255), blue: 0, alpha: 1.0)
        
    }
    
    //Complete
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CLPlaygroundViewController.menu_lock));
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = item;
        self.navigationController?.navigationItem.rightBarButtonItem = item;
        
        if (self.swipeImages.count == 0) {
            api.getNextContent();
        }
        
        NotificationCenter.default.addObserver(self,selector: #selector(CLPlaygroundViewController.ShowError),name:NSNotification.Name(rawValue: "ShowError"),object: nil)

    }
    
    
    func menu_lock()
    {
        
        if(self.tabBarController != nil)
        {
            (self.tabBarController as! CLTabBarController).sidebar.showInViewController(viewController: self, animated: true)
        }
        
    }
    
    func downloadMedia(media: Media)
    {
        MediaApiController.downloadMedia(media: media, success: downloadMedia_success, error: downloadMedia_error);
    }
    
    func downloadMedia_success(media: Media, img: UIImage)
    {
        self.addMedia(media: MediaImage(media: media, img: img));
    }
    
    func downloadMedia_error()
    {
        
    }
    
    func addMedia(media: MediaImage)
    {
        //dispatch_sync(serial_queue)
        //{
            let arrCount = self.swipeImages.count;
            let isEmpty = (arrCount == 0);
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
        let arrCount = self.swipeImages.count;
        if(arrCount == 0)
        {
            self.setMedia(media: nil);
        }
        else
        {
            self.setMedia(media: self.swipeImages[0]);
        }
       // }
    }
    
    override func onRemove(wasLiked: Bool) {
        
        serial_queue.sync()
            {
                if(self.swipeImages.count > 0){
                    let mediaImg = self.swipeImages.remove(at: 0);
                    if(mediaImg.media != nil){
                        self.api.markViewed(media: mediaImg.media!, wasLiked: wasLiked);
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
        
        var arrMedia = Media.mediaWithJSON(allResults: data);
        
        for i in 0 ..< arrMedia.count {
            self.downloadMedia(media: arrMedia[i]);
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
      
        if(self.tabBarController != nil)
        {
            (self.tabBarController as! CLTabBarController).sidebar.dismissAnimated(animated: true, completion: nil)
        }

        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
          print("touchesMoved")
        }
    
    func ShowError(notification: NSNotification)  {
        let alertController = UIAlertController(title: "Error", message: "Somthing gone wrong please try again", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
    
    }
}


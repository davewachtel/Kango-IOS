//
//  FindFriendsViewController.swift
//  Kango
//
//  Created by waseem shah on 11/3/16.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit

class FindFriendsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.backItem?.title = "Back"
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        let item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CLInboxViewController.menu_lock));
        self.title = "Find Friends";
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = item;
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (255/255), green: (153/255), blue: 0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    func menu_lock()
    {
        if(self.tabBarController != nil)
        {
            (self.tabBarController as! CLTabBarController).sidebar.showInViewController(viewController: self, animated: true)
        }
    }
    
    
}

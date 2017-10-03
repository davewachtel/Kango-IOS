//
//  CLTabBarController.swift
//  Kango
//
//  Created by James Majidian on 12/14/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation


@available(iOS 8.0, *)
class CLTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var sidebar: FrostedSidebar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self;
        tabBar.isHidden = true;
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(CLTabBarController.Logout),name:NSNotification.Name(rawValue: "Logout"),object: nil)
        
        
        sidebar = FrostedSidebar(itemImages: [
            UIImage(named: "Stream")!,
            UIImage(named: "Inbox")!,
            UIImage(named: "Friends")!,
            ],
            colors: [
                UIColor(red: 240/255, green: 159/255, blue: 254/255, alpha: 1),
              UIColor(red: 255/255, green: 137/255, blue: 167/255, alpha: 1),
                UIColor(red: 119/255, green: 152/255, blue: 255/255, alpha: 1)
            ],
            selectedItemIndices: NSIndexSet(index: 0))
        
        sidebar.showFromRight = true;
        sidebar.isSingleSelect = true
        sidebar.actionForIndex = [
            0: {self.sidebar.dismissAnimated(animated: true, completion: { finished in self.selectedIndex = 0}) },
            1: {self.sidebar.dismissAnimated(animated: true, completion: { finished in self.selectedIndex = 1}) },
           2: {self.sidebar.dismissAnimated(animated: true, completion: { finished in self.selectedIndex = 2}) }
        ];
    }
    
    func Logout(notification: NSNotification)  {
        let appDomain = Bundle.main.bundleIdentifier!
        
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        self.navigationController?.popToRootViewController(animated: true)
    }
}


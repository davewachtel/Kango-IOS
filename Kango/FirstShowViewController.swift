//
//  FirstShowViewController.swift
//  Kango
//
//  Created by waseem shah on 11/15/16.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit

class FirstShowViewController: UIViewController {

    @IBOutlet weak var splashView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
//        let token = Token.loadValidToken();
////        let app = UIApplication.shared.delegate as! AppDelegate
////        let deadLine =  Calendar.current.date(byAdding: .minute, value:1 , to: Date())
////        while app.deviceToekn == "" && deadLine! > Date()  {
////            
////        }
////        
//        if(token != nil)
//        {
//            
//            
//            
//            CLLoginViewController.authenticateAccount(username: (token?.getUsername())!, password: (token?.getPassword())!, completion: {
//              
//                CLInstance.sharedInstance.authToken = token;
//                
//                DispatchQueue.main.async(execute: {
//                
//                  
//                  self.performSegue(withIdentifier: "ShowMainView", sender: self);
//                      self.splashView.isHidden = true
//                })
//              
//            })
//        }
//        else
//        {
//           
//           splashView.isHidden = true
//        }
//        
//        if(token != nil)
//        {
//            CLInstance.sharedInstance.authToken = token;
//            self.performSegue(withIdentifier: "ShowMainView", sender: self);
            //            let alert = SCLAlertView(parent: self.view);
            //            alert.addButton(title: "Do it!") {
            //                self.login_success(token: token!);
            //            }
            //
            //            alert.addButton(title: "No, thanks...") {
            //                Token.clearToken();
            //                self.navigationController?.popViewController(animated: true);
            //            };
            //            let username = token!.getUsername();
            ////            alert.showTitle("Login", subTitle: "Would you like to login as " + username + "?", duration: TimeInterval(10), completeText: nil, style: SCLAlertViewStyle.Info);
            //
            //            alert.showTitle(title: "Login", subTitle: "Would you like to login as " + username + "?", duration: TimeInterval(10), completeText: nil, style: SCLAlertViewStyle.Info)
            
//        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {


        
        let when = DispatchTime.now() + 2
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            let token = Token.loadValidToken();
            
            if(token != nil)
            {
                //                if(token?.getPassword() != nil)
                //                {
                //                    CLLoginViewController.authenticateAccount(username: (token?.getUsername())!, password: (token?.getPassword())!, completion: {
                
                
                DispatchQueue.main.async(execute: {
                    CLInstance.sharedInstance.authToken = token;
                    self.performSegue(withIdentifier: "ShowMainView", sender: self);
                    //                            self.splashView.isHidden = true
                })
                
                //                    })
                //                }
                //                else {
                //                    self.splashView.isHidden = true
                //                }
            }
            else
            {
                
                self.splashView.isHidden = true
            }

        }
        
        
    }
    
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepare(for: segue, sender: sender);
        
        if(segue.identifier == "ShowMainView")
        {
            
        }
    }
    
    
}

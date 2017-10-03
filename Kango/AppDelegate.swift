//
//  AppDelegate.swift
//  Spatter
//
//  Created by James Majidian on 8/20/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    var deviceToekn = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
//        self.registerForPushNotifications(application: application)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
//        UINavigationBar.appearance().barTintColor = UIColor(colorLiteralRed: 253, green: 183, blue: 9, alpha: 1)

        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()

            
        } else {
            // Fallback on earlier versions
        }
        
        let gaInstance = GAI.sharedInstance();
        
        // Optional: automatically send uncaught exceptions to Google Analytics.
        gaInstance?.trackUncaughtExceptions = true;
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        gaInstance?.dispatchInterval = 30;
        
        // Optional: set Logger to VERBOSE for debug information.
        gaInstance?.logger.logLevel = GAILogLevel.verbose;
        
        // Initialize tracker. Replace with your tracking ID.
        gaInstance?.tracker(withTrackingId: "UA-56772093-1");
        
        
        let remoteNotification: NSDictionary! = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
        
        if (remoteNotification != nil) {
            
            handleNotification(userInfo: remoteNotification as! [AnyHashable : Any])
            
        }
        
        return true
    }
    

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Device Token:", deviceToken)
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        deviceToekn = deviceTokenString

        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Fail")
        deviceToekn = ""
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        
        let notificationSettings = UIUserNotificationSettings.init(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        print("UserInfo:\(userInfo)")
        
        if application.applicationState != .active {
            
            handleNotification(userInfo: userInfo)
        }
        else{
            let alertController = UIAlertController(title: "Notification", message: (userInfo["aps"] as! [AnyHashable : Any])["alert"] as? String , preferredStyle: .alert)
            
            if let _ = userInfo["asset_id"] as? Int {
                
                readMessageAPICall(msgId:"\(userInfo["msgId"] as! Int)")
                alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler:nil))
                alertController.addAction(UIAlertAction(title: "Show", style: .default, handler: { _ in
                    self.handleNotification(userInfo: userInfo)
                }))
            }
            else
            {
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
            }
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    
    func handleNotification(userInfo: [AnyHashable : Any])
    {
        if let assetId =  userInfo["asset_id"] as? Int {
            
            let inboxDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "CLInboxDetailViewController") as! CLInboxDetailViewController
            
            inboxDetailVC.assetId = assetId
            let navigationController = UINavigationController(rootViewController: inboxDetailVC)
            navigationController.navigationBar.tintColor = .black
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.present(navigationController, animated: true, completion: {
                self.readMessageAPICall(msgId:"\(userInfo["msgId"] as! Int)")
            })
        }
    }
    
    func readMessageAPICall(msgId: String) {
        
        if CLInstance.sharedInstance.authToken == nil {
            
            guard let token  =  Token.loadValidToken() else { return }
            sendreadCall(token: token, userId: token.getUserId(), msgId: msgId)
        }
        else{
            let userId = CLInstance.sharedInstance.authToken!.getUserId();
            sendreadCall(token:CLInstance.sharedInstance.authToken! , userId: userId, msgId: msgId)
        }
    }
    
    func sendreadCall(token:Token,userId: String, msgId: String) {
        
        let api = InboxApiController(token: token);
        api.MarkMessage(userId: userId, MessageID: msgId, success:  {  (token: NSDictionary) -> () in
            print(token)
            
        }, error: { (message) -> Void in
            DispatchQueue.main.sync(execute: {
                
            });
        });
    }
    
    
//    @available(iOS 10.0, *)
//    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
//    {
//        //Handle the notification
//        completionHandler(
//            [UNNotificationPresentationOptions.alert,
//             UNNotificationPresentationOptions.sound,
//             UNNotificationPresentationOptions.badge])
//    }
//
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
//        self.window!.rootViewController!.p(vc, animated: false, completion: nil)
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    
  }


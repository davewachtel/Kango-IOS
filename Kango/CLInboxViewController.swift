//
//  CLInboxViewController.swift
//  Kango
//
//  Created by James Majidian on 12/14/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class CLInboxViewController : UITableViewController
{
    var messages = [InboxMessage]();
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CLInboxTableViewCell")
        
        var item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.Bordered, target: self, action: "menu_lock");
        item.title = "Menu";
        
        self.navigationItem.rightBarButtonItem = item;
        //self.navigationController?.navigationItem.rightBarButtonItem = item;
        
        //Allow Delete.
        self.tableView.allowsMultipleSelectionDuringEditing = true;
     
        let userId = CLInstance.sharedInstance.authToken!.getUserId();
        let api = InboxApiController(token: CLInstance.sharedInstance.authToken!);
        api.getInbox(userId, { (msgArray: [InboxMessage]) -> Void in
            
            self.messages = msgArray;
            
            
            if(NSThread.isMainThread())
            {
                // Reload the table
                self.tableView.reloadData();
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), {
                    // Reload the table
                    self.tableView.reloadData();
                });
            }
            
            
            }, error: { (message) -> Void in
                
        });
    }
    
    func menu_lock()
    {
        
        if(self.tabBarController != nil)
        {
            (self.tabBarController as CLTabBarController).sidebar.showInViewController(self, animated: true)
        }
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        //let tc: AnyObject? = self.tableView.dequeueReusableCellWithIdentifier("cell");
        
        let cell : CLInboxTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell" ,forIndexPath: indexPath) as CLInboxTableViewCell;
        
        var msg : InboxMessage
        msg = self.messages[indexPath.row];
        
        cell.bind(msg);
        
        return cell
    }
   
    /*
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(editingStyle == UITableViewCellEditingStyle.Delete)
        {
            self.messages.removeAtIndex(indexPath.row);
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic);
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var msg = self.messages[indexPath.row];
        msg.isRead = true;
        
        self.performSegueWithIdentifier("InboxDetail", sender: self);
        
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None);
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "InboxDetail")
        {
            
            let inboxDetailVC = segue.destinationViewController as CLInboxDetailViewController;
            let indexPath = self.tableView.indexPathForSelectedRow()!
            
            var msg = self.messages[indexPath.row];
            
            inboxDetailVC.assetId = msg.assetId;
            
        }
    }
}
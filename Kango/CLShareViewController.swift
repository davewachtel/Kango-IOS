//
//  CLShareViewController.swift
//  Kango
//
//  Created by James Majidian on 12/25/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

protocol CLShareViewDelegate
{
    func cancel();
    func share();
}

class CLShareViewController : UITableViewController, CLShareViewDelegate
{
    var contacts = [Contact]();
    var selected = [Int: String]();
    
    var assetId: Int?;
    
    let api = ShareApiController(token: CLInstance.sharedInstance.authToken!);
    
    var navBar: UINavigationBar?;
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.title = "Share";
    }
    
    override func loadView() {
        super.loadView();
        
        var btnCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: "cancel");

        var btnShare = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.Bordered, target: self, action: "share");
        
        var navItem = UINavigationItem(title: "Share");
        navItem.rightBarButtonItem = btnShare;
        navItem.leftBarButtonItems = [btnCancel];
        
        
        navBar = UINavigationBar();
        navBar!.items = [navItem];
        navBar!.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        
        self.view.addSubview(navBar!);
    }
    
    
    
    override func viewDidLoad() {
        
        (self.view as CLShareView).shareDelegate = self;
        (self.view as CLShareView).navBar = self.navBar;
        
        
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CLInboxTableViewCell")
        
        let api = ShareApiController(token: CLInstance.sharedInstance.authToken!);
        api.getContacts({ (result: [Contact]) -> Void in
            
            var data = [Contact]();
            data.append(Contact(id: "", firstName: "", lastName: ""));
            data += result;
            
            self.contacts = data;
            
            // Reload the table
            self.tableView.reloadData();
            
            }, error: { (message) -> Void in
                
        });
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell;
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell");
        /*
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell");
        }
        */
        
        if(self.selected[indexPath.row] != nil)
        {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.None;
        }
        
        
        let contact = self.contacts[indexPath.row];
        cell.textLabel?.text = contact.firstName + " " + contact.lastName;
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        if(self.selected[indexPath.row] != nil)
        {
            self.selected[indexPath.row] = nil;
        }
        else
        {
            self.selected[indexPath.row] = self.contacts[indexPath.row].id;
        }
        
        tableView.reloadData();
    }
    
    
    /*
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        var header = tableView.dequeueReusableCellWithIdentifier("Header") as UITableViewCell;
        header.backgroundColor = UIColor(red: (247/255.0), green: (247/255.0), blue: (247/255.0), alpha: 1);
        
        return header;
    }
    */
    func share()
    {
        if(self.selected.count == 0)
        {
            return;
        }
        
        let userIds: [String] = self.selected.values.array;
        api.shareAsset(assetId!, userIds: userIds, success: { () -> Void in
            
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                //var alert = SCLAlertView(parent: self.view);
                //alert.showInfo("Success", subTitle: "Your message successfully shared.", closeButtonTitle: "OK", duration: NSTimeInterval(3));
            });
        },
        error: { (message: String?) -> Void in
            
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                //var alert = SCLAlertView(parent: self.view);
                //alert.showError("Oops", subTitle: "Your message was not successfully shared.", closeButtonTitle: "OK", duration: NSTimeInterval(3));
            });
        });
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
        
        
        });
    }
}
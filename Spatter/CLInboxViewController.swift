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
        /*
        {
        "id": 2288,
        "mediatype": 1,
        "title": "Yellow Brick Road!",
        "url": "http://r2-store.distractify.netdna-cdn.com/postimage/201410/10/7fe96376a7181fc4ec75686580e59f14_970x.jpg"
        },
        {
        "id": 197,
        "mediatype": 2,
        "title": "There are no accidents",
        "url": "http://i.imgur.com/PPzqM1E.gif"
        },
        {
        "id": 2609,
        "mediatype": 2,
        "title": "Miss",
        "url": "http://i.imgur.com/jjSIae0.gif"
        },
        {
        "id": 2598,
        "mediatype": 2,
        "title": "monkey see monkey do",
        "url": "http://stream1.gifsoup.com/view2/2061786/kid-will-do-anything-for-candy-o.gif"
        },
        {
        "id": 2286,
        "mediatype": 1,
        "title": "Life of Pi",
        "url": "http://r2-store.distractify.netdna-cdn.com/postimage/201410/10/66012eaacb0dfc900f5538572519b3f9_970x.jpg"
        }
        */
        self.messages = [
            InboxMessage(media: Media(id: 2288, title: "Yellow Brick Road!", url: "http://r2-store.distractify.netdna-cdn.com/postimage/201410/10/7fe96376a7181fc4ec75686580e59f14_970x.jpg", mediaTypeId: 1), isRead: false),
            InboxMessage(media: Media(id: 197, title: "There are no accidents", url: "http://i.imgur.com/PPzqM1E.gif", mediaTypeId: 2), isRead: true),
            InboxMessage(media: Media(id: 2609, title: "Miss", url: "http://i.imgur.com/jjSIae0.gif", mediaTypeId: 2), isRead: false),
            InboxMessage(media: Media(id: 2598, title: "monkey see monkey do", url: "http://stream1.gifsoup.com/view2/2061786/kid-will-do-anything-for-candy-o.gif", mediaTypeId: 2), isRead: false),
            InboxMessage(media: Media(id: 2286, title: "Life of Pi", url: "http://r2-store.distractify.netdna-cdn.com/postimage/201410/10/66012eaacb0dfc900f5538572519b3f9_970x.jpg", mediaTypeId: 1), isRead: true),
        
        ];
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.Bordered, target: self, action: "menu_lock");
        item.title = "Menu";
        
        self.navigationItem.rightBarButtonItem = item;
        self.navigationController?.navigationItem.rightBarButtonItem = item;
        
        
        // Reload the table
        self.tableView.reloadData()
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
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        var msg : InboxMessage
        msg = self.messages[indexPath.row];
        
        // Configure the cell
        cell.textLabel!.text = msg.media.title;
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var msg = self.messages[indexPath.row];
        msg.isRead = true;
        
        self.performSegueWithIdentifier("InboxDetail", sender: self)//tableView)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "InboxDetail")
        {
            let inboxDetailVC = segue.destinationViewController as CLInboxDetailViewController;
            let indexPath = self.tableView.indexPathForSelectedRow()!
            
            var msg = self.messages[indexPath.row];
            
            //let destinationTitle = self.messages[indexPath.row].med
            inboxDetailVC.media = msg.media;
            
        }
    }
}
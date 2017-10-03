//
//  CLInboxViewController.swift
//  Kango
//
//  Created by James Majidian on 12/14/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation
import Contacts

class CLInboxViewController : UITableViewController
{
    var messages = [InboxMessage]();
    var contacts : [CNContact] = [];
    var contactsStore: CNContactStore?
    
    let api = InboxApiController(token: CLInstance.sharedInstance.authToken!);
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CLInboxTableViewCell")
        
        let item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CLInboxViewController.menu_lock));
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = item;
        //self.navigationController?.navigationItem.rightBarButtonItem = item;
        
        //Allow Delete.
        self.tableView.allowsMultipleSelectionDuringEditing = true;
        
        let itemBack = UIBarButtonItem(image: UIImage(named: "backArrowNew"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.Back));
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = itemBack;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         getContacts()
        
    }
    
    func getContacts() {
        
        
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (Bool, Error) in
                self.retrieveContactsWithStore(store: store)
                
            })
            
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }else if CNContactStore.authorizationStatus(for: .contacts) == .denied || CNContactStore.authorizationStatus(for: .contacts) == .restricted {
            
            self.ShowError(string: "Please allow Kango to access your contacts.")
            
        }
    }

    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        
        
        if contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            contactsStore = CNContactStore()
        }
        
        contacts.removeAll()
        
        let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
        
        do {
            try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                //Ordering contacts based on alphabets in firstname
                self.contacts.append(contact)
            })
            
        }
            //Catching exception as enumerateContactsWithFetchRequest can throw errors
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        contacts.sort {
            item1, item2 in
            let date1 = item1.givenName
            let date2 = item2.givenName
            return date1.compare(date2) == ComparisonResult.orderedAscending
        }
        
        
        
        api.getInbox(userId:  CLInstance.sharedInstance.authToken!.getUserId(), success: { (msgArray: [InboxMessage]) -> Void in
            
            print(msgArray)
         
            
            DispatchQueue.main.sync(execute: {
                
            });
            
            
            if(Thread.isMainThread)
            {
                // Reload the table
                   self.GetAllusers_success(AllMessages: msgArray);
//                self.tableView.reloadData();
            }
            else
            {
                DispatchQueue.main.sync(execute: {
                    // Reload the table
                       self.GetAllusers_success(AllMessages: msgArray);
//                    self.tableView.reloadData();
                });
            }
            
        }, error: { (message) -> Void in
            DispatchQueue.main.sync(execute: {
                
            });
        });

    }

    
    func GetAllusers_success(AllMessages: [InboxMessage]) -> Void
    {
        messages.removeAll()
        print("Inbox messages:\(AllMessages)")
        
        if (AllMessages.count > 0)
        {
            for index in 0..<AllMessages.count
            {
                let message = AllMessages[index]
                
                for i in 0 ..< self.contacts.count {
                    let datadict = self.contacts[i]
                    
                    if (datadict.phoneNumbers.count > 0){
                        let phonenumber = ((datadict.phoneNumbers[0].value).value(forKey: "digits") as? String)!
                        
                        if phonenumber.compare(message.phoneNumber) == .orderedSame{
                            
                            message.fromUser = "\(datadict.givenName) \(datadict.familyName)"
                            
                            break;
                        }
                    }
                }
                self.messages.append(message)
            }
        }
        
        self.tableView.reloadData();
    }
    
    func Back(){
        //        Taponitem
        
        (self.tabBarController as! CLTabBarController).sidebar.Taponitem(index: 0)
    }
    
    func menu_lock()
    {
        
        if(self.tabBarController != nil)
        {
            (self.tabBarController as! CLTabBarController).sidebar.showInViewController(viewController: self, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.messages)
        return self.messages.count;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(self.messages[indexPath.row])
        let cell : CLInboxTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell" ,for: indexPath as IndexPath) as! CLInboxTableViewCell;
        
        var msg : InboxMessage
        msg = self.messages[indexPath.row];

        cell.bind(msg: msg);
        
        return cell
    }

     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(editingStyle == UITableViewCellEditingStyle.delete)
        {
            self.messages.remove(at: indexPath.row);
            self.tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic);
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let msg = self.messages[indexPath.row];
         let userId = CLInstance.sharedInstance.authToken!.getUserId();
        
        
        print(msg.msgID)

        readMessageAPICall(msgId: msg.msgID)
//        api.MarkMessage(userId: userId, MessageID:msg.msgID , success:  {  (token: NSDictionary) -> () in
//            
//            print(token)
//            
//            
//        }, error: { (message) -> Void in
//            DispatchQueue.main.sync(execute: {
//                
//            });
//        });

       
        msg.isRead = true;
        
//        DispatchQueue.
        
        DispatchQueue.main.async(execute: {
//            self.draggableView.RemoveShareButton()
//            self.performSegue(withIdentifier: "Share", sender: self);
            self.performSegue(withIdentifier: "InboxDetail", sender: self);
            self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none);

        });
       
    }

    
    func readMessageAPICall(msgId: String) {
        
        
        let userId = CLInstance.sharedInstance.authToken!.getUserId();
        
        
//        print(msg.msgID)
        let api = InboxApiController(token: CLInstance.sharedInstance.authToken!);
        api.MarkMessage(userId: userId, MessageID: msgId, success:  {  (token: NSDictionary) -> () in
            
            print(token)
            
            
        }, error: { (message) -> Void in
            DispatchQueue.main.sync(execute: {
                
            });
        });

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "InboxDetail")
        {
        
            let inboxDetailVC = segue.destination as! CLInboxDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            
            let msg = self.messages[indexPath.row];
            
            inboxDetailVC.assetId = msg.assetId;
        }
 
    }
    
    
    func ShowError(string : String) {
        let alertController = UIAlertController(title: "Error", message: string, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
    }

}

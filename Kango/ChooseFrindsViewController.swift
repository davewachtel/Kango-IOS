//
//  ChooseFrindsViewController.swift
//  Kango
//
//  Created by waseem shah on 11/10/16.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ChooseFrindsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate {

    @IBOutlet var tbleViewMain : UITableView!
    @IBOutlet var viewSpinner : UIView!
    
    var api                 = LoginApiController();
    var chooseTag           : Int = 0
    var mainarray           : Array<Dictionary<String,AnyObject>>  = Array()
    var mainarrayForFriends : Array<Dictionary<String,AnyObject>>  = Array()
    var results             : [CNContact] = []
    var pagenumber          : Int = 1
    let totalRecords        : Int = 50
    var isNextApiCall       : Bool = true
    var isAPICall           : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        chooseTag = 0
        isAPICall = true
        isNextApiCall = true
        
        let UserName =  (CLInstance.sharedInstance.authToken?.getUsername())! as String
        
        print(UserName)
        
        
        self.navigationController?.isNavigationBarHidden = false

        let item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChooseFrindsViewController.menu_lock));
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = item
        self.GetAllFriends()
        self.getContacts()
        
    }
    
    func GetAllusers() {
        
        if isAPICall && isNextApiCall {
            
            isAPICall = false;

            self.viewSpinner.isHidden = false
            pagenumber = 0
            self.GetAllusersAPI(pagenumber: String(pagenumber), pagesize: String(totalRecords), completion: { () in
                
                
            });
        }
       
    }
    
    func GetAllFriends() {
        
        if isAPICall && isNextApiCall {
            
            isAPICall = false;
            
            self.viewSpinner.isHidden = false
            let token =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
            pagenumber = 0
            self.GetAllFriendsAPI(pagenumber: String(pagenumber) as NSString, pagesize: String(totalRecords) as NSString,UserId: token as NSString, completion: { () in
                
                
            });

        }
        
    }

    
    
    func GetAllusersAPI(pagenumber: String, pagesize: String, completion: @escaping () -> Void) {
        
        let token =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        
        api.GetAllusers(pagenumber: pagenumber as NSString
            , pagesize: pagesize as NSString
            , UserId: token as NSString
            , success: {
                (token: NSDictionary) -> () in
                DispatchQueue.main.sync(execute: {
                    self.viewSpinner.isHidden = true
                });
                self.GetAllusers_success(token: token);
                completion();
                
            },
              error: {
                (message: String?) -> () in
                DispatchQueue.main.sync(execute: {
                    self.viewSpinner.isHidden = true
                });
                self.GetAllusers_failed(message: message);
                completion();
        });
    }
    
    func GetAllFriendsAPI(pagenumber: NSString, pagesize: NSString, UserId: NSString, completion: @escaping () -> Void) {
        
        api.ShowAllFriends(pagenumber: pagenumber, pagesize: pagesize, UserId: UserId
            , success: {
                (token: NSDictionary) -> () in
                DispatchQueue.main.sync(execute: {
                    self.viewSpinner.isHidden = true
                });
                self.GetAllusers_success(token: token);
                completion();
                
            },
              error: {
                (message: String?) -> () in
                DispatchQueue.main.sync(execute: {
                    self.viewSpinner.isHidden = true
                });
                self.GetAllusers_failed(message: message);
                completion();
        });
    }

    

    
    func GetAllusers_success(token: NSDictionary) -> Void
    {
        isAPICall = true
        
        if(chooseTag == 0){
            self.mainarrayForFriends += token["data"] as! Array
            if (self.mainarrayForFriends.count % totalRecords == 0 && self.mainarrayForFriends.count > 0) {
                isNextApiCall = true
            }else {
                isNextApiCall = false
            }
            
        }else if(chooseTag == 2){
//            self.mainarray = token["data"] as! Array

            self.mainarray += token["data"] as! Array
            if (self.mainarray.count % totalRecords == 0 && self.mainarray.count > 0) {
                isNextApiCall = true
            }else {
                isNextApiCall = false
            }
        }
        
        
        
        if(Thread.isMainThread)
        {
            self.tbleViewMain.reloadData()
        }
        else
        {
            DispatchQueue.main.sync(execute: {
                self.tbleViewMain.reloadData()
                
            });
        }
        
    }
    
    func GetAllusers_failed(message: String?) -> Void
    {
        isAPICall = true
        
        var msg: String = "Please try again.";
        if(message != nil)
        {
            msg = message!;
        }
        
        DispatchQueue.main.sync(execute: {
            self.ShowError(string: msg)
            self.tbleViewMain.reloadData()
        });
    }
    
    
    func ShowError(string : String) {
        let alertController = UIAlertController(title: "Error", message: string, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
    }
    
    
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (Bool, Error) in
                print(Bool)
                print("requestAccess")
                self.retrieveContactsWithStore(store: store)
                
            })
            
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }
     
    }
    
    
    func retrieveContactsWithStore(store: CNContactStore) {
        
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                self.results.append(contentsOf: containerResults)
                tbleViewMain.reloadData()
            } catch {
                print("Error fetching results for container")
            }
        }
        
        print(self.results.count)
        
        var arrayNumbers = [String]()
        
        
        for i in 0 ..< self.results.count {
            let datadict = self.results[i]
            
            if (datadict.phoneNumbers.count > 0){
                arrayNumbers.append(((datadict.phoneNumbers[0].value ).value(forKey: "digits") as? String)!)
            }
        }

        print(arrayNumbers)
        
        self.CheckFrindAPI(UserList: arrayNumbers as [NSString], completion: { () in
            
            
        });
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.chooseTag == 0)
        {
            return mainarrayForFriends.count
        }

//        if (self.chooseTag == 2)
//        {
//            return mainarray.count
//        }else if (self.chooseTag == 1){
//            return mainarrayForFriends.count
//        }
//        
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (self.chooseTag == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCC") as! FindFriendsCC
            let datadict = results[indexPath.row]
            
            cell.lblUserName.text = datadict.givenName + " " + datadict.familyName
            
            if (datadict.phoneNumbers.count > 0){
                cell.lblPhonenumber.text = (datadict.phoneNumbers[0].value ).value(forKey: "digits") as? String
            }else {
                cell.lblPhonenumber.text = ""
            }
            
            cell.btnAdd.tag = indexPath.row
            cell.btnAdd.setImage(UIImage.init(named: "AddButton"), for: .normal)
            cell.btnAdd.addTarget(self, action: #selector(ChooseFrindsViewController.AddFriends), for: UIControlEvents.touchUpInside)
            
            return cell
            
        }else  if (self.chooseTag == 2){
          
           

            let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCC") as! FindFriendsCC
            let datadict = self.mainarray[indexPath.row]
            
            cell.lblUserName.text = datadict["email"] as? String
            
            if let outcome = datadict["phonenumber"] as? String
            {
                cell.lblPhonenumber.text = outcome
            }
            cell.btnAdd.tag = indexPath.row
            cell.btnAdd.setImage(UIImage.init(named: "AddButton"), for: .normal)
            cell.btnAdd.addTarget(self, action: #selector(ChooseFrindsViewController.AddFriends), for: UIControlEvents.touchUpInside)
            
            if (isNextApiCall){
                if(indexPath.row == totalRecords - 1){
                    pagenumber = pagenumber + 1
                    self.GetAllusers()
                }
            }

            
            return cell

        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCC") as! FindFriendsCC
            let datadict = self.mainarrayForFriends[indexPath.row]
            
            cell.lblUserName.text = datadict["email"] as? String
            
            if let outcome = datadict["phonenumber"] as? String
            {
                cell.lblPhonenumber.text = outcome
            }
            cell.btnAdd.tag = indexPath.row
            cell.btnAdd.setImage(UIImage.init(named: "RemoveButton"), for: .normal)
            cell.btnAdd.addTarget(self, action: #selector(ChooseFrindsViewController.AddFriends), for: UIControlEvents.touchUpInside)
            
            
            if (isNextApiCall){
                if(indexPath.row == totalRecords - 1){
                    pagenumber = pagenumber + 1
                    self.GetAllFriends()
                }
            }
            
            return cell

        }
    }
    
    func AddFriends(sender : UIButton) {
        print(sender.tag)
        switch self.chooseTag {
        case 1:
            
            let datadict = results[sender.tag]
            
            var phonenumber = ""
            
            if (datadict.phoneNumbers.count > 0){
                phonenumber = ((datadict.phoneNumbers[0].value ).value(forKey: "digits") as? String)!
            }

            if (phonenumber.characters.count > 0) {
                self.sendMEssage(phonenumber: phonenumber as NSString)
            }
            
            break;
        
        case 0:
            
            let datadict = self.mainarrayForFriends[sender.tag]
            print(datadict)
            
            self.RemoveFriend(Userto: datadict["id"] as! NSString)
            
            break;
            
        case 2:
            
            let datadict = self.mainarray[sender.tag]
            print(datadict)
            
            self.AddFriend(Userto: datadict["id"] as! NSString)
            
            break;
            
            
        default:
         
            
            break;
        }
        
    }
    
    
    
    func menu_lock()
    {
        
        if(self.tabBarController != nil)
        {
            (self.tabBarController as! CLTabBarController).sidebar.showInViewController(viewController: self, animated: true)
        }
    }
    
    @IBAction func SwitchList(_ sender: UISegmentedControl) {
        pagenumber = 1
        isNextApiCall = true
        isAPICall = true
        self.mainarrayForFriends.removeAll()
        self.mainarray.removeAll()
        
        if(sender.selectedSegmentIndex == 0)
        {
            self.chooseTag = 0
             self.GetAllFriends()
        }else  if(sender.selectedSegmentIndex == 1){
            self.chooseTag = 1
            self.tbleViewMain.reloadData()
           
        }else  if(sender.selectedSegmentIndex == 2){
            self.chooseTag = 2
            self.GetAllusers()
        }
    }
    
    
    func AddFriend(Userto: NSString) {
        self.viewSpinner.isHidden = false
        let Userfrom =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        
        self.AddFrindAPI(Userto: Userto, Userfrom: Userfrom as NSString, completion: { () in
            
            
        });
    }
    
    
    
    func AddFrindAPI(Userto: NSString, Userfrom: NSString, completion: @escaping () -> Void) {
        
        api.AddFriend(Userto: Userto, Userfrom: Userfrom,
                      success: {
                        (token: NSDictionary) -> () in
                        DispatchQueue.main.sync(execute: {
                            self.viewSpinner.isHidden = true
                        });
                        self.GetAllusers();
                        completion();
                    
                    },
                      error: {
                        (message: String?) -> () in
                        DispatchQueue.main.sync(execute: {
                            self.viewSpinner.isHidden = true
                        });
                        self.GetAllusers_failed(message: message);
                        completion();
        });

    }
    
    
    func RemoveFriend(Userto: NSString) {
        self.viewSpinner.isHidden = false
        let Userfrom =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        
        self.RemoveFrindAPI(Userto: Userto, Userfrom: Userfrom as NSString, completion: { () in
            
            
        });
    }
    
    func RemoveFrindAPI(Userto: NSString, Userfrom: NSString, completion: @escaping () -> Void) {
        
        api.RemoveFriend(Userto: Userto, Userfrom: Userfrom,
                      success: {
                        (token: NSDictionary) -> () in
                        DispatchQueue.main.sync(execute: {
                            self.viewSpinner.isHidden = true
                        });
                        self.GetAllFriends();
                        completion();
                        
            },
                      error: {
                        (message: String?) -> () in
                        DispatchQueue.main.sync(execute: {
                            self.viewSpinner.isHidden = true
                        });
                        self.GetAllusers_failed(message: message);
                        completion();
        });
        
    }
    
    
    func CheckFrindAPI(UserList: [NSString], completion: @escaping () -> Void) {
        
         let Userfrom =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        
        api.checkFriend(User: Userfrom as NSString , UserList: UserList as [String],
                         success: {
                            (token: NSDictionary) -> () in
                            
                            print("=======>")
                            print(token)
                            
                            DispatchQueue.main.sync(execute: {
                                self.viewSpinner.isHidden = true
                            });
//                            self.GetAllFriends();
                            completion();
                            
        },
                         error: {
                            (message: String?) -> () in
                            DispatchQueue.main.sync(execute: {
                                self.viewSpinner.isHidden = true
                            });
//                            self.GetAllusers_failed(message: message);
                            completion();
        });
        
    }

    

    
    func sendMEssage(phonenumber : NSString){
        let UserName =  (CLInstance.sharedInstance.authToken?.getUsername())! as String
        
        print(UserName)
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            


            controller.body = UserName + "\nIf you haven't yet connected your Kango App, please do. We would be pleased to have you so join us."
            controller.recipients = [phonenumber as String]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
}

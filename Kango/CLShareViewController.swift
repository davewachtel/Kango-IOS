//
//  CLShareViewController.swift
//  Kango
//
//  Created by James Majidian on 12/25/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation
import Contacts

class CLShareViewController : UITableViewController
{
    
    @IBOutlet var viewBottom    : UIView!
    @IBOutlet var viewlblName   : UILabel!
    @IBOutlet var viewFindFriend: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var contacts    = [[String : String]]();
    var selected    = [Int: String]();
    var results                 : [CNContact] = []
    
    var rowArray = [String : [[String : String]]]()
    var sectionArray = [String]()
    
    var navBar: UINavigationBar?;
    
    let api         = ShareApiController(token: CLInstance.sharedInstance.authToken!);
    var apiLogin   = LoginApiController();
    let pagenumber          : Int = 1
    let totalRecords        : Int = 50
    
    var contactsStore: CNContactStore?
    
    var assetId: Int?;
    
    override func viewDidLoad() {
        
        super.viewDidLoad();

    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getContacts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewBottom.removeFromSuperview()
        viewFindFriend.removeFromSuperview()
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
        
        results.removeAll()
        
        let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
        
        do {
            try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                //Ordering contacts based on alphabets in firstname
                self.results.append(contact)
            })
            
        }
            //Catching exception as enumerateContactsWithFetchRequest can throw errors
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        results.sort {
            item1, item2 in
            let date1 = item1.givenName
            let date2 = item2.givenName
            return date1.compare(date2) == ComparisonResult.orderedAscending
        }
        
        
        
        self.APICAll()
        
        
    }

    func APICAll() {
        
        let token =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        
//        startActivityIndicator()
        
        apiLogin.ShowAllFriends(pagenumber: String(pagenumber) as NSString, pagesize: String(totalRecords) as NSString, UserId: token as NSString
            , success: {
                (token: NSDictionary) -> () in
                
//                self.stopActivityIndicator()
                self.GetAllusers_success(token: token);
                
            },
              error: {
                (message: String?) -> () in
                
//                self.stopActivityIndicator()
                self.GetAllusers_failed(message: message);
        });
    }
    
    func GetAllusers_success(token: NSDictionary) -> Void
    {
        
        print(token)
        var AllUsers = token["data"] as! [[String : String]]
        
        print(AllUsers)
        
        if (AllUsers.count > 0)
        {
            for index in 0..<AllUsers.count
            {
                var  dataUsers = AllUsers[index]
                
                for i in 0 ..< self.results.count {
                    let datadict = self.results[i]
                    
                    if (datadict.phoneNumbers.count > 0){
                        let phonenumber = ((datadict.phoneNumbers[0].value).value(forKey: "digits") as? String)!
                        
                        if phonenumber ==  dataUsers["phonenumber"]{
                            dataUsers["name"] = "\(datadict.givenName)  \(datadict.familyName)"
                            dataUsers["isSelect"] = ""
                            break;
                        }
                    }
                }
                
                if (dataUsers["name"] != nil)
                {
                }else {
                    dataUsers["name"] = dataUsers["email"]
                    dataUsers["isSelect"] = ""
                }
                
                
                self.contacts.append(dataUsers)
            }
            
            print(self.contacts)
            
            contacts.sort {
                item1, item2 in
                let date1 = item1["name"]?.lowercased()
                let date2 = item2["name"]?.lowercased()
                return date1!.compare(date2!) == ComparisonResult.orderedAscending
            }
            
            
            
            for index in 0..<contacts.count
            {
                let  dataUsers = contacts[index]
                var nameUser = dataUsers["name"]
                let firstChar = nameUser?.characters.first
                
                var isFound = false
                
                for indexInner in 0..<sectionArray.count {
                    let sectionObject = sectionArray[indexInner]
                    
                    if (sectionObject.caseInsensitiveCompare(String(firstChar!)) == .orderedSame){
                        isFound = true
                    }
                }
                
                if (!isFound){
                    let first = String(firstChar!)
                    sectionArray.append(first.uppercased())
                }
            }
            
            print(self.sectionArray)
            
            
            for index in 0..<sectionArray.count {
                let charFirst = sectionArray[index]
                
                var rowArrayInner = [[String : String]]()
                
                for indexInner in 0..<contacts.count
                {
                    let  dataUsers = contacts[indexInner]
                    var nameUser = dataUsers["name"]
                    let firstChar = nameUser?.characters.first
                    print(nameUser ?? "UserNam:")
                    if (charFirst == (String(firstChar!).uppercased())){
                        rowArrayInner.append(dataUsers)
                        
                    }
                }
                print(rowArrayInner)
                rowArray[charFirst] = rowArrayInner as  [[String : String]]?
                
                
            }
            
            
            print(rowArray)
            
            if(Thread.isMainThread)
            {
                self.tableView.reloadData()
            }
            else
            {
                DispatchQueue.main.sync(execute: {
                    self.tableView.reloadData()
                    
                });
            }
            
        }
        else
        {
            DispatchQueue.main.async(execute:
                {
                    let appD = UIApplication.shared.delegate as! AppDelegate
                    
                    appD.window?.addSubview(self.viewFindFriend)
                    //            self.view.addSubview(viewFindFriend)
                    self.viewFindFriend.frame = CGRect.init(x: Int(self.view.frame.origin.x), y: Int(self.view.frame.size.height - self.viewFindFriend.frame.size.height), width: Int(self.view.frame.size.width), height: Int(self.viewFindFriend.frame.size.height))
            })
//            DispatchQueue.main.asyn(execute: {
//                self.ShowError(string: msg)
//                self.tableView.reloadData()
//            });

//            viewFindFriend.removeFromSuperview()
//            let appD = UIApplication.shared.delegate as! AppDelegate
            
//            appD.window?.addSubview(viewFindFriend)
//            self.view.addSubview(viewFindFriend)
//            viewFindFriend.frame = CGRect.init(x: Int(self.view.frame.origin.x), y: Int(self.view.frame.size.height - self.viewFindFriend.frame.size.height), width: Int(self.view.frame.size.width), height: Int(self.viewFindFriend.frame.size.height))
        }
        
        
    }
    
    func GetAllusers_failed(message: String?) -> Void
    {
        var msg: String = "Please try again.";
        if(message != nil)
        {
            msg = message!;
        }
        
        DispatchQueue.main.sync(execute: {
            self.ShowError(string: msg)
            self.tableView.reloadData()
        });
    }

    
    func ShowError(string : String) {
        let alertController = UIAlertController(title: "Error", message: string, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
    }
    
    
    func menu_lock()
    {
        
        if(self.tabBarController != nil)
        {
            (self.tabBarController as! CLTabBarController).sidebar.showInViewController(viewController: self, animated: true)
        }
        
    }
    
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//     return self.sectionArray
//    }
//    
//    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//         return index
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 0
        }
        
        let arrayCount = rowArray[sectionArray[section-1]]
        
        return arrayCount!.count;
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellShareS")! as UITableViewCell
        
        
        
        
        if indexPath.section > 0
        {

            let arrayCount = rowArray[sectionArray[indexPath.section - 1]]
            
            let contact = arrayCount?[indexPath.row]
            
            
            cell.textLabel?.text = (contact?["name"])! as String

            
                cell.accessoryType = UITableViewCellAccessoryType.none;
            
            if (contact?["isSelect"]?.characters.count)! > 0 {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark;
            }
            let sepFrame = CGRect(x: 0, y: cell.frame.size.height-3, width: UIScreen.main.bounds.size.width, height: 1)
            
            let separatorView = UIView(frame: sepFrame)
            separatorView.backgroundColor = UIColor.black
            cell.addSubview(separatorView)

            
        }

        return cell
        
    }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath as IndexPath, animated: true);

    
    if (indexPath.section > 0)
    {

        var arrayCount = rowArray[sectionArray[indexPath.section - 1]]
        
        var contact = arrayCount?[indexPath.row]
        
        
        if ((contact?["isSelect"]?.characters.count)! > 0){
            contact?["isSelect"] = ""
            
            
            var fullNameArr = viewlblName.text?.characters.split{$0 == ","}.map(String.init)
            
             print(fullNameArr!)
            print(fullNameArr!.count)
            

            let nameUser = (contact?["name"])
            var indexFound = -1
            for index in 0..<fullNameArr!.count
            {
                if (fullNameArr?[index] == nameUser)
                {
                    indexFound = index
                    break
                }
            }
            
            
           fullNameArr?.remove(at: indexFound)
            print(fullNameArr!)
            
            viewlblName.text = ""
            
            for index in 0..<fullNameArr!.count
            {
                if (index == 0){
                    viewlblName.text = fullNameArr?[index]
                }else {
                    viewlblName.text = viewlblName.text! + "," + (fullNameArr?[index])!
                }
            }
            
            let appD = UIApplication.shared.delegate as! AppDelegate
            
            if (viewlblName.text?.isEmpty)! {
                
                viewBottom.removeFromSuperview()
            }else {
                appD.window?.addSubview(viewBottom)
                viewBottom.frame = CGRect.init(x: Int(self.view.frame.origin.x), y: Int(self.view.frame.size.height - self.viewBottom.frame.size.height), width: Int(self.view.frame.size.width), height: Int(self.viewBottom.frame.size.height))
            }
            
            arrayCount?[indexPath.row] = contact!
            
            rowArray[sectionArray[indexPath.section - 1]] = arrayCount

            
        }else {
            contact?["isSelect"] = "1"
            
            if (viewlblName.text?.isEmpty)! {
                viewlblName.text = contact?["name"]
            }else {
                viewlblName.text = viewlblName.text! + "," +  (contact?["name"])!
            }
            
            arrayCount?[indexPath.row] = contact!
            
            rowArray[sectionArray[indexPath.section - 1]] = arrayCount
            
            let appD = UIApplication.shared.delegate as! AppDelegate
            
            
            appD.window?.addSubview(viewBottom)
            viewBottom.frame = CGRect.init(x: Int(self.view.frame.origin.x), y: Int(self.view.frame.size.height - self.viewBottom.frame.size.height), width: Int(self.view.frame.size.width), height: Int(self.viewBottom.frame.size.height))
            
        }
    }
    
    
    tableView.reloadData();

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if section == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: "Header")! as UITableViewCell;
            header.backgroundColor = UIColor(red: (247/255.0), green: (247/255.0), blue: (247/255.0), alpha: 1);
            let cancelbtn = header.viewWithTag(101) as! UIButton
            let sharebtn = header.viewWithTag(102) as! UIButton
             let sectionlbl = header.viewWithTag(110) as! UILabel
            let sharebl = header.viewWithTag(109) as! UILabel

            
            
            cancelbtn.addTarget(self, action: #selector(CLShareViewController.cancel), for: .touchUpInside)
            sharebtn.addTarget(self, action: #selector(CLShareViewController.share), for: .touchUpInside)
            
            sectionlbl.isHidden = true;
            cancelbtn.isHidden = false
            sharebtn.isHidden = false
            sharebl.isHidden = false
            return header;
        }else {
            let header = tableView.dequeueReusableCell(withIdentifier: "Header")! as UITableViewCell;
            header.contentView.backgroundColor = UIColor.white
            header.backgroundColor = UIColor.white
            let cancelbtn = header.viewWithTag(101) as! UIButton
            let sharebtn = header.viewWithTag(102) as! UIButton
            let sectionlbl = header.viewWithTag(110) as! UILabel
            let sharebl = header.viewWithTag(109) as! UILabel
            
            cancelbtn.isHidden = true
            sharebtn.isHidden = true
            sharebl.isHidden = true
            sectionlbl.isHidden = false
            
            sectionlbl.text = sectionArray[section-1]
            
            
            
            let sepFrame = CGRect(x: 0, y: header.frame.size.height-3, width: UIScreen.main.bounds.size.width, height: 1)
            
            let separatorView = UIView(frame: sepFrame)
             separatorView.backgroundColor = UIColor.black
            header.addSubview(separatorView)
//            
//            CGRect sepFrame = CGRectMake(0, view.frame.size.height-1, 320, 1); UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame]; seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:1.0]; [header addSubview:seperatorView];
//            
            
            
            return header;
        }
    }
    
    @IBAction func ShareAction (sender : UIButton){
        self.share()
    }
    
    func share()
    {
        var userIds = [String]()
        
        for index in 0..<sectionArray.count
        {
            var arrayCount = rowArray[sectionArray[index]]
            print(arrayCount!)
            for indexInner in 0..<(arrayCount?.count)!
            {
                var contact = arrayCount?[indexInner]
                if (contact?["isSelect"]?.characters.count)! > 0 {
                    userIds.append((contact?["id"]!)!)
                }
            }
            print(userIds)
        }

        print(userIds)
        
        
//        self.startActivityIndicator()
        
        if(assetId != nil)
        {
            
            api.shareAsset(assetId: assetId!, userIds: userIds, success: { () -> Void in
                
                //            self.stopActivityIndicator()
            },
                           error: { (message: String?) -> Void in
                            
//                            
//                            if(message?.isEmpty)!
//                            {
//                                //                self.ShowError(string: "Content Not shared")
//                            }
//                            else
//                            {
//                                //                self.ShowError(string: "shared Response message:\(message)")
//                            }
//                            
//                            //            self.stopActivityIndicator()
//                            
//                            
            });
            
            self.dismiss(animated: false, completion: { () -> Void in
                //var alert = SCLAlertView(parent: self.view);
                //alert.showError("Oops", subTitle: "Your message was not successfully shared.", closeButtonTitle: "OK", duration: NSTimeInterval(3));
                //                 NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "AddShareButton"), object: nil)
            });

        }
            
        else
        {
            ShowError(string: "Unable to share content")
        }
    
//        self.dismiss(animated: false, completion: { () -> Void in
//            //var alert = SCLAlertView(parent: self.view);
//            //NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "AddShareButton"), object: nil)
//        });

    }

    


    
    func cancel() {
        self.dismiss(animated: false, completion: { () -> Void in
       //  NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "AddShareButton"), object: nil)
        
        });
    }
    
    @IBAction func findFriendAction(_ sender: Any){
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareViewToManageFriends"
        {
            let desView = segue.destination as! UINavigationController
            let profileView =  desView.viewControllers.first as! ProfileViewController
            profileView.isFromShareView = true
        }
    }
    
//    func startActivityIndicator()
//    {
//        DispatchQueue.main.async(execute:
//            {
//                let appD = UIApplication.shared.delegate as! AppDelegate
//                appD.window?.addSubview(self.activityIndicator)
//                //            self.view.addSubview(viewFindFriend)
//                self.activityIndicator.frame = CGRect.init(x: Int(self.view.frame.origin.x)/2, y:Int(self.view.frame.origin.y)/2, width: Int(self.activityIndicator.frame.width), height: Int(self.activityIndicator.frame.height) )
//                self.activityIndicator.isHidden = false
//                self.activityIndicator.startAnimating()
//            })
//      
//    }
//    
//    
//    func stopActivityIndicator()
//    {
//        DispatchQueue.main.async(execute:
//            {
//                self.activityIndicator.isHidden = true
//                self.activityIndicator.stopAnimating()
//                
//                self.activityIndicator.removeFromSuperview()
//            })
//    }
//    
    
    
}

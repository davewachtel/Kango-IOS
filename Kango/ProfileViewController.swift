//
//  ProfileViewController.swift
//  Kango
//
//  Created by waseem shah on 11/2/16.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

var attrs = [
    NSFontAttributeName : UIFont.systemFont(ofSize: 15.0),
    NSForegroundColorAttributeName : UIColor.black,
    NSUnderlineStyleAttributeName : 1] as [String : Any]



class ProfileViewController: UIViewController , UITextFieldDelegate ,UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate{
    @IBOutlet var txtFieldPhonenumber : UITextField!
    
    @IBOutlet var switchMain: UISegmentedControl!
    @IBOutlet var lblEmail : UILabel!
    
    @IBOutlet var switchNotifiaiton : UISwitch!
    
    var contactsStore: CNContactStore?
    
    let api = LoginApiController();
    
    @IBOutlet var tbleViewMain : UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var pageNumber = 0
    var totalRowsshow = 0
    var limit = 50
    
    var isMessageOpen : Bool = false
    var isAPICall : Bool = false
    
    var results                 : [CNContact] = []
    var mainarrayInvites        : Array<Dictionary<String,AnyObject>>  = Array()
    
    var mainarrayDummy          : Array<Dictionary<String,AnyObject>>  = Array()
    
    
    
    var arrayNumbers            = [String]()
    
    @IBOutlet var View_Friends : UIView!
    @IBOutlet var View_Friends_List : UIView!
    
    @IBOutlet var widthButton: NSLayoutConstraint!
    
    @IBOutlet var spinner: UIView!
    
    @IBOutlet var btnLogout: UIButton!
    
    var attributedString = NSMutableAttributedString(string:"")
    
    var isFromShareView: Bool = false
    
//    var isAllowNotificationForInbox =
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isFromShareView == true)
        {
            self.View_Friends.isHidden = false
            self.View_Friends_List.isHidden = false
        }
        else
        {
            self.View_Friends.isHidden = true
            self.View_Friends_List.isHidden = true
        }
        // Do any additional setup after loading the view.
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ProfileViewController.refresh), for: UIControlEvents.valueChanged)
        tbleViewMain.addSubview(refreshControl)
        
        let UserName =  (CLInstance.sharedInstance.authToken?.getUsername())! as String
        print(UserName)
    }

    
    func refresh() {
        // Code to refresh table view
        
        self.spinner.isHidden = false
        refreshControl.endRefreshing()
        pageNumber = 0
        totalRowsshow = 0
        mainarrayInvites.removeAll()
        self.tbleViewMain.reloadData()
        self.getContacts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (!isMessageOpen)
        {
            self.refresh()
            switchMain.selectedSegmentIndex = 0;
            self.Switch_Change(switchMain)
            self.spinner.isHidden = true
            let buttonTitleStr = NSMutableAttributedString(string:"LOGOUT", attributes:attrs)
            attributedString = buttonTitleStr
            btnLogout.setAttributedTitle(attributedString, for: .normal)
            
            self.View_Friends.isHidden = false
            
            txtFieldPhonenumber.delegate = self
            let item = UIBarButtonItem(image: UIImage(named: "burger"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.menu_lock));
            self.title = "Profile";
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = item;
            self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (255/255), green: (153/255), blue: 0, alpha: 1.0)
            
            
            let itemBack = UIBarButtonItem(image: UIImage(named: "backArrowNew"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.Back));
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = itemBack;
            
        }
        
        isMessageOpen = false
    }
    
    func Back(){
        //        Taponitem
        
        if(isFromShareView)
        {
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            (self.tabBarController as! CLTabBarController).sidebar.Taponitem(index: 0)
        }
    }
    
    func APICall() {
        let token =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        self.spinner.isHidden = false
        self.view.bringSubview(toFront: self.spinner)
        api.GettingProfile(username:token as NSString, success: { (data: NSDictionary) -> () in
            DispatchQueue.main.sync(execute: {
                self.spinner.isHidden = true
                self.txtFieldPhonenumber.text = ""
                self.txtFieldPhonenumber.isEnabled = true
                
                if (data["phonenumber"] as? String) != nil {
                    self.txtFieldPhonenumber.isEnabled = false
                    self.widthButton.constant = 0.0
                    self.txtFieldPhonenumber.text = data["phonenumber"] as? String
                    
                    self.txtFieldPhonenumber.RemoveLine()
                }else {
                    self.widthButton.constant = 30.0
                    self.txtFieldPhonenumber.DrawLine()
                }
                
                if  let isNotify = data["notification"] as? Bool {
                    
                    self.switchNotifiaiton.isOn = isNotify
                }
                
                self.lblEmail.text = data["email"] as? String
                
            });
            
            
        }, error:{ (message: String?) -> () in
            
            
            DispatchQueue.main.sync(execute: {
                
                self.spinner.isHidden = true
                if(message != nil){
                    self.ShowError(string: message!)
                }else {
                    self.ShowError(string: "Somthing gone wrong please try again")
                }
            });
        })
    }
    
    func ShowError(string : String) {
        self.spinner.isHidden = true
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func LOGOUT(sender : UIButton){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Logout"), object: nil)
    }
    
    func save()
    {
        
        let phoneString = txtFieldPhonenumber.text
        
        if txtFieldPhonenumber.isEnabled && (/*(phoneString?.characters.count)! > 0 ||*/ (phoneString?.characters.count)! < 10 ||  (phoneString?.characters.count)! > 10){
            self.ShowError(string: "Phone number must be 10 digits.")
            
        }else {
            
            self.spinner.isHidden = false
            
            txtFieldPhonenumber.resignFirstResponder()
            
            let token =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
            api.UpdateProfile(username:token as NSString,Phonenumber: phoneString! as NSString, noti:self.switchNotifiaiton.isOn , success: { (data: NSDictionary) -> () in
                
                DispatchQueue.main.sync(execute: {
                    self.spinner.isHidden = true
                    
                    if(self.txtFieldPhonenumber.text?.characters.count == 10){
                        self.txtFieldPhonenumber.isEnabled = false
                        self.txtFieldPhonenumber.RemoveLine()
                        self.widthButton.constant = 0.0
                    }
                });
                
                
            }, error:{ (message: String?) -> () in
                DispatchQueue.main.sync(execute: {
                    self.spinner.isHidden = true
                });
                
                if(message != nil){
                    self.ShowError(string: message!)
                }else {
                    self.ShowError(string: "Somthing gone wrong please try again")
                }
            })
        }
    }
    
    @IBAction func ChangeValue(_ sender: UISwitch) {
        self.save()
    }
    
    
    @IBAction func SaveValue(sender: UIButton) {
        self.save()
    }
    
    
    @IBAction func Switch_Change(_ sender: UISegmentedControl) {
        
        if (sender.selectedSegmentIndex == 1)
        {
            self.View_Friends.isHidden = true
            self.View_Friends_List.isHidden = true
            self.APICall()
        }else {
            if self.View_Friends.alpha == 0.0 {
                self.View_Friends_List.isHidden = false
                //                self.refresh()
                
            }else{
                self.View_Friends.isHidden = false
            }
        }
    }
    
    @IBAction func FindFriendsAction(_ sender: UIButton) {
        self.View_Friends_List.isHidden = false
        self.View_Friends.alpha = 0.0
//        self.refresh()
    }
    
    func getContacts() {
        self.spinner.isHidden = false
        
        
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (Bool, Error) in
                self.retrieveContactsWithStore(store: store)
            })
            
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }else if CNContactStore.authorizationStatus(for: .contacts) == .denied || CNContactStore.authorizationStatus(for: .contacts) == .restricted {
            self.spinner.isHidden = true
            
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
        arrayNumbers.removeAll()
        
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
        
        for i in 0 ..< self.results.count {
            let datadict = self.results[i]
            
            if (datadict.phoneNumbers.count > 0){
                let phonenumber = ((datadict.phoneNumbers[0].value).value(forKey: "digits") as? String)!
                arrayNumbers.append(phonenumber.digits)
            }
        }
        arrayNumbers = arrayNumbers.unique
//        arrayNumbers = Array( Set(arrayNumbers))
        
        if arrayNumbers.count > limit {
            self.CallAPI()
        }else {
            self.CheckFrindAPI(UserList: arrayNumbers as [NSString], completion: { () in
                
            });
        }
    }
    
    
    
    func CallAPI(){
        self.spinner.isHidden = false
        
        let startIndex = pageNumber * limit
        var EndIndex = (pageNumber + 1 ) * limit
        
        if EndIndex < arrayNumbers.count
        {
        
        
        
            let arrayNumbersRange = arrayNumbers[startIndex..<EndIndex]
            let someTagsArray: [NSString] = Array(arrayNumbersRange) as [NSString]
            self.CheckFrindAPI(UserList: someTagsArray as [NSString], completion: { () in
                        });
        }
        else
        {
            EndIndex = EndIndex - (EndIndex-arrayNumbers.count)
            
            if startIndex < EndIndex
            {
                let arrayNumbersRange = arrayNumbers[startIndex..<EndIndex]
                let someTagsArray: [NSString] = Array(arrayNumbersRange) as [NSString]
                self.CheckFrindAPI(UserList: someTagsArray as [NSString], completion: { () in
                });
            }
                
            else
            {
                self.spinner.isHidden = true
            }
        }
//        else
//        {
//              let arrayNumbersRange = arrayNumbers[startIndex..<EndIndex]
//
//        }
        
        
//        if(EndIndex < arrayNumbers.count)
//        {
//            let arrayNumbersRange = arrayNumbers[startIndex..<EndIndex]
//            
//            if (arrayNumbersRange.count < limit)
//            {
//                pageNumber = -1
//            }
//            
//            let someTagsArray: [NSString] = Array(arrayNumbersRange) as [NSString]
//            
//            self.CheckFrindAPI(UserList: someTagsArray as [NSString], completion: { () in
//                
//                
//            });
//            
//        }else {
//            
//            if (arrayNumbers.count <  startIndex)
//            {
//                startIndex = 0;
//                EndIndex = arrayNumbers.count
//            }else {
//                EndIndex = arrayNumbers.count
//            }
//            
//            
//            let arrayNumbersRange = arrayNumbers[startIndex..<EndIndex]
//            
//            if (arrayNumbersRange.count < limit)
//            {
//                pageNumber = -1
//            }
//            
//            let someTagsArray: [NSString] = Array(arrayNumbersRange) as [NSString]
//            
//            self.CheckFrindAPI(UserList: someTagsArray as [NSString], completion: { () in
//                
//                
//            });
//        }
        
        isAPICall = true
    }
    
    func CheckFrindAPI(UserList: [NSString], completion: @escaping () -> Void) {
        
        let Userfrom =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        api.checkFriend(User: Userfrom as NSString , UserList: UserList as [String],
                        success: {
                            (token: NSDictionary) -> () in
                            
            self.GetAllusers_success(token: token);
                           
            completion();
        },
                        error: {
                            (message: String?) -> () in
                            self.GetAllusers_failed(message: message);
                            completion();
        });
        
    }
    
    func GetAllusers_success(token: NSDictionary) -> Void
    {
        
        let allUsers : Array = token["phone"] as! Array<AnyObject>
        
        if (pageNumber == 0){
            self.mainarrayInvites.removeAll()
//            self.mainarrayUsers.removeAll()
        }
        
        
        for index in 0 ..< allUsers.count
        {
            let userDict = allUsers[index] as! Dictionary<String,AnyObject>
            
//            if((userDict["staus"] as! String) == "No User"){
                self.mainarrayInvites.append(userDict)
//            }else {
//                self.mainarrayUsers.append(userDict)
//            }
        }
        for index in 0 ..< self.mainarrayInvites.count {
            var userDict = self.mainarrayInvites[index]
            let phonenumber = userDict["phone"] as! String
            
            for i in 0 ..< self.results.count {
                let datadict = self.results[i]
                
                if (datadict.phoneNumbers.count > 0){
                    let Number = (datadict.phoneNumbers[0].value ).value(forKey: "digits") as? String
                    if Number?.digits == phonenumber {
                        userDict["Result"] = (datadict.givenName + " " + datadict.familyName) as AnyObject?
                        break
                    }
                }
            }
            self.mainarrayInvites[index] = userDict
            
        }
        
//        for index in 0 ..< self.mainarrayUsers.count {
//            var userDict = self.mainarrayUsers[index]
//            let phonenumber = userDict["phone"] as! String
//            
//            for i in 0 ..< self.results.count {
//                let datadict = self.results[i]
//                
//                if (datadict.phoneNumbers.count > 0){
//                    let Number = (datadict.phoneNumbers[0].value ).value(forKey: "digits") as! String
//                    if Number.digits == phonenumber {
//                        userDict["Result"] = (datadict.givenName + " " + datadict.familyName) as AnyObject?
//                        break
//                    }
//                }
//            }
//            
//            self.mainarrayUsers[index] = userDict
//        }
//        
        
//        mainarrayDummy.removeAll()
//        for index in 0..<self.mainarrayUsers.count{
//            let objArray = mainarrayUsers[index]
//            
//            var isfound = false
//            
//            for indexInner in 0..<self.mainarrayDummy.count{
//                let objInner = mainarrayDummy[indexInner]
//                if ((objInner["phone"] as? String) == (objArray["phone"] as? String) )
//                {
//                    isfound = true
//                    break
//                }
//            }
//            
//            if !isfound {
//                mainarrayDummy.append(objArray)
//                
//            }
//        }
//        
//        mainarrayUsers = mainarrayDummy
//        
//        mainarrayUsers.sort {
//            item1, item2 in
//            let date1 = item1["Result"] as! String
//            let date2 = item2["Result"] as! String
//            return date1.compare(date2) == ComparisonResult.orderedAscending
//        }
//        
        mainarrayDummy.removeAll()
        for index in 0..<self.mainarrayInvites.count{
            let objArray = mainarrayInvites[index]
            
            var isfound = false
            
            for indexInner in 0..<self.mainarrayDummy.count{
                let objInner = mainarrayDummy[indexInner]
                if ((objInner["phone"] as? String) == (objArray["phone"] as? String) )
                {
                    isfound = true
                    break
                }
            }
            
            if !isfound {
                mainarrayDummy.append(objArray)
                
            }
        }
        
        mainarrayInvites = mainarrayDummy
        mainarrayInvites.sort {
            item1, item2 in
            let date1 = item1["Result"] as! String
            let date2 = item2["Result"] as! String
            return date1.compare(date2) == ComparisonResult.orderedAscending
        }
        
        
//        if (allUsers.count < limit)
//        {
//            pageNumber = -1
//        }
        
        DispatchQueue.main.sync(execute: {
            tbleViewMain.reloadData()
            isAPICall = false
            self.spinner.isHidden = true
            if (pageNumber >= 0)
            {
                pageNumber += 1
            }
            
        });
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        switch section {
//        case 0:
//            return 0
//            
//        case 1 :
//            
//            return 45
//            
//        default :
//            return 0
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        if (section == 0)
//        {
//            return mainarrayUsers.count
//        }else {
            return mainarrayInvites.count
//        }
        
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if (section == 0)
//        {
//            return ""
//        }else {
//            return "Spread the Word"
//        }
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (mainarrayInvites.count > 0 && pageNumber > 0)
//        {
        
            
//        }else {
//            totalRowsshow = mainarrayUsers.count - 1
//        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCC") as! FindFriendsCC

            let dict = mainarrayInvites[indexPath.row]
        
            if (dict["Result"] as! String?)?.trimmingCharacters(in: .whitespaces).isEmpty == false
            {
                cell.lblUserName.text = dict["Result"] as! String?
            }
            else
            {
                cell.lblUserName.text = "No Name"
            }
        
            cell.btnAdd.tag = indexPath.row
        
        
        if  (dict["staus"] as! String) == "User" {
            
            cell.btnAdd.removeTarget(nil, action:nil, for: .touchUpInside)
            cell.btnAdd.addTarget(self, action: #selector(ProfileViewController.AddFriendsForUser), for: UIControlEvents.touchUpInside)
            cell.btnAdd.setImage(UIImage.init(named: "AddButton"), for: .normal)
            cell.appUserLogo.isHidden = false
            
        }
        else if (dict["staus"] as! String) == "Friend" {
         
            cell.btnAdd.setImage(UIImage.init(named: "RemoveButton"), for: .normal)
            cell.btnAdd.removeTarget(nil, action:nil, for: .touchUpInside)
            cell.btnAdd.addTarget(self, action: #selector(ProfileViewController.AddFriendsForUser), for: UIControlEvents.touchUpInside)
            cell.appUserLogo.isHidden = false
        }
        else
        {
            cell.appUserLogo.isHidden = true
            cell.btnAdd.setImage(UIImage.init(named: "InviteButton"), for: .normal)
            cell.btnAdd.removeTarget(nil, action:nil, for: .touchUpInside)
            cell.btnAdd.addTarget(self, action: #selector(ProfileViewController.AddFriends), for: UIControlEvents.touchUpInside)
        }

        
        totalRowsshow = mainarrayInvites.count - 1
        
        if (mainarrayInvites.count - 1) == indexPath.row        {
            if (mainarrayInvites.count < arrayNumbers.count){
                if (!isAPICall) {
                    
                            self.CallAPI()
                }
            }
        }
    
        return cell
    }
    
    func AddFriendsForUser(sender : UIButton) {
        let dict = mainarrayInvites[sender.tag]
        
        if  (dict["staus"] as! String) == "User"{
            self.AddFriend(sender: sender, Userto: dict["user_id"] as! NSString)
        }else if(dict["staus"] as! String) == "Friend"{
            self.RemoveFriend(sender: sender, Userto: dict["user_id"] as! NSString)
        }
        
    }
    
    func RemoveFriend(sender : UIButton, Userto: NSString) {
        self.spinner.isHidden = false
        let Userfrom =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        
        self.RemoveFrindAPI(sender: sender, Userto: Userto, Userfrom: Userfrom as NSString, completion: { () in
            
        });
    }
    func RemoveFrindAPI(sender : UIButton, Userto: NSString, Userfrom: NSString, completion: @escaping () -> Void) {
        
        api.RemoveFriend(Userto: Userto, Userfrom: Userfrom,
                         success: {
                            (token: NSDictionary) -> () in
                            DispatchQueue.main.sync(execute: {
                                self.mainarrayInvites[sender.tag]["staus"] = "User" as AnyObject?
                                sender.setImage(UIImage.init(named: "AddButton"), for: .normal)
                                sender.removeTarget(nil, action:nil, for: .touchUpInside)
                                sender.addTarget(self, action: #selector(ProfileViewController.AddFriendsForUser), for: UIControlEvents.touchUpInside)
                                self.tbleViewMain.reloadData()
                                self.spinner.isHidden = true

                            });
                            completion();
                            
        },
                         error: {
                            (message: String?) -> () in
                            DispatchQueue.main.sync(execute: {
                                self.spinner.isHidden = true
                            });
                            self.GetAllusers_failed(message: message);
                            completion();
        });
        
    }
    
    func AddFriends(sender : UIButton) {
        let dict = mainarrayInvites[sender.tag]
        
        self.sendMEssage(phonenumber: dict["phone"] as! NSString)
    }
    
    func AddFriend(sender: UIButton,Userto: NSString) {
        self.spinner.isHidden = false
        let Userfrom =  (CLInstance.sharedInstance.authToken?.getUserId())! as String
        
        self.AddFrindAPI(sender: sender, Userto: Userto, Userfrom: Userfrom as NSString, completion: { () in
            
            
        });
    }
    
    func AddFrindAPI(sender: UIButton, Userto: NSString, Userfrom: NSString, completion: @escaping () -> Void) {
        
        api.AddFriend(Userto: Userto, Userfrom: Userfrom,
                      success: {
                        (token: NSDictionary) -> () in
                        DispatchQueue.main.sync(execute: {
                 

                            self.mainarrayInvites[sender.tag]["staus"] = "Friend" as AnyObject?
                            sender.setImage(UIImage.init(named: "RemoveButton"), for: .normal)
                            sender.removeTarget(nil, action:nil, for: .touchUpInside)
                            sender.addTarget(self, action: #selector(ProfileViewController.AddFriendsForUser), for: UIControlEvents.touchUpInside)
                            self.tbleViewMain.reloadData()
                            self.spinner.isHidden = true
                        });
                        completion();
                        
        },
                      error: {
                        (message: String?) -> () in
                        DispatchQueue.main.sync(execute: {
                            self.spinner.isHidden = true
                        });
                        self.GetAllusers_failed(message: message);
                        completion();
        });
    }
    
    func sendMEssage(phonenumber : NSString){
        
//        let UserName =  (CLInstance.sharedInstance.authToken?.getUsername())! as String
        
        
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            

//            controller.body = UserName + "\nThis is kango message. https://itunes.apple.com/pk/genre/ios/id36?mt=8"
            controller.body = "Come discover something awesome on Kango!\nhttps://itunes.apple.com/us/app/kango/id972935984"
            
//            controller.body = attributedString
            controller.recipients = [phonenumber as String]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
            isMessageOpen = true
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    func GetAllusers_failed(message: String?) -> Void
    {
        
        var msg: String = "Please try again.";
        DispatchQueue.main.sync(execute: {
            self.tbleViewMain.reloadData()
            self.spinner.isHidden = true
        });
        if(message != nil)
        {
            msg = message!;
            ShowError(string: msg)
        }
        

    }
    
}


extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

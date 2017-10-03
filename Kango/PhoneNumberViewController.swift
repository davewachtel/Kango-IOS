//
//  PhoneNumberViewController.swift
//  Kango
//
//  Created by Taimoor Ali on 25/10/2016.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit
import Contacts

@available(iOS 9.0, *)

class PhoneNumberViewController: UIViewController {
    @IBOutlet var txtFieldPhonenumber : UITextField!
    
    let api = LoginApiController();
    
    @IBOutlet var HeightError: NSLayoutConstraint!
    
    var Password = String()
    var UserEmail = String()
    @IBOutlet var spinner: UIView!
    
    @IBOutlet weak var btnCross: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtFieldPhonenumber.text = ""
        txtFieldPhonenumber.DrawLine()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.spinner.isHidden = true
        self.btnCross.isHidden = true
        HeightError.constant = 0.0
//        self.getContacts()
        self.CustomAccessoryView()
        txtFieldPhonenumber.becomeFirstResponder()
    }

   
    
    func CustomAccessoryView(){
        
        let viewAccery : UIView!
        viewAccery = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        viewAccery.backgroundColor = UIColor.red
        viewAccery.layer.borderColor = UIColor.black.cgColor
        viewAccery.layer.borderWidth = 1.0
        
        let buttonDone   = UIButton(type: .custom) as UIButton
        buttonDone.frame = CGRect(x: 0, y: 0,width: self.view.frame.size.width , height: 50)
        buttonDone.backgroundColor = UIColor(red: 0.6627, green: 0.8078, blue: 0.2156, alpha: 1.0)
        buttonDone.setTitle("Continue", for: UIControlState())
        buttonDone.addTarget(self, action: #selector(SignupEmailViewController.DoneAction(sender:)), for: .touchUpInside)
        
        viewAccery.addSubview(buttonDone)
        
        txtFieldPhonenumber.inputAccessoryView = viewAccery
    }

     func DoneAction(sender : UIButton){
        self.CAllSignUPAPI(isSkip: false)
    }
    
    
    func CAllSignUPAPI(isSkip : Bool )  {
        
        var phonenumber = ""
        
        
        if(!isSkip)
        {
            phonenumber = txtFieldPhonenumber.text!
        }
            
        
        txtFieldPhonenumber.resignFirstResponder()
        if((txtFieldPhonenumber.text?.characters.count)! != 10 && !isSkip)
        {
            phonenumber = txtFieldPhonenumber.text!
            
            HeightError.constant = 25.0
            self.btnCross.isHidden = false
        }else {
            self.spinner.isHidden = false
            self.view.bringSubview(toFront: self.spinner)
            api.Signup(username: self.UserEmail as NSString, Phonenumber: phonenumber as NSString, password: self.Password as NSString, success: { (token: NSDictionary) -> () in
                print(token)
                self.authenticate(username: self.UserEmail, password: self.Password, completion: {
                    
                })
            }, error: {
                (message: String?) -> () in
                
            
                DispatchQueue.main.sync(execute: {
                    
                    if message != nil{
                        self.ShowError(string: message!)
                    }else {
                       self.ShowError(string: "Something went wrong. Please Try again.")
                    }
                    self.spinner.isHidden = true
                });
                
            })

        }
        
        
    }
    
   
    
    func ShowError(string : String) {
        let alertController = UIAlertController(title: "Error", message: string, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
    }
    
    func authenticate(username: String, password: String, completion: @escaping () -> Void) {
        
        api.login(username: username as NSString
            , password: password as NSString
            , success: {
                (token: Token) -> () in
                self.login_success(token: token);
                completion();
                
            },
              error: {
                (message: String?) -> () in
                self.login_failed(message: message);
                completion();
        });
    }

    func login_success(token: Token) -> Void
    {
        _ = token.saveToken();
        CLInstance.sharedInstance.authToken = token;
        
        DispatchQueue.main.sync(execute: {
            self.spinner.isHidden = true
        });

        
        if(Thread.isMainThread)
        {
            self.performSegue(withIdentifier: "LoginSuccessSegue", sender: self);
        }
        else
        {
            DispatchQueue.main.sync(execute: {
                self.performSegue(withIdentifier: "LoginSuccessSegue", sender: self);
            });
        }
        
    }
    
    func login_failed(message: String?) -> Void
    {
        DispatchQueue.main.sync(execute: {
            self.spinner.isHidden = true
        });

        var msg: String = "";
        if(message != nil)
        {
            msg = message!;
        }else {
            msg = "Somthing gone wrong please try again"
        }
        
        DispatchQueue.main.sync(execute: {
            self.ShowError(string: msg)
            
        });
    }
    
    @IBAction func SkipFunction(sender : UIButton){
        self.CAllSignUPAPI(isSkip: true)
    }
    
    @IBAction func RemoveTextfield(sender : UIButton)
    {
        print("Call Back BTn")
        self.txtFieldPhonenumber.text = ""
        self.btnCross.isHidden = true
        
    }
    
}

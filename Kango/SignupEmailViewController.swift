//
//  SignupEmailViewController.swift
//  Kango
//
//  Created by Taimoor Ali on 24/10/2016.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit

class SignupEmailViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet var lblError : UILabel!
    @IBOutlet var spinner: UIView!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet var txtFieldName : UITextField!
    
    @IBOutlet weak var btnCross: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.spinner.isHidden = true
        lblError.isHidden = true
        height.constant = 0;
        btnCross.isHidden = true
        self.CustomAccessoryView()
        txtFieldName.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtFieldName.text = ""
        txtFieldName.DrawLine()
        
    }
    
    //MARK: Set Custom Buttons
    
    func CustomAccessoryView(){
        
        let viewAccery : UIView!
        viewAccery = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        viewAccery.backgroundColor = UIColor.red
        viewAccery.layer.borderColor = UIColor.black.cgColor
        viewAccery.layer.borderWidth = 1.0
        
        let buttonDone   = UIButton(type: .custom) as UIButton
        buttonDone.frame = CGRect(x: 0, y: 0,width: self.view.frame.size.width , height: 50)
        buttonDone.backgroundColor = UIColor(red: 0.6627, green: 0.8078, blue: 0.2156, alpha: 1.0)
        buttonDone.setTitle("CONTINUE", for: UIControlState())
        buttonDone.addTarget(self, action: #selector(SignupEmailViewController.DoneAction(sender:)), for: .touchUpInside)
        
        viewAccery.addSubview(buttonDone)
        
        txtFieldName.inputAccessoryView = viewAccery
    }
    
   @IBAction func BackBtn(sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func DoneAction(sender : UIButton){
        
//         self.txtFieldName.text = "dave.wachtel@gmail.com"
//        self.txtFieldName.text = "waseem.shah@purelogics.net"
        
        let objCommonClass = CommonClass()
        txtFieldName.resignFirstResponder()
        if txtFieldName.text?.characters.count == 0 || !objCommonClass.isValidEmail(txtFieldName.text as String!){
            lblError.isHidden = false
            lblError.text = "Please enter a valid email address"
            height.constant = 25
            self.btnCross.isHidden = false
            return
        }
    
        let api = LoginApiController();
       
        self.spinner.isHidden = false
        self.view.bringSubview(toFront: self.spinner)
        api.CheckEmail(email: txtFieldName.text! , success: {
            (token: NSDictionary) -> () in
            
            print(token)
            
                DispatchQueue.main.sync(execute: {
                    self.spinner.isHidden = true
                _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SignupEmailViewController.PushNewView), userInfo: nil, repeats: false)
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
    
    func PushNewView() {
        let SignupPasswordVc  = self.storyboard?.instantiateViewController(withIdentifier: "SignupPasswordViewController") as! SignupPasswordViewController
        SignupPasswordVc.UserEmail = self.txtFieldName.text!
        self.navigationController?.pushViewController(SignupPasswordVc, animated: true)

    }
    
    func ShowError(string : String) {
        DispatchQueue.main.sync(execute: {
            self.btnCross.isHidden = false
            self.spinner.isHidden = true
            
            lblError.isHidden = false
            lblError.text = "Email address is already in use."
            height.constant = 25

            
        })
    }
    
    
    @IBAction func RemoveTextfield(sender : UIButton)
    {
        print("Call Back BTn")
        txtFieldName.text = ""
        self.btnCross.isHidden = true
        
    }
}

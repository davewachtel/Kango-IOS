//
//  CLLoginView.swift
//  Kango
//
//  Created by James Majidian on 11/15/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

import Foundation

class CLLoginView : UIView ,UITextFieldDelegate
{
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var spinner: UIView!
    
    @IBOutlet weak var btnCross: UIButton!
    
    @IBOutlet weak var heightError: NSLayoutConstraint!
    
    var delegate: CLLoginViewDelegate!;
    
    @IBAction func buttonTapped(_: AnyObject) {
        
//        if txtPassword.text?.characters.count == 0 {
//            txtUsername.text = "dave.wachtel@gmail.com"
//            txtPassword.text = "ski123"
//        }
        
        

//        txtUsername.text = "test5@test.com"
//        txtPassword.text = "12345678"

        
        if (txtUsername.text?.characters.count == 0 || txtPassword.text?.characters.count == 0){
         
            self.delegate.ShowError(string: "Email and Password are required to login.",heading: "Oops")
            return ;
            
        }
                    
        spinner.isHidden = false
         self.bringSubview(toFront: self.spinner)
        

        self.delegate.authenticate(username: txtUsername.text!, password: txtPassword.text!, completion: { () in
            
            DispatchQueue.main.sync(execute: {
                self.spinner.isHidden = true
            });
            
        });
    }
    
    @IBAction func BackBtn(sender : UIButton)
    {
        print("Call Back BTn")
        self.delegate.BackBTn()
    }
    
    func CustomAccessoryView(textField : UITextField){
        
        let viewAccery : UIView!
        viewAccery = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 50))
        viewAccery.backgroundColor = UIColor.red
        viewAccery.layer.borderColor = UIColor.black.cgColor
        viewAccery.layer.borderWidth = 1.0
        
        let buttonDone   = UIButton(type: .custom) as UIButton
        buttonDone.frame = CGRect(x: 0, y: 0,width: self.frame.size.width , height: 50)
        buttonDone.backgroundColor = UIColor(red: 0.6627, green: 0.8078, blue: 0.2156, alpha: 1.0)
        buttonDone.setTitle("SIGN IN", for: UIControlState())
        buttonDone.addTarget(self, action: #selector(SignupEmailViewController.DoneAction(sender:)), for: .touchUpInside)
        
        viewAccery.addSubview(buttonDone)
        
        textField.inputAccessoryView = viewAccery
    }

    func DoneAction(sender : UIButton){
        self.txtPassword.resignFirstResponder()
        self.txtUsername.resignFirstResponder()
        self.buttonTapped(sender)
        
    }
    
    @IBAction func RemoveTextfield(sender : UIButton)
    {
        print("Call Back BTn")
        txtPassword.text = ""
        self.btnCross.isHidden = true
        self.CustomAccessoryView(textField: self.txtPassword)
        self.CustomAccessoryView(textField: self.txtUsername)
        self.txtUsername.reloadInputViews()
        self.txtPassword.reloadInputViews()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !self.btnCross.isHidden {
            self.CustomAccessoryView(textField: self.txtPassword)
            self.CustomAccessoryView(textField: self.txtUsername)
            self.txtUsername.reloadInputViews()
            self.txtPassword.reloadInputViews()
            
        }
        
        return true
    }
    
    
}

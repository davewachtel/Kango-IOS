//
//  SignupPasswordViewController.swift
//  Kango
//
//  Created by Taimoor Ali on 25/10/2016.
//  Copyright © 2016 Cornice Labs. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class SignupPasswordViewController: UIViewController {
    @IBOutlet var lblError : UILabel!
    
    @IBOutlet var txtFieldPassword : UITextField!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    @IBOutlet weak var btnCross: UIButton!
    
    var UserEmail = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtFieldPassword.text = ""
        txtFieldPassword.DrawLine()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.btnCross.isHidden = true
        lblError.isHidden = true
        height.constant = 0;
        self.CustomAccessoryView()
        txtFieldPassword.becomeFirstResponder()
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
        buttonDone.setTitle("SIGNUP", for: UIControlState())
        buttonDone.addTarget(self, action: #selector(SignupEmailViewController.DoneAction(sender:)), for: .touchUpInside)
        
        viewAccery.addSubview(buttonDone)
        
        txtFieldPassword.inputAccessoryView = viewAccery
    }

    func DoneAction(sender : UIButton){
        
        
        if ((txtFieldPassword.text?.characters.count)! < 8)
        {
            lblError.isHidden = false
            height.constant = 25;
            self.btnCross.isHidden = false
        }else {
            lblError.isHidden = true
            height.constant = 0;
            
            let phonenumberVc  = self.storyboard?.instantiateViewController(withIdentifier: "PhoneNumberViewController") as! PhoneNumberViewController
            phonenumberVc.UserEmail = self.UserEmail
            phonenumberVc.Password = txtFieldPassword.text!
            self.navigationController?.pushViewController(phonenumberVc, animated: true)
            
        }
    }

    
    @IBAction func RemoveTextfield(sender : UIButton)
    {
        print("Call Back BTn")
        txtFieldPassword.text = ""
        self.btnCross.isHidden = true
        
    }
    
}

//
//  UIDViewController.swift
//  CableModemScanner
//
//  Created by Sheik Tajudeen  on 12/15/16.
//  Copyright © 2016 Sheik Tajudeen . All rights reserved.
//

import UIKit

class UIDViewController: UIViewController {
    
    var accountNumber = ""

    @IBOutlet var btnCreateUserID: UIButton!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var txtCaptcha: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtCPwd: UITextField!
    @IBOutlet var txtPwd: UITextField!
    @IBOutlet var txtUname: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        print("inside UID")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @IBAction func CreateUserID(_ sender: Any) {
        lblStatus.text = "User id creation successful"
        txtCaptcha.isEnabled = false
        txtEmail.isEnabled = false
        txtCPwd.isEnabled = false
        txtPwd.isEnabled = false
        txtUname.isEnabled = false
        btnCreateUserID.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationSvc = segue.destination
        if destinationSvc is ActivationViewController{
            if segue.identifier == "CreateUID"{
                print("redirect to act controller")
                
            }
        }
        
    }

}

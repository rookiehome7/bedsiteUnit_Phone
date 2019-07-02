//
//  SettingViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//  Copyright © 2562 WiAdvance. All rights reserved.
//

import Foundation

import UIKit
import os.log

class SettingViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var serverAddressField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create LocalUser Data Class
        let accountData = LocalUserData()
        // Get the User setting data
        let account = accountData.getSipUsername()
        let password = accountData.getSipPassword()
        let domain = accountData.getSipDomain()
        usernameField.text = account
        passwordField.text = password
        serverAddressField.text = domain
        
        // Do any additional setup after loading the view.
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

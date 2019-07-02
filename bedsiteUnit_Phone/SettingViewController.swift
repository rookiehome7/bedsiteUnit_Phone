//
//  SettingViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai on 27/6/19.
//

import UIKit
import os.log

class SettingViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
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
    
    
    // MARK: - Navigation
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }


    
    

}

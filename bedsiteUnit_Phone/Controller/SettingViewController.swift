//
//  SettingViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//

import Foundation
import UIKit
import os.log

class SettingViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var sipServerIpField: UITextField!
    @IBOutlet weak var sipServerPort: UITextField!
    
    @IBOutlet weak var mqttServerIpField: UITextField!
    @IBOutlet weak var mqttServerPort: UITextField!
    @IBOutlet weak var mqttTopicField: UITextField!
    
    var linphoneManager: LinphoneManager?
    var viewController : ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create Local User Data Class
        let accountData = LocalUserData()
        // Get the User setting data
        usernameField.text = accountData.getSipUsername()
        passwordField.text = accountData.getSipPassword()
        sipServerIpField.text = accountData.getSipServerIp()
        sipServerPort.text = accountData.getSipServerPort()
        
        mqttServerIpField.text = accountData.getMQTTServerIp()
        mqttServerPort.text = accountData.getMQTTServerPort()
        mqttTopicField.text = accountData.getMQTTTopic()
    }
    
    //MARK: Navigation
    @IBAction func saveButton(_ sender: Any) {
        // SIP Setting
        UserDefaults.standard.set(usernameField.text, forKey: "sipaccount")
        UserDefaults.standard.set(passwordField.text, forKey: "sippassword")
        UserDefaults.standard.set(sipServerIpField.text, forKey: "sipserverip")
        UserDefaults.standard.set(sipServerPort.text, forKey: "sipserverport")
        //MQTT Setting
        UserDefaults.standard.set(mqttServerIpField.text, forKey: "mqttserverip")
        UserDefaults.standard.set(mqttServerPort.text, forKey: "mqttserverport")
        UserDefaults.standard.set(mqttTopicField.text, forKey: "mqttsubscribetopic")
        
        // Restart with new setting Linphone Service
        self.linphoneManager = LinphoneManager()
        linphoneManager?.restartService()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

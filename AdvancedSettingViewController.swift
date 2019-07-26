//
//  AdvancedSettingViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 25/7/2562 BE.
//  Copyright © 2562 WiAdvance. All rights reserved.
//

import UIKit

class AdvancedSettingViewController: UIViewController {
    
    @IBOutlet weak var mqttIpAddress: UITextField!
    @IBOutlet weak var mqttPort: UITextField!
    @IBOutlet weak var mqttTopic: UITextField!
    @IBOutlet weak var mqttUsername: UITextField!
    @IBOutlet weak var mqttPassword: UITextField!
    
    @IBOutlet weak var sipIpAddress: UITextField!
    @IBOutlet weak var sipPort: UITextField!
    @IBOutlet weak var sipUsername: UITextField!
    @IBOutlet weak var sipPassword: UITextField!

    @IBOutlet weak var beaconUUID: UITextField!
    @IBOutlet weak var beaconMajor: UITextField!
    @IBOutlet weak var beaconMinor: UITextField!
    
    var linphoneManager: LinphoneManager?
    var viewController : ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let accountData = LocalUserData()
        
        mqttIpAddress.text = accountData.getMQTTServerIp()
        mqttPort.text = accountData.getMQTTServerPort()
        mqttTopic.text = accountData.getMQTTTopic()
        mqttUsername.text = accountData.getMQTTUsername()
        mqttPassword.text = accountData.getMQTTPassword()
        
        sipIpAddress.text = accountData.getSipServerIp()
        sipPort.text = accountData.getSipServerPort()
        sipUsername.text = accountData.getSipUsername()
        sipPassword.text = accountData.getSipPassword()
        
        beaconUUID.text = accountData.getBeaconUUID()
        beaconMajor.text = accountData.getBeaconMajor()
        beaconMinor.text = accountData.getBeaconMinor()
        
    }
    @IBAction func saveButton(_ sender: Any) {
        //MQTT Setting
        UserDefaults.standard.set(mqttIpAddress.text, forKey: "mqttserverip")
        UserDefaults.standard.set(mqttPort.text, forKey: "mqttserverport")
        UserDefaults.standard.set(mqttTopic.text, forKey: "mqttsubscribetopic")
        UserDefaults.standard.set(mqttUsername.text, forKey: "mqttusername")
        UserDefaults.standard.set(mqttPassword.text, forKey: "mqttpassword")
        // SIP Setting
        UserDefaults.standard.set(sipIpAddress.text, forKey: "sipserverip")
        UserDefaults.standard.set(sipPort.text, forKey: "sipserverport")
        UserDefaults.standard.set(sipUsername.text, forKey: "sipusername")
        UserDefaults.standard.set(sipPassword.text, forKey: "sippassword")
        //Beacon
        UserDefaults.standard.set(beaconUUID.text, forKey: "beaconuuid")
        UserDefaults.standard.set(beaconMajor.text, forKey: "beaconmajor")
        UserDefaults.standard.set(beaconMinor.text, forKey: "beaconminor")
        // Restart with new setting Linphone Service
        self.linphoneManager = LinphoneManager()
        linphoneManager?.restartService()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

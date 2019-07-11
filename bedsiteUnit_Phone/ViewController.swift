//
//  ViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//
import UIKit
import CocoaMQTT

struct ViewVT{
        static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}

class ViewController: UIViewController {
    // User Label
    @IBOutlet weak var mqttTopic: UILabel!
    @IBOutlet weak var mqttStatus: UILabel!
    @IBOutlet weak var mqttMessage: UILabel!
    @IBOutlet weak var sipStatus: UILabel!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    
    // User Button name
    @IBOutlet weak var mqttReconnectButton: UIButton!

    // Variable decrelation
    var mqtt: CocoaMQTT?
    let accountData = LocalUserData() // Get function read file from PLIST
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UI Setting
        mqttReconnectButton.isHidden = false
        mqttMessage.isHidden = true
    
        updateUIStatus()
        
        //Run MQTT on mac: /usr/local/sbin/mosquitto -c /usr/local/etc/mosquitto/mosquitto.conf
        mqttSetting()       // Setting MQTT
        _ = mqtt!.connect() // MQTT Connect'
        
        //UPDATE UI every 2 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateUIStatus()
        }
    }
    
    // Function to update UI
    func updateUIStatus(){
        mqttTopic.text = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!
        
        if sipRegistrationStatus == .fail {
            sipStatus.text = "FAIL"
        }
        else if sipRegistrationStatus == .unknown {
            sipStatus.text = "Unknown"
        }
        else if sipRegistrationStatus ==  .ok {
            sipStatus.text = "OK"
        }
        else if sipRegistrationStatus == .unregister{
            sipStatus.text = "Not Register"
        }
        else if sipRegistrationStatus == .progress{
            sipStatus.text = "Progress"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : Action
    @IBAction func mqttReconnectButton(_ sender: Any) {
        _ = mqtt!.connect()
        mqttTopic.text = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!
    }

    override func viewWillAppear(_ animated: Bool) {
        // Reset after view appear
        _ = mqtt?.disconnect()
        mqttSetting()
        _ = mqtt?.connect()
        mqttTopic.text! = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    // Send phone number  to OutgoingCallViewController
    // Identifier : makeCall
    // Get number from text field
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeCall"
        {
            if let destinationVC = segue.destination as? OutgoingCallViewController {
                destinationVC.phoneNumber = phoneNumberField.text
            }
        }
    }
}


// Cocoa MQTT - View Controller Extension Part
// This extension will handle all MQTT function
extension ViewController: CocoaMQTTDelegate {
    
    func makeCall(phoneNumber : String){
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OutgoingCallViewController") as? OutgoingCallViewController
        vc!.phoneNumber = phoneNumber
        //self.navigationController?.pushViewController(vc!, animated: true)
        self.present(vc!, animated: true, completion: nil)
    }
    
    func terminateCall(){
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            let result = linphone_core_terminate_call(theLinphone.lc!, call)
            NSLog("Terminated call result(outgoing): \(result)")
        }
        OutgoingCallViewData.controller?.dismiss(animated: false, completion: nil)
    }
    
    //MARK : SETTING Environment
    func mqttSetting() {
        // Get MQTT Broker IP from PLIST File
        let brokerIP = accountData.getMQTTServerIp()!
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: brokerIP, port: 1883)
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
    }
    
    //MARK : MQTT Command handle
    // When received message
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.string.description), id: \(id)")
        mqttMessage.isHidden = false
        mqttMessage.text = message.string?.description
        let command = message.string!.components(separatedBy: " ")
        if command[0] == "call" {
            makeCall(phoneNumber: command[1])
        }
        else if command[0] == "end" {
            terminateCall()
        }
    }
    
    // When MQTT Server Connect
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        if ack == .accept {
            mqttReconnectButton.isHidden = true
            // Get MQTT Broker Topic from PLIST File
            let mqttTopic = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!
            mqtt.subscribe(mqttTopic, qos: CocoaMQTTQOS.qos2)
            mqttStatus.text = "Connected " + accountData.getMQTTServerIp()!
        }
    }
    
    // When MQTT Server Disconnect
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.debugDescription)")
        mqttReconnectButton.isHidden = false
        mqttStatus.text = "Disconnect"
        // Try to disconnect every 5 seconds when MQTT server Disconnect
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            _ = mqtt.connect()
        }
    }
    

    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        TRACE("trust: \(trust)")
        completionHandler(true)
    }
    
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.string.description), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        TRACE("topics: \(topics)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        TRACE("topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    

}

extension ViewController {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }
        print("[TRACE] [\(prettyName)]: \(message)")
    }
}

extension Optional {
    // Unwarp optional value for printing log only
    var description: String {
        if let warped = self {
            return "\(warped)"
        }
        return ""
    }
}




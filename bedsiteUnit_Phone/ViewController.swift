//
//  ViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//
import UIKit
import CocoaMQTT

class ViewController: UIViewController {
    let defaultHost = "localhost"
    var mqtt: CocoaMQTT?
    let accountData = LocalUserData()
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var mqttStatus: UILabel!
    @IBOutlet weak var sipStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        mqttStatus.text = "Disconnect"
        sipStatus.text = "Unknown"
        // Setting MQTT
        
        // How to run MQTT broker in MACOS
        // /usr/local/sbin/mosquitto -c /usr/local/etc/mosquitto/mosquitto.conf
        mqttSetting()
        
        // MQTT Connect
        _ = mqtt!.connect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK : Action
    @IBAction func mqttReconnectButton(_ sender: Any) {
        _ = mqtt!.connect()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeCall"
        {
            if let destinationVC = segue.destination as? OutgoingCallViewController {
                destinationVC.phoneNumber = "100"
            }
        }
    }
    
    func terminateCall(){
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            let result = linphone_core_terminate_call(theLinphone.lc!, call)
            NSLog("Terminated call result(outgoing): \(result)")
        }
        OutgoingCallViewData.controller?.dismiss(animated: false, completion: nil)
    }
    
    // MARK : SETTING Environment
    func mqttSetting() {
        
        // Get MQTT Broker IP from PLIST File
        let defaultHost = accountData.getMQTTServerIP()
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost!, port: 1883)
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
    }
}

extension ViewController: CocoaMQTTDelegate {
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        TRACE("trust: \(trust)")
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        if ack == .accept {
            // Get MQTT Broker Topic from PLIST File
            let mqttTopic = accountData.getMQTTTopic()!
            mqtt.subscribe(mqttTopic, qos: CocoaMQTTQOS.qos2)
            mqttStatus.text = "Connected to: " + defaultHost
        }
    }
    
    // When received message
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.string.description), id: \(id)")
        textLabel.text = message.string?.description
        
        let command = message.string!.components(separatedBy: " ")
        
        
        if command[0] == "call" {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OutgoingCallViewController") as? OutgoingCallViewController
            vc!.phoneNumber = command[1]
            //self.navigationController?.pushViewController(vc!, animated: true)
            self.present(vc!, animated: true, completion: nil)
        }
        else if command[0] == "end" {
            terminateCall()
        }
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
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.debugDescription)")
        mqttStatus.text = "Disconnect"
        //_ = mqtt.connect()
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




//
//  MQTTManager.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 3/8/2562 BE.
//
import Foundation
import CocoaMQTT

struct theMQTT {
    static var manager: MQTTManager?
}

class MQTTManager : CocoaMQTTDelegate {
    static var isConnect: Bool = false
    let accountData = LocalUserData()
    var mqtt: CocoaMQTT?

    func startMQTT() {
        if MQTTManager.isConnect {
            print("MQTT already connect.")
        }
        else{
            print("Start MQTT Service")
            MQTTManager.isConnect = true
            mqttSetting()
            _ = mqtt?.connect()
        }
    }
    
    func stopMQTT(){
        print("Stop MQTT Service")
        MQTTManager.isConnect = false
        _ = mqtt?.disconnect()
    }
    
    func restartMQTTService(){
        stopMQTT()
        print("Restart MQTT Service")
        startMQTT()
    }
    

    // Send phone number  to OutgoingCallViewController
    // MARK: MQTT Setting-
    func mqttSetting() {
        // Get MQTT Broker IP from PLIST File
        let brokerIP = accountData.getMQTTServerIp()!
        let clientID = "Bedside-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: brokerIP, port: 1883)
        mqtt!.username = accountData.getMQTTUsername()
        mqtt!.password = accountData.getMQTTPassword()
        mqtt!.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
    }
    
    // MARK: MQTT Command
    // When Message Received
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.string.description), id: \(id)")
        // MQTT MESSAGE HANDLE PART
        let command = message.string!.components(separatedBy: " ")
        MainViewData.controller?.mqttMessageLabel.text = message.string?.description
        // 3 Type of task
        // low_risk_task bed_id
        // mid_risk_task bed_id
        // high_risk_task bed_id
        // Incoming Task
        // "task bed_id"
        
        if (MainViewData.display == true) { // To check mainview appear or not.
            if command[0] == "low_risk_task" {
                print("Low Task Incoming waiting for nurse reply")
                if MainViewData.controller?.audioPlayer == nil {
                    MainViewData.controller?.startPlayback()
                }
            }
            if command[0] == "mid_risk_task" {
                print("Mid Task Incoming waiting for nurse reply")
                if MainViewData.controller?.audioPlayer == nil {
                    MainViewData.controller?.startPlayback()
                }
            }
            if command[0] == "high_risk_task" {
                print("High Task Incoming waiting for nurse reply")
                if MainViewData.controller?.audioPlayer == nil {
                    MainViewData.controller?.startPlayback()
                }
            }
            
            // Stop alert
            // "task_alert_stop bed_id"
            if command[0] == "task_alert_stop" {
                print("Task Stop Alert Message")
                if MainViewData.controller?.audioPlayer != nil {
                    MainViewData.controller?.finishPlayback()
                }
            }
            // When Task Complete
            // task_complete task_id bed_id wearable_id patient_intention
            // Get task_Complete and check same bed id or not
            if command[0] == "task_complete" && command[2] == accountData.getSipUsername() {
                print("Task Complete" + command[1] + ". By Nurse:" + command[3] )
                // Do some thing when task complete  like terminate call? but when nurse terminate phone call in this device will terminate immediately
            }
            
            if command[0] == "getmicgain"{
                MainViewData.controller?.getMicGainValue()
            }
            if command[0] == "getspeakergain"{
                MainViewData.controller?.getSpeakerGainValue()
            }
            

        }
        
        
        // Go to Patient_In State
        if (command[0] == "patient_check_in" )
        {
            //RecordIntentionNavigationController
            if var controller = UIApplication.shared.keyWindow?.rootViewController{
                while let presentedViewController = controller.presentedViewController {
                    controller = presentedViewController
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "RecordIntentionNavigationController")
                controller.present(vc, animated: true, completion: nil)
            }
        }
            
        // Go to Prior_Check_In State
        else if command[0] == "patient_check_out"{
            if var controller = UIApplication.shared.keyWindow?.rootViewController{
                while let presentedViewController = controller.presentedViewController {
                    controller = presentedViewController
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                controller.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    // When MQTT Server Connect
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        if ack == .accept {
            let mqttTopic = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!
            // Set UI Label
            mqtt.subscribe(mqttTopic, qos: CocoaMQTTQOS.qos1)
            //mqtt.subscribe("Test", qos: CocoaMQTTQOS.qos1)
            MainViewData.controller?.mqttStatusLabel.text = "Connected to " + accountData.getMQTTServerIp()!
            MainViewData.controller?.mqttReconnectButton.isHidden = true
        }
    }
    
    // When MQTT Server Disconnect
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.debugDescription)")
        MainViewData.controller?.mqttStatusLabel.text = "Disconnect"
        // Try to disconnect every 5 seconds when MQTT server Disconnect
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
        //            _ = mqtt.connect()
        //        }
    }
    
    // Another Function
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


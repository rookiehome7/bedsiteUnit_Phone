//
//  mainViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 30/7/2562 BE.
//  Copyright © 2562 WiAdvance. All rights reserved.
//

import UIKit
import CocoaMQTT
import MediaPlayer
import AVFoundation
import CoreLocation
import CoreBluetooth

struct MainViewData{
    static var controller: MainViewController?
}

struct MainViewVT{
    static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}

var mainViewCallStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallIncomingReceived: /**<This is a new incoming call */
        NSLog("mainViewCallStateChanged: LinphoneCallIncomingReceived")
        // Auto Answer Call
        let address = linphone_call_get_remote_address_as_string(call)!
        let incomingPhoneNumber = getPhoneNumberFromAddress(String(cString: address))
        MainViewData.controller?.incomingCallLabel.text = incomingPhoneNumber
        MainViewData.controller?.callStatusLabel.text = "IncomingReceived"
        // Auto answer
        //MainViewData.controller?.answerCall()
        MainViewData.controller?.answerButton.isHidden = false
        MainViewData.controller?.callMode_Active()
        
    case LinphoneCallOutgoingProgress:
        NSLog("mainViewCallStateChanged: LinphoneCallOutgoingProgress")
        MainViewData.controller?.callStatusLabel.text = "Calling Progress"
        MainViewData.controller?.answerButton.isHidden = true
        MainViewData.controller?.callMode_Active()

    case LinphoneCallConnected:
        NSLog("mainViewCallStateChanged: LinphoneCallConnected")
        MainViewData.controller?.callStatusLabel.text = "Connected"
        MainViewData.controller?.answerButton.isHidden = true
        MainViewData.controller?.callMode_Active()
        
        
        MainViewData.controller?.startSearchingBeacon()
        MainViewData.controller?.startBroadcastBeacon()
        
    case LinphoneCallError:
        NSLog("mainViewCallStateChanged: LinphoneCallError")
        MainViewData.controller?.callStatusLabel.text = "Error"
        MainViewData.controller?.terminateCall()
        MainViewData.controller?.callMode_NotActive()
        MainViewData.controller?.stopSearchingBeacon()
        MainViewData.controller?.stopBroadcastBeacon()
        
    case LinphoneCallEnd:
        NSLog("mainViewCallStateChanged: LinphoneCallEnd")
        MainViewData.controller?.callStatusLabel.text = "End"
        MainViewData.controller?.terminateCall()
        MainViewData.controller?.callMode_NotActive()
        MainViewData.controller?.stopSearchingBeacon()
        MainViewData.controller?.stopBroadcastBeacon()
        
        
    case LinphoneCallReleased:
        NSLog("mainViewCallStateChanged: LinphoneCallReleased")
        MainViewData.controller?.callStatusLabel.text = "Released"
        MainViewData.controller?.terminateCall()
        MainViewData.controller?.callMode_NotActive()
        MainViewData.controller?.stopSearchingBeacon()
        MainViewData.controller?.stopBroadcastBeacon()
        
    default:
        NSLog("mainViewCallStateChanged: Default call state \(callSate)")
    }
}

class MainViewController: UIViewController {

    // Button
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    
    @IBOutlet weak var volumeDownButton: UIButton!
    @IBOutlet weak var volumeUpButton: UIButton!
    @IBOutlet weak var mqttReconnectButton: UIButton!
    
    @IBOutlet weak var warningSoundButton: UIButton!
    
    // Text Field
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    // Label
    @IBOutlet weak var incomingCallLabel: UILabel!
    @IBOutlet weak var callStatusLabel: UILabel!
    @IBOutlet weak var currentVolumeLabel: UILabel!
    
    @IBOutlet weak var mqttSubscribeTopicLabel: UILabel!
    @IBOutlet weak var mqttMessageLabel: UILabel!
    @IBOutlet weak var mqttStatusLabel: UILabel!
    
    @IBOutlet weak var sipPhoneNumberLabel: UILabel!
    @IBOutlet weak var sipStatusLabel: UILabel!
    @IBOutlet weak var sipServerIpLabel: UILabel!
    
    @IBOutlet weak var beaconRSSILabel: UILabel!
    @IBOutlet weak var beaconProximityLabel: UILabel!
    
    @IBOutlet weak var beaconSearchStatusLabel: UILabel!
    @IBOutlet weak var beaconBroadcastStatusLabel: UILabel!
 
    // MQTT
    var audioPlayer: AVAudioPlayer!
    var mqtt: CocoaMQTT?
    
    // Call Class
    let soundManager = SoundManager()
    let accountData = LocalUserData()
    
    // iBeacon Searching
    var locationManager: CLLocationManager!
    // iBeacon Broadcast
    var broadcastBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewData.controller = self
        
        // Start SIP Phone Service
        theLinphone.manager = LinphoneManager()
        theLinphone.manager?.startLinphone()
        
        answerButton.isHidden = true
        
        // Add listener
//        MainViewVT.lct.call_state_changed = mainViewCallStateChanged
//        linphone_core_add_listener(theLinphone.lc!,  &MainViewVT.lct)
        mqttSetting()
        _ = mqtt?.connect()
        
        
        // iBeacon Searching
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // Dont forgot to add in Info.plst file
        // Privacy - Location When In Use Usage Description & Location Always Usage Description
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
//        startSearchingBeacon()
//        startBroadcastBeacon()
//        beaconSearchStatusLabel.text = "Start"
//        beaconBroadcastStatusLabel.text = "Start"
    
        callMode_NotActive()
        // UPDATE UI every 2 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateUI()
        }
        
        currentVolumeLabel.text = "-"
//        // Set sound
//        let vc = VolumeControl.sharedInstance
//        /*
//         This dispatch after is because the application is adding the volume control and not allowing enought time
//         for the system to get the actual volume so it returns 0.0 which is incorrect.
//         */
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
//        {
//            self.currentVolumeLabel.text = String(format: "%.3f", vc.getCurrentVolume())
//        }
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UserInterface
    func updateUI(){
        print("UpdateUI")
        // SIP Update Value
        sipPhoneNumberLabel.text = accountData.getSipUsername()
        sipServerIpLabel.text = accountData.getSipServerIp()
        switch sipRegistrationStatus{
        case .fail:
            sipStatusLabel.text = "FAIL"
        case .unknown:
            sipStatusLabel.text = "Unknown"
        case .progress:
            sipStatusLabel.text = "Progress"
        case .ok:
            sipStatusLabel.text = "OK"
        case .unregister:
            sipStatusLabel.text = "Not Register"
        }
    }

    func callMode_Active(){
        // Hide Call Button
        phoneNumberTextField.isHidden = true
        callButton.isHidden = true
        
        // Show Phone Control UI
        incomingCallLabel.isHidden = false
        callStatusLabel.isHidden = false
        endButton.isHidden = false
        
    }
    func callMode_NotActive(){
        
        incomingCallLabel.text = "phonenumber"
        
        // Show Call Button
        phoneNumberTextField.isHidden = false
        callButton.isHidden = false
        // Hide Phone Control UI
        incomingCallLabel.isHidden = true
        callStatusLabel.isHidden = true
        endButton.isHidden = true
        answerButton.isHidden = true
    }
    
    
    // MARK: ViewAppear / ViewDisappear
    override func viewWillAppear(_ animated: Bool) {
        //Add Call Status Listener
        MainViewVT.lct.call_state_changed = mainViewCallStateChanged
        linphone_core_add_listener(theLinphone.lc!,  &MainViewVT.lct)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Remove Call Status Listener
        linphone_core_remove_listener(theLinphone.lc!, &MainViewVT.lct)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: Action Button
    // _ = mqtt.connect()
    @IBAction func mqttReconnectButton(_ sender: Any) {
        _ = mqtt?.connect()
    }
    
    @IBAction func volumeDownButton(_ sender: Any) {
        let vc = VolumeControl.sharedInstance
        vc.turnDown()
        currentVolumeLabel.text = String(format: "%.3f", vc.getCurrentVolume())
    }
    
    @IBAction func volumeUpButton(_ sender: Any) {
        let vc = VolumeControl.sharedInstance
        //vc.setVolume(volume: 0.50)
        vc.turnUp()
        currentVolumeLabel.text = String(format: "%.3f", vc.getCurrentVolume())
        
    }
    
    @IBAction func makeCallButton(_ sender: Any) {
        incomingCallLabel.text = phoneNumberTextField.text
        makeCall()
        
    }
    @IBAction func answerCallButton(_ sender: Any) {
        answerCall()
    }
    
    @IBAction func endCallButton(_ sender: Any) {
        terminateCall()
        
    }
    
    @IBAction func playSoundButton(_ sender: Any) {
        if audioPlayer == nil {
            startPlayback()
        }
        else {
            finishPlayback()
        }
    }
    
}

// MARK : Linphone Extension
extension MainViewController {
    func makeCall(){
        // MAKE Phone call
        let lc = theLinphone.lc
        linphone_core_invite(lc, phoneNumberTextField.text)
    }
    
    func answerCall(){
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            let result = linphone_core_accept_call(theLinphone.lc!, call)
            NSLog("Answer call result(receive): \(result)")
        }
    }
    func terminateCall(){
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            let result = linphone_core_terminate_call(theLinphone.lc!, call)
            NSLog("Terminated call result(receive): \(result)")
        }
    }
    
}


// MARK : Sound Extension
extension MainViewController {
    func startPlayback() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("waitingsound.m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            // NumberofLoops: -1 Forever loop
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
            warningSoundButton.setTitle("Stop Playback", for: .normal)
        } catch {
            warningSoundButton.isHidden = true
            // unable to play recording!
        }
    }
    
    func finishPlayback() {
        audioPlayer = nil
        warningSoundButton.setTitle("Playback", for: .normal)
    }
    
}


// MARK: Cocoa MQTT - View Controller Extension Part
// This extension will handle all MQTT function
extension MainViewController: CocoaMQTTDelegate {
    // Send phone number  to OutgoingCallViewController

    // MARK: MQTT Setting-
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

    // MARK: MQTT Command
    // When Message Received
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.string.description), id: \(id)")
        mqttMessageLabel.isHidden = false
        mqttMessageLabel.text = message.string?.description
        
        // MQTT MESSAGE HANDLE PART
        let command = message.string!.components(separatedBy: " ")
        //        if command[0] == "call" {
        //            makeCall(phoneNumber: command[1])
        //        }
        
        // 3 Type of task
        // low_risk_task bed_id
        // mid_risk_task bed_id
        // high_risk_task bed_id
        // Incoming Task
        // "task bed_id"
        if command[0] == "task" && command[1] == accountData.getSipUsername() {
            print("Task Incoming waiting for nurse reply")
            if audioPlayer == nil {
                startPlayback()
            }
            //            else {
            //                finishPlayback()
            //            }
        }
        
        // Stop alert
        // "task_alert_stop bed_id"
        if command[0] == "task_alert_stop" && command[1] == accountData.getSipUsername() {
            print("Task Stop Alert Message")
            if audioPlayer != nil {
                finishPlayback()
            }
        }
        
        // When Task Complete
        // task_complete task_id bed_id wearable_id patient_intention
        // Get task_Complete and check same bed id or not
        if command[0] == "task_complete" && command[2] == accountData.getSipUsername() {
            print("Task Complete" + command[1] + ". By Nurse:" + command[3] )
            // Do some thing when task complete  like terminate call? but when nurse terminate phone call in this device will terminate immediately
            
        }
        
    }
    
    // When MQTT Server Connect
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        if ack == .accept {
            mqttReconnectButton.isHidden = true

            let mqttTopic = accountData.getMQTTTopic()! // + "/" + accountData.getSipUsername()!
            // Set UI Label
            mqttSubscribeTopicLabel.text = mqttTopic
            mqtt.subscribe(mqttTopic, qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe("Test", qos: CocoaMQTTQOS.qos1)
            mqttStatusLabel.text = "Connected to " + accountData.getMQTTServerIp()!
        }
    }
    
    // When MQTT Server Disconnect
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.debugDescription)")
        mqttStatusLabel.text = "Disconnect"
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

extension MainViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}

// MARK: iBeacon - View Controller Extension Part
extension MainViewController: CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    // MARK: iBeacon Broadcast Signal
    func startBroadcastBeacon() {
        beaconBroadcastStatusLabel.text = "Start"
        if broadcastBeacon != nil {
            stopBroadcastBeacon()
        }
        // Set iBeacon Value
        let uuid = UUID(uuidString: accountData.getBeaconUUID()!)!
        let localBeaconMajor: CLBeaconMajorValue = UInt16(accountData.getBeaconMajor()!)!
        let localBeaconMinor: CLBeaconMinorValue = UInt16(accountData.getBeaconMinor()!)!
        //let localBeaconMajor: CLBeaconMajorValue = 123
        //let localBeaconMinor: CLBeaconMinorValue = 789
        let identifier = "Put your identifier here"
        
        broadcastBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: identifier)
        beaconPeripheralData = broadcastBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopBroadcastBeacon() {
        if broadcastBeacon != nil {
            beaconBroadcastStatusLabel.text = "Stop"
            beaconRSSILabel.text = " "
            beaconProximityLabel.text = " "
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            broadcastBeacon = nil
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
        }
        else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
    // MARK: iBeacon Searching Signal
    func startSearchingBeacon() {
        beaconSearchStatusLabel.text = "Start"
        if let uuid = NSUUID(uuidString: accountData.getBeaconUUID()!) {
            print("Start Monitoring")
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "iBeacon")
            startMonitoring(beaconRegion: beaconRegion)
            startRanging(beaconRegion: beaconRegion)
        }
    }
    func stopSearchingBeacon() {
        beaconSearchStatusLabel.text = "Stop"
        if let uuid = NSUUID(uuidString: accountData.getBeaconUUID()!) {
            print("Stop Monitoring")
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "iBeacon")
            stopMonitoring(beaconRegion: beaconRegion)
            stopRanging(beaconRegion: beaconRegion)
        }
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if !(status == .authorizedAlways || status == .authorizedWhenInUse) {
            print("Must allow location access for this application to work")
        } else {
            if let uuid = NSUUID(uuidString: accountData.getBeaconUUID()!) {
                let beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "iBeacon")
                startMonitoring(beaconRegion: beaconRegion)
                startRanging(beaconRegion: beaconRegion)
            }
        }
    }
    func startMonitoring(beaconRegion: CLBeaconRegion) {
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        locationManager.startMonitoring(for: beaconRegion)
    }
    func startRanging(beaconRegion: CLBeaconRegion) {
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    func stopMonitoring(beaconRegion: CLBeaconRegion) {
        beaconRegion.notifyOnEntry = false
        beaconRegion.notifyOnExit = false
        locationManager.stopMonitoring(for: beaconRegion)
    }
    func stopRanging(beaconRegion: CLBeaconRegion) {
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    //  ======== CLLocationManagerDelegate methods ==========
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            var beaconProximity: String;
            switch (beacon.proximity) {
            case .unknown:    beaconProximity = "Unknown";
            case .far:        beaconProximity = "Far";
            case .near:       beaconProximity = "Near";
            case .immediate:  beaconProximity = "Immediate";
            default:          beaconProximity = "Error";
                
            }
            print("BEACON RANGED: uuid: \(beacon.proximityUUID.uuidString) major: \(beacon.major)  minor: \(beacon.minor) proximity: \(beaconProximity)" )

            let call = linphone_core_get_current_call(theLinphone.lc!)
            let address = linphone_call_get_remote_address_as_string(call)!
            let incomingPhoneNumber = getPhoneNumberFromAddress(String(cString: address))

            print (phoneNumberTextField.text ?? " " )
            if ( incomingPhoneNumber == "\(beacon.minor)"){
                // Need to create part get the phone number to set the minor value
                beaconProximityLabel.text = beaconProximity
                beaconRSSILabel.text = "\(beacon.rssi)"
            }
            else if (phoneNumberTextField.text == "\(beacon.minor)" ){
                beaconProximityLabel.text = beaconProximity
                beaconRSSILabel.text = "\(beacon.rssi)"
            }
            else {
                beaconProximityLabel.text = "Error"
                beaconRSSILabel.text = "Error"
            }
            //if ( incomingPhoneNumber == "\(beacon.minor)"){
            // Example how to set the volume
            //                if (beaconProximity == "Immediate"){
            //                    let vc = VolumeControl.sharedInstance
            //                    vc.setVolume(volume: 0.1)
            //                }
            //                if (beaconProximity == "Near"){
            //                    let vc = VolumeControl.sharedInstance
            //                    vc.setVolume(volume: 0.50)
            //                }
            //                if (beaconProximity == "Far"){
            //                    let vc = VolumeControl.sharedInstance
            //                    vc.setVolume(volume: 1.0)
            //                }
            //}
        }
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Monitoring started")
    }
    private func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID ENTER REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID EXIT REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
        }
    }
}

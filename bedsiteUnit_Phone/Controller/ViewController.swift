//
//  ViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//
import UIKit
// Mqtt
import CocoaMQTT
//Volume Control
import MediaPlayer
// iBeacon
import CoreLocation
import CoreBluetooth

import AVFoundation

struct ViewVT{
        static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}

var viewCallStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallOutgoingProgress:
        NSLog("outgoingCallStateChanged: LinphoneCallReleased")

    case LinphoneCallReleased:
        NSLog("outgoingCallStateChanged: LinphoneCallReleased")
        
    case LinphoneCallConnected:
        NSLog("outgoingCallStateChanged: LinphoneCallConnected")

    case LinphoneCallError:
        NSLog("outgoingCallStateChanged: LinphoneCallError")

    case LinphoneCallEnd:
        NSLog("outgoingCallStateChanged: LinphoneCallEnd")
        
    default:
        NSLog("outgoingCallStateChanged: Default call state \(callSate)")
    }
}


class ViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    // UI Label
    @IBOutlet weak var mqttTopic: UILabel!
    @IBOutlet weak var mqttStatus: UILabel!
    @IBOutlet weak var mqttMessage: UILabel!
    @IBOutlet weak var sipStatus: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!
    
    // UI TextField
    @IBOutlet weak var phoneNumberField: UITextField!
    
    // User Button name
    @IBOutlet weak var mqttReconnectButton: UIButton!
    @IBOutlet weak var playbutton: UIButton!
    
    // User Data
    let accountData = LocalUserData() // Get function read file from PLIST
    
    //let volumeView = MPVolumeView()
    
    // MQTT
    var mqtt: CocoaMQTT?
    
    // iBeacon Setting
    let iBeacon_UUID = "7D0D9B66-0554-4CCF-A6E4-ADE12325C4F0"
    let IBEACON_PROXIMITY_UUID = "7D0D9B66-0554-4CCF-A6E4-ADE12325C4F0"
    let localBeaconUUID = "7D0D9B66-0554-4CCF-A6E4-ADE12325C4F0"
    // iBeacon Searching
    var locationManager: CLLocationManager!
    // iBeacon Broadcast
    var broadcastBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    let localBeaconMajor: CLBeaconMajorValue = 123
    let localBeaconMinor: CLBeaconMinorValue = 789
    let identifier = "Put your identifier here"
    
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UI Setting
        mqttReconnectButton.isHidden = false
        mqttMessage.isHidden = true
    
        updateUIStatus()
        
        //Run MQTT on mac: /usr/local/sbin/mosquitto -c /usr/local/etc/mosquitto/mosquitto.conf
        mqttSetting()       // Setting MQTT
        _ = mqtt!.connect() // MQTT Connect'
        
        
        // iBeacon Start Searching
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // Dont forgot to add in Info.plst file
            // Privacy - Location When In Use Usage Description
        locationManager.requestWhenInUseAuthorization()
            // Privacy - Location Always Usage Description
        locationManager.requestAlwaysAuthorization()
        if let uuid = NSUUID(uuidString: IBEACON_PROXIMITY_UUID) {
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "iBeacon")
            startMonitoring(beaconRegion: beaconRegion)
            startRanging(beaconRegion: beaconRegion)
            print("Start Monitoring")
        }
        
         // iBeacon Start Searching
        startBroadcastBeacon()
        
        // UPDATE UI every 2 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateUIStatus()
        }
    }
    
    @IBAction func playbutton(_ sender: Any) {
        if audioPlayer == nil {
            startPlayback()
        }
        else {
            finishPlayback()
        }
        
    }
    // MARK: - Playback
    func startPlayback() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("waitingsound.m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            audioPlayer.play()
            playbutton.setTitle("Stop Playback", for: .normal)
        } catch {
            playbutton.isHidden = true
            // unable to play recording!
        }
    }
    
    func finishPlayback() {
        audioPlayer = nil
        playbutton.setTitle("Play Your Recording", for: .normal)
    }
    
    // Function to update UI
    func updateUIStatus(){
        mqttTopic.text = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!

        switch sipRegistrationStatus{
        case .fail:
            sipStatus.text = "FAIL"
        case .unknown:
            sipStatus.text = "Unknown"
        case .progress:
            sipStatus.text = "Progress"
        case .ok:
            sipStatus.text = "OK"
        case .unregister:
            sipStatus.text = "Not Register"
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button Action
    @IBAction func mqttReconnectButton(_ sender: Any) {
        _ = mqtt!.connect()
        mqttTopic.text = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!
    }

    // MARK: ViewAppear / ViewDisappear
    override func viewWillAppear(_ animated: Bool) {
        // Reset after view appear
        _ = mqtt?.disconnect()
        mqttSetting()
        _ = mqtt?.connect()
        mqttTopic.text! = accountData.getMQTTTopic()! + "/" + accountData.getSipUsername()!
        
        ViewVT.lct.call_state_changed = viewCallStateChanged
        linphone_core_add_listener(theLinphone.lc!,  &ViewVT.lct)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    // Function to handle MQTT Command
    
    func terminateCall(){
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            let result = linphone_core_terminate_call(theLinphone.lc!, call)
            NSLog("Terminated call result(outgoing): \(result)")
        }
        OutgoingCallViewData.controller?.dismiss(animated: false, completion: nil)
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
    // MARK: iBeacon Searching Signal
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if !(status == .authorizedAlways || status == .authorizedWhenInUse) {
            print("Must allow location access for this application to work")
        } else {
            if let uuid = NSUUID(uuidString: IBEACON_PROXIMITY_UUID) {
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
            print("BEACON RANGED: uuid: \(beacon.proximityUUID.uuidString) major: \(beacon.major)  minor: \(beacon.minor) proximity: \(beaconProximity)")
            
            proximityLabel.text = beaconProximity
            if (beaconProximity == "Immediate"){
                let vc = VolumeControl.sharedInstance
                vc.setVolume(volume: 0.1)
                //                let call = linphone_core_get_current_call(theLinphone.lc!)
                //                if call != nil {
                //                    linphone_core_terminate_call(theLinphone.lc!, call)
                //                }
            }
            if (beaconProximity == "Near"){
                let vc = VolumeControl.sharedInstance
                vc.setVolume(volume: 0.50)
            }
            if (beaconProximity == "Far"){
                let vc = VolumeControl.sharedInstance
                vc.setVolume(volume: 1.0)
            }
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

// MARK: iBeacon - View Controller Extension Part
extension ViewController {
    // MARK: iBeacon Broadcast Signal
    func startBroadcastBeacon() {
        if broadcastBeacon != nil {
            stopBroadcastBeacon()
        }
        let uuid = UUID(uuidString: iBeacon_UUID)!
        broadcastBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: identifier)
        beaconPeripheralData = broadcastBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopBroadcastBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        broadcastBeacon = nil
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
            
        }
        else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
    
    
}


// MARK: Cocoa MQTT - View Controller Extension Part
// This extension will handle all MQTT function
extension ViewController: CocoaMQTTDelegate {
    func makeCall(phoneNumber : String){
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OutgoingCallViewController") as? OutgoingCallViewController
        vc!.phoneNumber = phoneNumber
        //self.navigationController?.pushViewController(vc!, animated: true)
        self.present(vc!, animated: true, completion: nil)
    }
    // MARK: MQTT Setting
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



extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}

//
//  ReceiveCallViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//
import UIKit
import CoreLocation
import CoreBluetooth

struct ReceiveCallViewData{
    static var controller: ReceiveCallViewController?
}

struct ReceiveCallVT {
    static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}

var receiveCallStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallConnected: /**<The call encountered an error*/
        NSLog("receiveCallStateChanged: LinphoneCallConnected")
        ReceiveCallViewData.controller?.statusLabel.text = "Connected"
        ReceiveCallViewData.controller?.showEndButton()
        
    case LinphoneCallError: /**<The call encountered an error*/
        NSLog("receiveCallStateChanged: LinphoneCallError")
        finishReceiveCallView()
        
    case LinphoneCallEnd:
        NSLog("receiveCallStateChanged: LinphoneCallEnd")
        finishReceiveCallView()
        
    default:
        NSLog("receiveCallStateChanged: Default call state")
    }
}

func finishReceiveCallView(){
    let call = linphone_core_get_current_call(theLinphone.lc!)
    if call != nil {
        let result = linphone_core_terminate_call(theLinphone.lc!, call)
        NSLog("Terminated call result(receive): \(result)")
    }
    ReceiveCallViewData.controller?.dismiss(animated: false, completion: nil)
}

class ReceiveCallViewController: UIViewController {
    // UI Lable
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    // UI Button
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    // User Data
    let accountData = LocalUserData() // Get function read file from PLIST
    // iBeacon Searching
    var locationManager: CLLocationManager!
    // iBeacon Broadcast
    var broadcastBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI Setting
        endButton.isHidden = true
        ReceiveCallViewData.controller = self
        self.navigationItem.hidesBackButton = true
        
        // iBeacon Searching Part
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // Dont forgot to add in Info.plst file
        // Privacy - Location When In Use Usage Description & Location Always Usage Description
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        
        // Get CALL - Auto Answer
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            linphone_core_accept_call(theLinphone.lc!, call)
            statusLabel.text = "Connected"
            showEndButton()
        }
       
        let address = linphone_call_get_remote_address_as_string(call)!
        
         let number = linphone_call_get_remote_address(call)!
        let account = getUsernameFromAddress(String(cString: address))
        nameLabel.text = account
    }

    // MARK: - Action
    // MAY BE NOT USE IN NEXT TIME
    @IBAction func answerCall(_ sender: Any) {
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            linphone_core_accept_call(theLinphone.lc!, call)
        }
    }
    @IBAction func endCall(_ sender: Any) {
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            linphone_core_terminate_call(theLinphone.lc!, call)
        }
    }
    
    // MARK: - Navigation
    override func viewWillAppear(_ animated: Bool) {
        // Add CallStateChange listener
        ReceiveCallVT.lct.call_state_changed = receiveCallStateChanged
        linphone_core_add_listener(theLinphone.lc!, &ReceiveCallVT.lct)
        
        // Start Service : iBeacon Searching & Broadcast
        startSearchingBeacon()
        startBroadcastBeacon()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Remove CallStateChange listener
        linphone_core_remove_listener(theLinphone.lc!, &ReceiveCallVT.lct)
        
        // Start Service : iBeacon Searching & Broadcast
        startSearchingBeacon()
        startBroadcastBeacon()
        
        // Terminate Call First If it still have call
        finishReceiveCallView()
    }
    
    func showEndButton(){
        acceptButton.isHidden = true
        declineButton.isHidden = true
        endButton.isHidden = false
    }
}

// MARK: iBeacon - View Controller Extension Part
extension ReceiveCallViewController: CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    // MARK: iBeacon Broadcast Signal
    func startBroadcastBeacon() {
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
    
    // MARK: iBeacon Searching Signal
    func startSearchingBeacon() {
        if let uuid = NSUUID(uuidString: accountData.getBeaconUUID()!) {
            print("Start Monitoring")
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "iBeacon")
            startMonitoring(beaconRegion: beaconRegion)
            startRanging(beaconRegion: beaconRegion)
        }
    }
    func stopSearchingBeacon() {
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
            print("BEACON RANGED: uuid: \(beacon.proximityUUID.uuidString) major: \(beacon.major)  minor: \(beacon.minor) proximity: \(beaconProximity)")
            
            // Need to create part get the phone number to set the minor value
            
            //proximityLabel.text = beaconProximity
            
            // Example how to set the volume
            if (beaconProximity == "Immediate"){
                let vc = VolumeControl.sharedInstance
                vc.setVolume(volume: 0.1)
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

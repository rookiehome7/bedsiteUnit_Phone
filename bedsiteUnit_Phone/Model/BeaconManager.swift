//
//  BeaconManager.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 24/7/2562 BE.
//  Copyright © 2562 WiAdvance. All rights reserved.
//

import Foundation
// iBeacon 
import CoreLocation
import CoreBluetooth
import UIKit

class BeaconManager {
    
}
//class BeaconManager: CLLocationManagerDelegate, CBPeripheralManagerDelegate {
//
//    // For iBeacon Searching
//    let IBEACON_PROXIMITY_UUID = "7D0D9B66-0554-4CCF-A6E4-ADE12325C4F0"
//    var locationManager: CLLocationManager!
//
//    // Objects used in the creation of iBeacons
//    var localBeacon: CLBeaconRegion!
//    var beaconPeripheralData: NSDictionary!
//    var peripheralManager: CBPeripheralManager!
//
//    let localBeaconUUID = "7D0D9B66-0554-4CCF-A6E4-ADE12325C4F0"
//    let localBeaconMajor: CLBeaconMajorValue = 123
//    let localBeaconMinor: CLBeaconMinorValue = 456
//    let identifier = "Put your identifier here"
//
//
//    func start(){
//        locationManager = CLLocationManager()
//        //locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestAlwaysAuthorization()
//
//        if let uuid = NSUUID(uuidString: IBEACON_PROXIMITY_UUID) {
//            let beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "iBeacon")
//            startMonitoring(beaconRegion: beaconRegion)
//            startRanging(beaconRegion: beaconRegion)
//            print("Start Monitoring")
//        }
//
//        initLocalBeacon()
//    }
//
//    // iBeacon Function
//    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if !(status == .authorizedAlways || status == .authorizedWhenInUse) {
//            print("Must allow location access for this application to work")
//        } else {
//            if let uuid = NSUUID(uuidString: IBEACON_PROXIMITY_UUID) {
//                let beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "iBeacon")
//                startMonitoring(beaconRegion: beaconRegion)
//                startRanging(beaconRegion: beaconRegion)
//            }
//        }
//    }
//
//    func startMonitoring(beaconRegion: CLBeaconRegion) {
//        beaconRegion.notifyOnEntry = true
//        beaconRegion.notifyOnExit = true
//        locationManager.startMonitoring(for: beaconRegion)
//
//    }
//
//    func startRanging(beaconRegion: CLBeaconRegion) {
//        locationManager.startRangingBeacons(in: beaconRegion)
//    }
//
//    func stopMonitoring(beaconRegion: CLBeaconRegion) {
//        beaconRegion.notifyOnEntry = false
//        beaconRegion.notifyOnExit = false
//        locationManager.stopMonitoring(for: beaconRegion)
//    }
//
//    func stopRanging(beaconRegion: CLBeaconRegion) {
//        locationManager.stopRangingBeacons(in: beaconRegion)
//    }
//
//
//    //  ======== CLLocationManagerDelegate methods ==========
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        for beacon in beacons {
//            var beaconProximity: String;
//            switch (beacon.proximity) {
//            case .unknown:    beaconProximity = "Unknown";
//            case .far:        beaconProximity = "Far";
//            case .near:       beaconProximity = "Near";
//            case .immediate:  beaconProximity = "Immediate";
//            }
//            //            beaconList.append(BeaconData(uuid: beacon.proximityUUID.uuidString,
//            //                                         major: "\(beacon.major)",
//            //                minor: "\(beacon.minor)",
//            //                proximity: beaconProximity))
//
//
//            print("BEACON RANGED: uuid: \(beacon.proximityUUID.uuidString) major: \(beacon.major)  minor: \(beacon.minor) proximity: \(beaconProximity)")
//

//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        print("Monitoring started")
//    }
//
//
//    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
//        print("Monitoring failed")
//    }
//
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        if let beaconRegion = region as? CLBeaconRegion {
//            print("DID ENTER REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        if let beaconRegion = region as? CLBeaconRegion {
//            print("DID EXIT REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
//        }
//    }
//
//
//    func initLocalBeacon() {
//        if localBeacon != nil {
//            stopLocalBeacon()
//        }
//        let uuid = UUID(uuidString: localBeaconUUID)!
//        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: identifier)
//        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//    }
//
//    func stopLocalBeacon() {
//        peripheralManager.stopAdvertising()
//        peripheralManager = nil
//        beaconPeripheralData = nil
//        localBeacon = nil
//    }
//
//
//    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        if peripheral.state == .poweredOn {
//            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
//
//        }
//        else if peripheral.state == .poweredOff {
//            peripheralManager.stopAdvertising()
//        }
//    }
//}

//
//  LocalUserData.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//
import Foundation

// This class made create function to get the data from setting file
// and it will return the data
// In this version using NSDictionary to read "Secret.plist" database file
class LocalUserData {
    // This function for load data from Plist file and write to userdefault
    func loadSettingPlist() {
        // GET Plist directory
        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        //MQTT
        UserDefaults.standard.set(dict?.object(forKey: "mqttserverip") as? String, forKey: "mqttserverip")
        UserDefaults.standard.set(dict?.object(forKey: "mqttserverport") as? String, forKey: "mqttserverport")
        UserDefaults.standard.set(dict?.object(forKey: "mqttsubscribetopic") as? String, forKey: "mqttsubscribetopic")
        UserDefaults.standard.set(dict?.object(forKey: "mqttusername") as? String, forKey: "mqttusername")
        UserDefaults.standard.set(dict?.object(forKey: "mqttpassword") as? String, forKey: "mqttpassword")
        //SIP
        UserDefaults.standard.set(dict?.object(forKey: "sipserverip") as? String, forKey: "sipserverip")
        UserDefaults.standard.set(dict?.object(forKey: "sipserverport") as? String, forKey: "sipserverport")
        UserDefaults.standard.set(dict?.object(forKey: "sipusername") as? String, forKey: "sipusername")
        UserDefaults.standard.set(dict?.object(forKey: "sippassword") as? String, forKey: "sippassword")
        //Beacon
        UserDefaults.standard.set(dict?.object(forKey: "beaconuuid") as? String, forKey: "beaconuuid")
        UserDefaults.standard.set(dict?.object(forKey: "beaconmajor") as? String, forKey: "beaconmajor")
        UserDefaults.standard.set(dict?.object(forKey: "beaconminor") as? String, forKey: "beaconminor")
    }
    
    // Example how to get file from plist
    //        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
    //        let dict = NSDictionary(contentsOfFile: path!)
    //        return dict?.object(forKey: "mqttserverip") as? String
    
    // MQTT
    func getMQTTServerIp() -> String?{
        return UserDefaults.standard.string(forKey: "mqttserverip") ?? ""
    }
    func getMQTTServerPort() -> String?{
        return UserDefaults.standard.string(forKey: "mqttserverport") ?? ""
    }
    func getMQTTTopic() -> String?{
        return UserDefaults.standard.string(forKey: "mqttsubscribetopic") ?? ""
    }
    func getMQTTUsername() -> String?{
        return UserDefaults.standard.string(forKey: "mqttusername") ?? ""
    }
    func getMQTTPassword() -> String?{
        return UserDefaults.standard.string(forKey: "mqttpassword") ?? ""
    }
    
    // SIP
    func getSipServerIp() -> String?{
        return UserDefaults.standard.string(forKey: "sipserverip") ?? ""
    }
    func getSipServerPort() -> String?{
        return UserDefaults.standard.string(forKey: "sipserverport") ?? ""
    }
    func getSipUsername() -> String?{
        return UserDefaults.standard.string(forKey: "sipusername") ?? ""
    }
    func getSipPassword() -> String?{
        return UserDefaults.standard.string(forKey: "sippassword") ?? ""
    }
    
    // UUID
    func getBeaconUUID() -> String?{
        return UserDefaults.standard.string(forKey: "beaconuuid") ?? ""
    }
    func getBeaconMajor() -> String?{
        return UserDefaults.standard.string(forKey: "beaconmajor") ?? ""
    }
    func getBeaconMinor() -> String?{
        return UserDefaults.standard.string(forKey: "beaconminor") ?? ""
    }
}

//    mqttIpAddress
//    mqttPort
//    mqttSubscribeTopic
//    mqttUsername
//    mqttPassword
//
//    sipIpAddress
//    sipPort
//    sipUsername
//    sipPassword
//
//    beaconUUID
//    beaconMajor
//    beaconMinor

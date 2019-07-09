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
        //SIP
        UserDefaults.standard.set(dict?.object(forKey: "sipaccount") as? String, forKey: "sipaccount")
        UserDefaults.standard.set(dict?.object(forKey: "sippassword") as? String, forKey: "sippassword")
        UserDefaults.standard.set(dict?.object(forKey: "sipserverip") as? String, forKey: "sipserverip")
        UserDefaults.standard.set(dict?.object(forKey: "sipserverport") as? String, forKey: "sipserverport")
        //MQTT
        UserDefaults.standard.set(dict?.object(forKey: "mqttserverip") as? String, forKey: "mqttserverip")
        UserDefaults.standard.set(dict?.object(forKey: "mqttserverport") as? String, forKey: "mqttserverport")
        UserDefaults.standard.set(dict?.object(forKey: "mqttsubscribetopic") as? String, forKey: "mqttsubscribetopic")
    }
    
    //SIP
    func getSipUsername() -> String?{
//        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//        return dict?.object(forKey: "sipaccount") as? String
        return UserDefaults.standard.string(forKey: "sipaccount") ?? ""
    }
    func getSipPassword() -> String?{
//        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//        return dict?.object(forKey: "sippassword") as? String
        return UserDefaults.standard.string(forKey: "sippassword") ?? ""
    }
    func getSipServerIp() -> String?{
//        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//        return dict?.object(forKey: "sipserverip") as? String
        return UserDefaults.standard.string(forKey: "sipserverip") ?? ""
    }
    func getSipServerPort() -> String?{
//        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//        return dict?.object(forKey: "sipserverport") as? String
        return UserDefaults.standard.string(forKey: "sipserverport") ?? ""
    }
    
    //MQTT
    func getMQTTServerIp() -> String?{
//        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//        return dict?.object(forKey: "mqttserverip") as? String
        return UserDefaults.standard.string(forKey: "mqttserverip") ?? ""
    }
    func getMQTTServerPort() -> String?{
//        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//        return dict?.object(forKey: "mqttserverport") as? String
        return UserDefaults.standard.string(forKey: "mqttserverport") ?? ""
    }
    func getMQTTTopic() -> String?{
//        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//        return dict?.object(forKey: "mqttsubscribetopic") as? String
        return UserDefaults.standard.string(forKey: "mqttsubscribetopic") ?? ""
    }
    
}

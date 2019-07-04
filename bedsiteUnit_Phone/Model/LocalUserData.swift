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
    func getSipUsername() -> String?{
        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        return dict?.object(forKey: "account") as? String
    }
    func getSipPassword() -> String?{
        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        return dict?.object(forKey: "password") as? String
    }
    func getSipDomain() -> String?{
        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        return dict?.object(forKey: "domain") as? String
    }
    
}

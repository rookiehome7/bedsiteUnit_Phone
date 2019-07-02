//
//  LocalUserData.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//  Copyright © 2562 WiAdvance. All rights reserved.
//

import Foundation

// This class for get data from Secret.plist
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

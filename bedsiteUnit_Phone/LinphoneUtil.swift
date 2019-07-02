//
//  LinphoneUtil.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai on 30/6/19.
//  Copyright © 2019 WiAdvance. All rights reserved.
//

import Foundation

func getUsernameFromAddress(_ address: String) -> String{
    
    var result: String = address
    if((address.range(of: "sip:")) != nil) {
        result = address.replacingOccurrences(of: "sip:", with: "");
    }
    
    if((result.range(of: "@")) != nil) {
        
        result = result.components(separatedBy: "@")[0]
    }
    
    return result
}

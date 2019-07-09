//
//  LinphoneUtil.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
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

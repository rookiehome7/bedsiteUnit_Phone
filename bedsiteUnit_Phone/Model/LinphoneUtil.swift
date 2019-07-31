//
//  LinphoneUtil.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//

import Foundation



// Get address Example: "104"<sip:104@10.12.154.54>
func getPhoneNumberFromAddress(_ address: String) -> String{
    var result: String = address
    if((result.range(of: "<")) != nil) {
        // Set to "104"
        result = result.components(separatedBy: "<")[0]
        
        // Set to 104
        result = result.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal , range: nil)
    }
    return result.trimmingCharacters(in: .whitespacesAndNewlines)
}

// Get address Example: "104"<sip:104@10.12.154.54>
//After first if change to  "104"<104@10.12.154.54>
//After Second if change to  "104"<104>
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

//
//  OutgoingCallViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//  Copyright © 2562 WiAdvance. All rights reserved.
//

import UIKit

struct OutgoingCallViewData{
    static var controller: OutgoingCallViewController?
    static var callTime: Date?
    static var phoneType: CallPhoneType?
    static var phoneNumber: String?
    static var statusLabel: UILabel?
    static var sipIcon: UIImageView?
    static var calleeName: String?
    static var callConnected: Bool?
    static var retry: Bool = false
}
enum CallPhoneType {
    case sip
    case call_END
}

struct OutgoingCallVT{
    static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}

var outgoingCallStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallOutgoingProgress:
        if OutgoingCallViewData.retry == true{
            OutgoingCallViewData.retry = false
        }
        
    case LinphoneCallConnected:
        NSLog("outgoingCallStateChanged: LinphoneCallConnected")
        
        //OutgoingCallViewData.callType = CallLogType.outgoing_CALL_ANSWERED
       // OutgoingCallViewData.controller?.statusLabel.text = "Connected"
        OutgoingCallViewData.callConnected = true
        
    case LinphoneCallError: /**<The call encountered an error, will not call LinphoneCallEnd*/
        NSLog("outgoingCallStateChanged: LinphoneCallError")
       // OutgoingCallViewData.controller?.statusLabel.text = "Error"
        let message = String(cString: message!)
        NSLog(message)
        
        //        if message == "Busy Here"{
        //            OutgoingCallData.retry = false
        //            OutgoingCallData.phoneType = CallPhoneType.NONSIP
        //            let alertController = UIAlertController(title: "", message: "使用者無法接聽", preferredStyle: UIAlertControllerStyle.Alert)
        //            alertController.addAction(UIAlertAction(title: "關閉", style: UIAlertActionStyle.Default, handler: {
        //                (action: UIAlertAction!) in
        //                close()
        //            }))
        //            OutgoingCallData.controller?.presentViewController(alertController, animated: true, completion: nil)
        //
        //            dispatch_async(dispatch_get_main_queue()) { () -> Void in
        //
        //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
        //                    alertController.dismissViewControllerAnimated(true, completion: nil)
        //                    close()
        //                })
        //            }
        //        }else{
        
        //OutgoingCallViewData.callType = CallLogType.outgoing_CALL_NO_ANSWER
        
//        if OutgoingCallViewData.phoneType == CallPhoneType.sip && OutgoingCallData.callee?.phones.count != 0{
//            OutgoingCallViewData.retry = true
//            OutgoingCallViewData.phoneType = CallPhoneType.nonsip
//            OutgoingCallViewData.phoneNumber = OutgoingCallData.callee?.phones[0]
//            makeCall()
//            return
//        }
//        // If call type is SIP and phone number is available
//        if OutgoingCallViewData.retry == false {
//            close()
//        }
//        //        }
        
        
    case LinphoneCallEnd:
        NSLog("outgoingCallStateChanged: LinphoneCallEnd")
        if OutgoingCallViewData.retry == false {
            close()
        }
        
    default:
        NSLog("outgoingCallStateChanged: Default call state \(callSate)")
    }
}

func resetOutgoingCallData(){
    OutgoingCallViewData.callTime = nil
    OutgoingCallViewData.callConnected = false
    OutgoingCallViewData.retry = false
}

func close(){
    
    resetOutgoingCallData()
    OutgoingCallViewData.controller?.dismiss(animated: true, completion: nil)
}

func makeCall(){
    
    switch OutgoingCallViewData.phoneType! {
    
    case CallPhoneType.sip:
        OutgoingCallViewData.statusLabel!.text = "SIP Dialing..."
    
    case CallPhoneType.call_END:
        OutgoingCallViewData.statusLabel!.text = "Call end"
    }
    

    //if let phone = OutgoingCallViewData.phoneNumber {
    if let lc = theLinphone.lc {
        linphone_core_invite(lc, OutgoingCallViewData.phoneNumber)
    //    }
        
//        if OutgoingCallViewData.phoneType == CallPhoneType.sip {
//            // Fire a timer to auto call mobile if not connect
//            OutgoingCallViewData.addEndSipCallTimer()
//        }
    }
}

class OutgoingCallViewController: UIViewController {
    
    var phoneNumber: String?
    var calleeName: String?
    var phoneType: CallPhoneType = .sip
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sipImage: UIImageView!

    //TEST
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("OutgoingCallController.viewDidLoad()")
        
        // Get data from view controller
        resetOutgoingCallData()
        OutgoingCallViewData.controller = self
        OutgoingCallViewData.phoneNumber = phoneNumber
        OutgoingCallViewData.calleeName = phoneNumber // Try to set phone number
        OutgoingCallViewData.statusLabel = statusLabel
        OutgoingCallViewData.callTime = Date()
        OutgoingCallViewData.phoneType = phoneType
        
        // Set namelabel with phone number
        nameLabel.text = OutgoingCallViewData.calleeName
       
        
//        OutgoingCallViewData.calleeName = calleeName
//        nameLabel.text = calleeName
//
        makeCall()
        //nameLabel.text = OutgoingCallViewData.phoneNumber
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        OutgoingCallVT.lct.call_state_changed = outgoingCallStateChanged
        linphone_core_add_listener(theLinphone.lc!,  &OutgoingCallVT.lct)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        linphone_core_remove_listener(theLinphone.lc!, &OutgoingCallVT.lct)
    }
    
    @IBAction func hangupButton(_ sender: Any) {
        OutgoingCallViewData.phoneType = CallPhoneType.call_END
        NSLog("OutgoingCallController.hangUp()")
        terminateCall()
    }
    
    func terminateCall(){
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            let result = linphone_core_terminate_call(theLinphone.lc!, call)
            NSLog("Terminated call result(outgoing): \(result)")
        }
        OutgoingCallViewData.controller?.dismiss(animated: false, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

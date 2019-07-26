//
//  OutgoingCallViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//
import UIKit
import CoreLocation
import CoreBluetooth

struct OutgoingCallViewData{
    static var controller: OutgoingCallViewController?
    static var phoneNumber: String?
    static var statusLabel: UILabel?
    static var calleeName: String?
    static var callConnected: Bool?
    static var retry: Bool = false
}

struct OutgoingCallVT{
    static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}

var outgoingCallStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallOutgoingProgress:
        NSLog("outgoingCallStateChanged: LinphoneCallProgress")
        if OutgoingCallViewData.retry == true{
            OutgoingCallViewData.retry = false
        }
    case LinphoneCallReleased:
        NSLog("outgoingCallStateChanged: LinphoneCallReleased")
        
    case LinphoneCallConnected:
        NSLog("outgoingCallStateChanged: LinphoneCallConnected")
        //OutgoingCallViewData.callType = CallLogType.outgoing_CALL_ANSWERED
        OutgoingCallViewData.controller?.statusLabel.text = "Connected"
        OutgoingCallViewData.callConnected = true

    case LinphoneCallError: /**<The call encountered an error, will not call LinphoneCallEnd*/
        NSLog("outgoingCallStateChanged: LinphoneCallError")
        OutgoingCallViewData.controller?.statusLabel.text = "Error"
        let message = String(cString: message!)
        NSLog(message)
        finishOutgoingCallView()
        
    case LinphoneCallEnd:
        NSLog("outgoingCallStateChanged: LinphoneCallEnd")
        OutgoingCallViewData.controller?.statusLabel.text = "EndCall"
        if OutgoingCallViewData.retry == false {
        finishOutgoingCallView()
        }
        
    default:
        NSLog("outgoingCallStateChanged: Default call state \(callSate)")
    }
}

func finishOutgoingCallView(){
    resetOutgoingCallData()
    OutgoingCallViewData.controller?.dismiss(animated: true, completion: nil)
}

func resetOutgoingCallData(){
    OutgoingCallViewData.callConnected = false
    OutgoingCallViewData.retry = false
}

class OutgoingCallViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var phoneNumber: String?
    var calleeName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("OutgoingCallController.viewDidLoad()")
        
        // Get data from view controller
        resetOutgoingCallData()
        OutgoingCallViewData.controller = self
        OutgoingCallViewData.phoneNumber = phoneNumber
        OutgoingCallViewData.calleeName = phoneNumber // Try to set phone number
        OutgoingCallViewData.statusLabel = statusLabel
        
        // Set namelabel with phone number
        nameLabel.text = "Call: " + OutgoingCallViewData.calleeName!
        
        // MAKE Phone call
        let lc = theLinphone.lc
        linphone_core_invite(lc, OutgoingCallViewData.phoneNumber)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Add CallStateChange listener
        OutgoingCallVT.lct.call_state_changed = outgoingCallStateChanged
        linphone_core_add_listener(theLinphone.lc!,  &OutgoingCallVT.lct)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Remove CallStateChange listener
        linphone_core_remove_listener(theLinphone.lc!, &OutgoingCallVT.lct)
        // Terminate Call First If it still have call
        terminateCall()
    }
    
    
    // MARK: Action
    @IBAction func hangupButton(_ sender: Any) {
        terminateCall()
    }
    
    // TerminateCall and closed OutgingCallViewData
    func terminateCall(){
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            let result = linphone_core_terminate_call(theLinphone.lc!, call)
            NSLog("Terminated call result(outgoing): \(result)")
        }
        OutgoingCallViewData.controller?.dismiss(animated: false, completion: nil)
    }
}


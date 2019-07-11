//
//  ReceiveCallViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//

import UIKit

struct ReceiveCallViewData{
    static var controller: ReceiveCallViewController?
    static var callTime: Date?
}

struct ReceiveCallVT {
    static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}

func finish(){
    let call = linphone_core_get_current_call(theLinphone.lc!)
    if call != nil {
        let result = linphone_core_terminate_call(theLinphone.lc!, call)
        NSLog("Terminated call result(receive): \(result)")
    }
    resetReceiveCallData()
    ReceiveCallViewData.controller?.dismiss(animated: false, completion: nil)
}

func resetReceiveCallData(){
    ReceiveCallViewData.callTime = nil
}

var receiveCallStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallConnected: /**<The call encountered an error*/
        NSLog("receiveCallStateChanged: LinphoneCallConnected")
        ReceiveCallViewData.controller?.statusLabel.text = "Connected"
        ReceiveCallViewData.controller?.showEndButton()
        
    case LinphoneCallError: /**<The call encountered an error*/
        NSLog("receiveCallStateChanged: LinphoneCallError")
        finish()
        
    case LinphoneCallEnd:
        NSLog("receiveCallStateChanged: LinphoneCallEnd")
        finish()
        
    default:
        NSLog("receiveCallStateChanged: Default call state")
    }
}

class ReceiveCallViewController: UIViewController {
    // UI Lable
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // UI Button
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSLog("ReceiveCallController.viewDidLoad()")
        endButton.isHidden = true
        ReceiveCallViewData.controller = self
        ReceiveCallViewData.callTime = Date()
        
        self.navigationItem.hidesBackButton = true
        
        let call = linphone_core_get_current_call(theLinphone.lc!)
        let address = linphone_call_get_remote_address_as_string(call)!
        let account = getUsernameFromAddress(String(cString: address))
        nameLabel.text = account
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // MARK: - Action
    @IBAction func answerCall(_ sender: Any) {
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            linphone_core_accept_call(theLinphone.lc!, call)
        }
    }
    
    @IBAction func endCall(_ sender: Any) {
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            linphone_core_terminate_call(theLinphone.lc!, call)
//            if ReceiveCallData.callType == .incoming_CALL_NO_ANSWER{
//                linphone_core_decline_call(theLinphone.lc!, call, LinphoneReasonDeclined)
//            }else{
//                linphone_core_terminate_call(theLinphone.lc!, call)
//            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NSLog("viewWillAppear: ")
        // Add CallStateChange function 
        ReceiveCallVT.lct.call_state_changed = receiveCallStateChanged
        linphone_core_add_listener(theLinphone.lc!, &ReceiveCallVT.lct)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NSLog("viewDidDisappear: ")
        linphone_core_remove_listener(theLinphone.lc!, &ReceiveCallVT.lct)
        
        //Check if have call still kill it
        let call = linphone_core_get_current_call(theLinphone.lc!)
        if call != nil {
            linphone_core_terminate_call(theLinphone.lc!, call)
//            if ReceiveCallData.callType == .incoming_CALL_NO_ANSWER{
//                linphone_core_decline_call(theLinphone.lc!, call, LinphoneReasonDeclined)
//            }else{
//                linphone_core_terminate_call(theLinphone.lc!, call)
//            }
        }
    }
    
    func showEndButton(){
        acceptButton.isHidden = true
        declineButton.isHidden = true
        endButton.isHidden = false
    }

}

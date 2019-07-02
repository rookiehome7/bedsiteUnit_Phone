//
//  ReceiveCallController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai on 30/6/19.
//  Copyright © 2019 WiAdvance. All rights reserved.
//

import UIKit
import Foundation

struct ReceiveCallData{
    static var controller: ReceiveCallController?
    static var callTime: Date?
}

struct ReceiveCallVT {
    static var lct: LinphoneCoreVTable = LinphoneCoreVTable()
}



var receiveCallStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallConnected: /**<The call encountered an error*/
        NSLog("receiveCallStateChanged: LinphoneCallConnected")
        ReceiveCallData.controller?.statusLabel.text = "Connected"
        ReceiveCallData.controller?.showEndButton()
        
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

func finish(){
    let call = linphone_core_get_current_call(theLinphone.lc!)
    if call != nil {
        let result = linphone_core_terminate_call(theLinphone.lc!, call)
        NSLog("Terminated call result(receive): \(result)")
    }
    
    resetReceiveCallData()
    ReceiveCallData.controller?.dismiss(animated: false, completion: nil)
}

func resetReceiveCallData(){
    ReceiveCallData.callTime = nil
}


class ReceiveCallController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ReceiveCallController.viewDidLoad()")
        endButton.isHidden = true
        ReceiveCallData.controller = self
        ReceiveCallData.callTime = Date()
        
        self.navigationItem.hidesBackButton = true
        
        let call = linphone_core_get_current_call(theLinphone.lc!)
        let address = linphone_call_get_remote_address_as_string(call)!
        let account = getUsernameFromAddress(String(cString: address))
        
        nameLabel.text = account

        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NSLog("ReceiveCallController.prepareForSegue()")
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

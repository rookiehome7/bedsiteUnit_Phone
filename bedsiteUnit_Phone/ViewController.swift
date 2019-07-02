//
//  ViewController.swift
//  linphone
//
//  Created by Takdanai on 27/6/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var setting: UIBarButtonItem!
    
    var linphoneManager: LinphoneManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.linphoneManager = LinphoneManager()
        self.performSegue(withIdentifier: "makeCall", sender: nil)
        // Do any additional setup after loading the view, typically from a nib.
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Navigation
    
    
    // MARK: Action
    @IBAction func callNurse101(_ sender: Any) {
        print("Call Nurse 101")
        linphoneManager?.makeCall(phoneNumber: "101")
        linphoneManager?.idle()
    }
    @IBAction func callNurse102(_ sender: Any) {
        print("Call Nurse 102")
        linphoneManager?.makeCall(phoneNumber: "102")
        linphoneManager?.idle()
    }
    @IBAction func callNurse103(_ sender: Any) {
        print("Call Nurse 103")
        linphoneManager?.makeCall(phoneNumber: "103")
        linphoneManager?.idle()
        
    }
    
    @IBAction func endCall(_ sender: Any) {
        print("EndCall")
        linphoneManager?.endCall()
        linphoneManager?.idle()
    }
    @IBAction func settingPage(_ sender: Any) {
        print("done!")
    }
    
    

}


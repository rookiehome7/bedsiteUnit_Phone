//
//  ViewController.swift
//  linphone-trial
//
//  Created by Cody Liu on 6/7/16.
//  Copyright © 2016 WiAdvance. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let VC : OutgoingCallViewController = segue.destination as! OutgoingCallViewController
//        VC.phoneNumber = "100"
        if segue.identifier == "makeCall"
        {
            if let destinationVC = segue.destination as? OutgoingCallViewController {
                destinationVC.phoneNumber = "100"
            }
        }
        

    }
    
}


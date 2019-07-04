//
//  ViewController.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 2/7/2562 BE.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeCall"
        {
            if let destinationVC = segue.destination as? OutgoingCallViewController {
                destinationVC.phoneNumber = "100"
            }
        }
    }
    
}


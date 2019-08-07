//
//  Localization.swift
//  bedside
//
//  Created by 邱天鈜 on 7/21/19.
//  Copyright © 2019 Tony_Qiu. All rights reserved.
//

import UIKit

class LocalizationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "btn_back", comment: "")
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        if segue.identifier == "English"
        {
            if let destinationVC = segue.destination as? defaultMessageViewController {
                destinationVC.language = "EN"
            }
        }
        else if segue.identifier == "Chinese"
        {
            if let destinationVC = segue.destination as? defaultMessageViewController {
                destinationVC.language = "CN"
            }
        }
        else { // Default Value 
            if let destinationVC = segue.destination as? defaultMessageViewController {
                destinationVC.language = "EN"
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }
    //    @IBAction func btnEnglish(_ sender: UIButton) {
    //    LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
    //        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "defaultMessageViewController") as? defaultMessageViewController
    //        vc!.languageSound = "EN"
    //        //self.navigationController?.pushViewController(vc!, animated: true)
    //        self.present(vc!, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func btnChinese(_ sender: UIButton) {
    //    LocalizationSystem.sharedInstance.setLanguage(languageCode: "zh-Hans")
    //        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "defaultMessageViewController") as? defaultMessageViewController
    //        vc!.languageSound = "CN"
    //        //self.navigationController?.pushViewController(vc!, animated: true)
    //        self.present(vc!, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func btnMalay(_ sender: UIButton) {
    //    LocalizationSystem.sharedInstance.setLanguage(languageCode: "ms")
    //    }
    //
    //    @IBAction func btnTamil(_ sender: UIButton) {
    //    LocalizationSystem.sharedInstance.setLanguage(languageCode: "ta-SG")
    //    }
    
}

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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnEnglish(_ sender: UIButton) {
    LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
    }
    
    @IBAction func btnChinese(_ sender: UIButton) {
    LocalizationSystem.sharedInstance.setLanguage(languageCode: "zh-Hans")
    }
    
    @IBAction func btnMalay(_ sender: UIButton) {
    LocalizationSystem.sharedInstance.setLanguage(languageCode: "ms")
    }
    
    @IBAction func btnTamil(_ sender: UIButton) {
    LocalizationSystem.sharedInstance.setLanguage(languageCode: "ta-SG")
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "btn_back", comment: "")
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
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

//
//  RecordIntention.swift
//  bedside
//
//  Created by 邱天鈜 on 7/21/19.
//  Edit by Takdanai Jirawanichkul on 24 July 2019
//  Copyright © 2019 Tony_Qiu. All rights reserved.
//
import UIKit

class RecordIntentionViewController: UIViewController {
    @IBOutlet weak var lblRecordIntention2: UILabel!
    @IBOutlet weak var lblRecordIntention1: UILabel!
    @IBOutlet weak var btnNoRecord: UIButton!
    @IBOutlet weak var btnYesRecord: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblRecordIntention1.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "label_record_prompt1", comment: "")
        lblRecordIntention1.adjustsFontSizeToFitWidth=true
        
        
        lblRecordIntention2.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "label_record_prompt2", comment: "")
        lblRecordIntention2.adjustsFontSizeToFitWidth=true

        
        btnYesRecord.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "btn_yes", comment: ""), for: .normal)
        btnYesRecord.titleLabel?.adjustsFontSizeToFitWidth=true
        
        btnNoRecord.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "btn_use_default", comment: ""), for: .normal)
        btnNoRecord.titleLabel?.adjustsFontSizeToFitWidth=true
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "btn_back", comment: "")
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
        
    }
}

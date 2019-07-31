//
//  CompletePrompt.swift
//  bedside
//
//  Created by 邱天鈜 on 7/23/19.
//  Edit by Takdanai Jirawanichkul on 24 July 2019
//  Copyright © 2019 Tony_Qiu. All rights reserved.
//
import UIKit
class CompletePromptViewController : UIViewController {
    @IBOutlet weak var lblComplete: UILabel!
    @IBOutlet weak var lblThx: UILabel!

    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        lblComplete.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "label_complete", comment: "")
        lblThx.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "label_thx", comment: "")
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(showVC), userInfo: nil, repeats: false)
    }
    
    @objc func showVC() {
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewNavigationController")
        self.present(nextViewController, animated:true, completion:nil)
    }
}



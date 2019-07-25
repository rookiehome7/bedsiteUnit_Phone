//
//  NewRecordingPageViewController.swift
//  bedsiteUnit_Phone
//
//  Created by 邱天鈜 on 7/25/19.
//  Copyright © 2019 WiAdvance. All rights reserved.
//

import UIKit

class NewRecordingPageViewController: UIViewController {
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnRerecord: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var lblHold: UILabel!
    @IBOutlet weak var lblRerecord: UILabel!
    @IBOutlet weak var lblConfirm: UILabel!
    
    var timer: Timer?
    
    @objc func recordButtonDown(_ sender: UIButton) {
        //addPulse()
        //timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(addPulse), userInfo: nil, repeats: true)
    }
    
    @objc func recordButtonUp(_ sender: UIButton) {
        timer?.invalidate()
        playbackLayout()
    }
    
    @objc func addPulse(){
        let pulse = Pulsing(numberOfPulses: 1, radius: 250, position: btnRecord.center)
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.init(red: 9/255, green: 201/255, blue: 194/255, alpha: 1).cgColor
        
        self.view.layer.insertSublayer(pulse, below: btnRecord.layer)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordLayout()
        btnFitShape(button: btnRecord)
        btnRecord.addTarget(self, action: #selector(recordButtonDown), for: .touchDown)
        btnRecord.addTarget(self, action: #selector(recordButtonUp), for: [.touchUpInside, .touchUpOutside])
        // Do any additional setup after loading the view.
        
    }
    
    func btnFitShape(button: UIButton){
        button.layer.cornerRadius = button.frame.size.width/2
    }
    
    
    
    func recordLayout(){
        
        btnRecord.isHidden = false
        btnPlay.isHidden = true
        btnRerecord.isHidden = true
        btnConfirm.isHidden = true
        lblHold.isHidden = false
        lblConfirm.isHidden = true
        lblRerecord.isHidden = true
    }
    
    func playbackLayout(){
        
        btnRecord.isHidden = true
        btnPlay.isHidden = false
        btnRerecord.isHidden = false
        btnConfirm.isHidden = false
        lblHold.isHidden = true
        lblConfirm.isHidden = false
        lblRerecord.isHidden = false
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

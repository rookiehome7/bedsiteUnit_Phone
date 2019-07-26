//
//  defaultMessage.swift
//  bedside
//
//  Created by 邱天鈜 on 7/23/19.
//  Edit by Takdanai Jirawanichkul on 24 July 2019
//  Copyright © 2019 Tony_Qiu. All rights reserved.
//

import UIKit
import AVFoundation


class defaultMessageViewController : UIViewController{

    @IBOutlet var btnPlay: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    
    let soundManager = SoundManager() // Get function for manage sound file
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        btnPlay.layer.cornerRadius = btnPlay.frame.size.width / 2;
        btnConfirm.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "label_confirm", comment: ""), for: .normal)

    }
    
    // MARK: - Button
    @IBAction func PlayOrPause(_ sender: Any) {
        //getLocalFileList()
        if audioPlayer == nil {
            startPlayback()
        }
        else {
            finishPlayback()
        }
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        // Save sound file from default into waiting sound
        soundManager.copySound_Default_to_Waiting()
        // Go to next page
    }
    
    // MARK: - Playback
    func startPlayback() {
        let audioURL = soundManager.getDefaultSoundURL()
        do {
            btnPlay.setImage( UIImage.init(named: "pause"), for: .normal)
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            //playButton.isHidden = true
            // unable to play recording!
        }
    }
    func finishPlayback() {
        btnPlay.setImage( UIImage.init(named: "play"), for: .normal)
        audioPlayer = nil
    }
}

extension defaultMessageViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}

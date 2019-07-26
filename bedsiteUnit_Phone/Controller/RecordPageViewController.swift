//
//  RecordPage.swift
//  bedside
//
//  Created by 邱天鈜 on 7/22/19.
//  Edit by Takdanai Jirawanichkul on 24 July 2019
//  Copyright © 2019 Tony_Qiu. All rights reserved.
//

import UIKit
import AVFoundation

import FilesProvider

class RecordPageViewController : UIViewController {
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnRerecord: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var lblHold: UILabel!
    @IBOutlet weak var lblRerecord: UILabel!
    @IBOutlet weak var lblConfirm: UILabel!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var timer: Timer?
    
    let soundManager = SoundManager() // Get function for manage sound file
    
    let documentsProvider = LocalFileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordLayout()
        btnFitShape(button: btnRecord)
        btnRecord.addTarget(self, action: #selector(recordButtonDown), for: .touchDown)
        btnRecord.addTarget(self, action: #selector(recordButtonUp), for: [.touchUpInside, .touchUpOutside])
        
        //navigationController?.navigationBar.shadowImage = UIImage()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            //try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordLayout()
                    } else {
                        // failed to record
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    // MARK: User Interface
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
    
    @objc func addPulse(){
        let pulse = Pulsing(numberOfPulses: 1, radius: 250, position: btnRecord.center)
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.init(red: 9/255, green: 201/255, blue: 194/255, alpha: 1).cgColor
        self.view.layer.insertSublayer(pulse, below: btnRecord.layer)
    }
    
    func loadRecordingUI() {
//        recordButton.isHidden = false
//        recordButton.setTitle("Tap to Record", for: .normal)
    }
    
//    // MARK: Action Button
//    @IBAction func recordButtonPressed(_ sender: UIButton) {
//        if audioRecorder == nil {
//            startRecording()
//        } else {
//            finishRecording(success: true)
//        }
//    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if audioPlayer == nil {
            startPlayback()
        } else {
            finishPlayback()
        }
    }
    
    @objc func recordButtonDown(_ sender: UIButton) {
        startRecording()
        addPulse()
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(addPulse), userInfo: nil, repeats: true)
    }
    
    @objc func recordButtonUp(_ sender: UIButton) {
        finishRecording(success: true)
        timer?.invalidate()
        // bplaybackLayout()
    }
    
    @IBAction func reRecordButton(_ sender: Any) {
        recordLayout()
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        // Save sound file from record into waiting sound
        soundManager.copySound_Record_to_Waiting()
        // Go to next page
    }
    
    // MARK: - Recording
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(soundManager.getRecordSoundName())
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            playbackLayout()
        }
        else {
            recordLayout()
        }
    }
    
    // MARK: - Playback
    func startPlayback() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(soundManager.getRecordSoundName())
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            audioPlayer.play()
            btnPlay.setImage( UIImage.init(named: "pause"), for: .normal)
        } catch {
            btnPlay.isHidden = true
            // unable to play recording!
        }
    }
    func finishPlayback() {
        audioPlayer = nil
        btnPlay.setImage( UIImage.init(named: "play"), for: .normal)
    }
    
}

extension RecordPageViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

extension RecordPageViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}

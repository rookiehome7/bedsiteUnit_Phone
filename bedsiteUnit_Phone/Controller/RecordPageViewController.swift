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
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    let soundManager = SoundManager() // Get function for manage sound file
    
    let documentsProvider = LocalFileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationController?.navigationBar.shadowImage = UIImage()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            //try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }

    func loadRecordingUI() {
        recordButton.isHidden = false
        recordButton.setTitle("Tap to Record", for: .normal)
    }
    
    // MARK: Action Button
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if audioPlayer == nil {
            startPlayback()
        } else {
            finishPlayback()
        }
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        // Save sound file from record into waiting sound
        soundManager.copySound_Record_to_Waiting()
        // Go to next page
    }
    
    // MARK: - Recording
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
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
            
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            playButton.setTitle("Play Your Recording", for: .normal)
            playButton.isHidden = false
        }
        else {
            recordButton.setTitle("Tap to Record", for: .normal)
            playButton.isHidden = true
            // recording failed :(
        }
    }
    // MARK: - Playback
    func startPlayback() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            audioPlayer.play()
            playButton.setTitle("Stop Playback", for: .normal)
        } catch {
            playButton.isHidden = true
            // unable to play recording!
        }
    }
    func finishPlayback() {
        audioPlayer = nil
        playButton.setTitle("Play Your Recording", for: .normal)
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

//
//  ViewController.swift
//  Audio Recording
//
//  Created by Ganesh Balaji Pawar on 07/08/19.
//  Copyright © 2019 Ganesh Balaji Pawar. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var minValue = 0.0
    let maxValue = 30.0
    
    
    @IBOutlet var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("allowed")
                    } else {
                        print("not allowed")
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }

    func startRecording() {
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            //recordButton.setTitle("Tap to Stop", for: .normal)
            
            //progress bar
            progressView.setProgress(Float(minValue), animated: true)
            perform(#selector(updateProgress), with: nil, afterDelay: 1)
        } catch {
            finishRecording(success: false)
        }
    }
    
    @objc func updateProgress(){
        
        minValue += 1
        progressView.progress = Float(minValue / maxValue)
        
        if minValue < maxValue{
            perform(#selector(updateProgress), with: nil, afterDelay: 1)
        }else{
            minValue = 0.0
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            //recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            //recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func recordTapped() {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func stopRecordTapped(_ sender: Any) {
        
        finishRecording(success: true)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        if let _ = URL(string: "recording.m4a") {
            
            // then lets create your document folder url
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let documentsDirectoryURL = getDocumentsDirectory()
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent("recording.m4a")
            
            //let url = Bundle.main.url(forResource: destinationUrl, withExtension: "mp3")!
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                guard let player = audioPlayer else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        audioPlayer.pause()
    }
    
    
}


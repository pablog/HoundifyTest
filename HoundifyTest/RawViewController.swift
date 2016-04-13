//
//  RawViewController.swift
//  HoundifyTest
//
//  Created by Pablo Giorgi on 4/5/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import UIKit

class RawViewController: UIViewController {
    
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    private let audioRecorder = AudioRecorder()
    private var audioPlayer = AudioPlayer()
    
    private let houndVoiceSearch = HoundVoiceSearch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationTitle()
        self.addButtonActions()
        
        self.initializeHound()
        self.initializeVoiceRecognizer()
    }
    
    func holdDown() {
        self.audioRecorder.initialize()
        self.audioRecorder.startRecording()
    }
    
    func holdRelease() {
        self.audioRecorder.stopRecording()
        self.audioPlayer.play(self.audioRecorder.audioURL())
        self.houndVoiceSearch.writeRawAudioData(NSData(contentsOfURL: self.audioRecorder.audioURL()))
    }
    
}

private extension RawViewController {
    
    func setNavigationTitle() {
        self.navigationItem.title = "Automatic mode"
    }
    
    func addButtonActions() {
        self.listenButton.addTarget(self, action: "holdDown", forControlEvents: UIControlEvents.TouchDown)
        self.listenButton.addTarget(self, action: "holdRelease", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
}

private extension RawViewController {
    
    func initializeHound() {
        Hound.setClientID("RlSQ5j_cDXQ-cRbi4Q3zsQ==")
        Hound.setClientKey("0zLAk--X9TJ2-1NeX5o8XSX5cZ3BexqFQiPjd_BOtfVO1cimWEebMiQ20x7xcHiUTcO50Kv4QroHwFXuuONgww==")
    }
    
    func initializeVoiceRecognizer() {
        self.houndVoiceSearch.setupRawModeWithInputSampleRate(Double(16000.0)) { (error) -> Void in
            NSLog("error: \(error)")
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(HoundVoiceSearchFinalTranscriptionNotification,
            object: nil, queue: nil) { notification in
                if let userInfo = notification.userInfo as? Dictionary<String,String> {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.textLabel.text = userInfo["finalTranscription"]
                    })
                }
        }

    }
    
}

//
//  AudioRecorder.swift
//  HoundifyTest
//
//  Created by Pablo Giorgi on 4/5/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import AVFoundation

final class AudioRecorder {

    private var audioSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    
}

extension AudioRecorder {
    
    func initialize() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            
        }
        
        do {
            try audioRecorder = AVAudioRecorder(URL: self.directoryURL()!, settings: recordSettings())
            audioRecorder.prepareToRecord()
        } catch {
            
        }
    }
    
    func startRecording() {
        if audioRecorder.recording {
            return
        }
        
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
            
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        
        do {
            try audioSession.setActive(false)
        } catch {

        }
    }
    
    func audioURL() ->  NSURL {
        return audioRecorder.url
    }
    
}

private extension AudioRecorder {
    
    func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        return soundURL
    }
    
    func recordSettings() -> [String: NSNumber] {
        return [AVSampleRateKey : NSNumber(float: Float(16000.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 1),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]
    }
    
}

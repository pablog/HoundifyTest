//
//  AudioPlayer.swift
//  HoundifyTest
//
//  Created by Pablo Giorgi on 4/5/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import AVFoundation

final class AudioPlayer {

    private var audioPlayer: AVAudioPlayer!
    
}

extension AudioPlayer {
    
    func play(audioURL: NSURL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: audioURL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            
        }
    }
    
}
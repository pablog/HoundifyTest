//
//  HoundifyService.swift
//  HoundifyTest
//
//  Created by Pablo Giorgi on 4/13/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import ReactiveCocoa
import Result
import CocoaLumberjackSwift

public enum ControlCommand: String {
    case PLAY, STOP, PAUSE, RESTART, PREVIOUS, NEXT, UNKNOWN
}

public final class HoundifyService {

    // This URL is just for development purposes...
    private static let HoundifySearchURL = "https://api.houndify.com/v1/audio"
    
    private let _houndVoiceSearch = HoundVoiceSearch()
    private let _notificationCenter = NSNotificationCenter.defaultCenter()
    
    // This signal sends values each time a command is detected...
    public let controlCommandSignal: Signal<ControlCommand, NoError>
    private let _controlCommandObserver: Signal<ControlCommand, NoError>.Observer
    
    // This signal sends values each time houndify starts / stops listening in the mic...
    public let voiceActiveSignal: Signal<Bool, NoError>
    private let _voiceActiveObserver: Signal<Bool, NoError>.Observer
    
    init() {
        (controlCommandSignal, _controlCommandObserver) = Signal<ControlCommand, NoError>.pipe()
        (voiceActiveSignal, _voiceActiveObserver) = Signal<Bool, NoError>.pipe()
        
        initializeHound()
        initializeVoiceRecognizer()
        subscribeToNotifications()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    func startSearch() {
        startServiceSearch()
    }
    
}

private extension HoundifyService {
    
    func initializeHound() {
        Hound.setClientID("RlSQ5j_cDXQ-cRbi4Q3zsQ==")
        Hound.setClientKey("0zLAk--X9TJ2-1NeX5o8XSX5cZ3BexqFQiPjd_BOtfVO1cimWEebMiQ20x7xcHiUTcO50Kv4QroHwFXuuONgww==")
    }
    
    func initializeVoiceRecognizer() {
        _houndVoiceSearch.enableHotPhraseDetection = true
        _houndVoiceSearch.enableEndOfSpeechDetection = true
        _houndVoiceSearch.enableSpeech = false
        
        _houndVoiceSearch.startListeningWithCompletionHandler { error in
            if (error == nil) {
                DDLogInfo("Start listening completed successfuly")
            } else {
                DDLogInfo("Start listening completed with error: \(error)")
            }
        }
    }
    
    func startServiceSearch() {
        DDLogInfo("Houndify started listening in the mic")
        self._voiceActiveObserver.sendNext(true)
        let endPointURL = NSURL(string: HoundifyService.HoundifySearchURL)
        _houndVoiceSearch.startSearchWithRequestInfo(nil, endPointURL: endPointURL) {
            [unowned self] (error, responseType, response, dictionary) -> Void in
            // When the voice search starts and ends, this value is sent
            // in the voice active signal to inform this condition.
            if (responseType == .HoundServer) {
                DDLogInfo("Houndify ended listening in the mic")
                self._voiceActiveObserver.sendNext(false)
            }
        }
    }
    
    /// Based on a transcription, it returns the ControlCommand that best matches.
    /// In case the transcription doens't match any, it returns UNKNOWN as default.
    func controlCommandFromTranscription(transcription: String) -> ControlCommand {
        // Here, a better transformation can be done.
        // i.e. if transcriptions is not exactly a rawValue, but contains it, it can be enough.
        let controlCommand = ControlCommand(rawValue: transcription)
        return controlCommand ?? ControlCommand.UNKNOWN
    }
    
}

private extension HoundifyService {
    
    func subscribeToNotifications() {
        // This block is called each time the `hot phrase` is said.
        _notificationCenter.addObserverForName(HoundVoiceSearchHotPhraseNotification) { _ in
            self.startSearch()
        }
        
        // This block is called each time Houndify returns a value with a transcription of 
        // what it heard.
        // It can be a temporal or final answer.
        _notificationCenter.addObserverForName(HoundVoiceSearchFinalTranscriptionNotification) {
            [unowned self] notification in
            if let userInfo = notification.userInfo as? Dictionary<String,String> {
                // When the transcript arrives, it is converted to a ControlCommand and sent
                // in the control command signal.
                let transcript = userInfo["finalTranscription"]!
                DDLogInfo("Transcript successfuly found: \(transcript)")
                let controlCommand = self.controlCommandFromTranscription(transcript)
                self._controlCommandObserver.sendNext(controlCommand)
            }
        }
    }
    
    func unsubscribeFromNotifications() {
        _notificationCenter.removeObserver(self)
    }

}

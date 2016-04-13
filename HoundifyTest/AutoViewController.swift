//
//  AutoViewController.swift
//  HoundifyTest
//
//  Created by Pablo Giorgi on 4/5/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

class AutoViewController: UIViewController {
    
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let houndVoiceSearch = HoundVoiceSearch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationTitle()
        self.addButtonActions()
        
        self.initializeHound()
        self.initializeVoiceRecognizer()
        self.subscribeToNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.unsubscribeFromNotifications()
    }
    
    func listenPressed() {
        self.startSearch()
    }
    
}

private extension AutoViewController {
    
    func setNavigationTitle() {
        self.navigationItem.title = "Automatic mode"
    }
    
    func addButtonActions() {
        self.listenButton.addTarget(self, action: "listenPressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
}

private extension AutoViewController {
    
    func initializeHound() {
        Hound.setClientID("RlSQ5j_cDXQ-cRbi4Q3zsQ==")
        Hound.setClientKey("0zLAk--X9TJ2-1NeX5o8XSX5cZ3BexqFQiPjd_BOtfVO1cimWEebMiQ20x7xcHiUTcO50Kv4QroHwFXuuONgww==")
    }
    
    func initializeVoiceRecognizer() {
        houndVoiceSearch.enableHotPhraseDetection = true
        houndVoiceSearch.enableEndOfSpeechDetection = true
        houndVoiceSearch.enableSpeech = false
        
        houndVoiceSearch.startListeningWithCompletionHandler { (error) -> Void in
            NSLog("Started listening with error: \(error)")
        }
    }
    
    func startSearch() {
        let endPointURL = NSURL(string: "https://api.houndify.com/v1/audio")
        houndVoiceSearch.startSearchWithRequestInfo(nil, endPointURL: endPointURL) {
            (error, responseType, response, dictionary) -> Void in

            if (!self.activityIndicatorView.isAnimating()) {
                // This if clause is to avoid animating it every time
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicatorView.startAnimating()
                })
            }
            
            if (responseType == .HoundServer) {
                // The search is completed.
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicatorView.stopAnimating()
                })
            }
        }
    }
    
    func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(HoundVoiceSearchFinalTranscriptionNotification,
            object: nil, queue: nil) { notification in
                if let userInfo = notification.userInfo as? Dictionary<String,String> {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.textLabel.text = userInfo["finalTranscription"]
                    })
                }
            }
        
        NSNotificationCenter.defaultCenter().addObserverForName(HoundVoiceSearchHotPhraseNotification,
            object: nil, queue: nil) { notification in
                self.startSearch()
            }
    }
    
    func unsubscribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

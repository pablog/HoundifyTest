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
    
    private let _houndifyService = HoundifyService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationTitle()
        self.addButtonActions()
        
        _houndifyService.controlCommandSignal.observeNext { controlCommand in
            NSLog("Llego un control command: \(controlCommand)")
        }
        
        _houndifyService.voiceActiveSignal.observeNext { voiceActive in
            NSLog("Voice has changed state: \(voiceActive)")
        }
    }
    
    func listenPressed() {
        _houndifyService.startSearch()
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

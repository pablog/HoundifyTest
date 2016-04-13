//
//  NSNotificationCenterExtension.swift
//  HoundifyTest
//
//  Created by Pablo Giorgi on 4/13/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

public extension NSNotificationCenter {
    
    public func addObserverForName(name: String?, usingBlock:(NSNotification) -> Void) {
        self.addObserverForName(name, object: nil, queue: nil, usingBlock: usingBlock)
    }
    
}

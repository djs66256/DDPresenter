//
//  MyPureServiceService.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

protocol MyPureServiceListener: AnyObject {
    func pureServiceResultDidChange(_ service: MyPureService)
}

protocol MyPureService: Service {
    var result: Int { get }
    func add(_ value: Int)
    
    func addListener(_ listener: MyPureServiceListener)
    func removeListener(_ listener: MyPureServiceListener)
}

class MyPureServiceImpl: MyPureService {
    var result: Int = 0 {
        didSet {
            for listener in listeners {
                listener.pureServiceResultDidChange(self)
            }
        }
    }
    
    func add(_ value: Int) {
        result += value
    }
    
    var listeners: [MyPureServiceListener] = []
    
    func addListener(_ listener: MyPureServiceListener) {
        listeners.append(listener)
    }
    
    func removeListener(_ listener: MyPureServiceListener) {
        listeners.removeAll { $0 === listener }
    }
}

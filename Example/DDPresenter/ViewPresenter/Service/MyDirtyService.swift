//
//  MyDirtyServiceService.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

protocol MyDirtyServiceNotification {
    func dirtyServiceResultDidChange(_ service: MyDirtyService)
}

protocol MyDirtyService: Service {
    @MainActor var result: Int { get }
    @MainActor func add(_ value: Int)
}

class MyDirtyServiceImpl: DirtyService, MyDirtyService {
    var result: Int = 0 {
        didSet {
            notifyGlobal(listener: MyDirtyServiceNotification.self) {
                $0.dirtyServiceResultDidChange(self)
            }
        }
    }
    
    func add(_ value: Int) {
        result += value + (getService(MyPureService.self)?.result ?? 0)
    }
}

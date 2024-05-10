//
//  MyServicePresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

struct MyServiceViewState: ViewState {
    var pureResult: Int = 0
    var dirtyResult: Int = 0
}

class MyServicePresenter: RootViewStatePresenter<MyServiceView, MyServiceViewState>, MyServiceViewDelegate {
    
    typealias View = MyServiceView
    typealias ViewState = MyServiceViewState
    
    override func onAttach() {
        super.onAttach()
        
        getService(MyPureService.self)?.addListener(self)
    }
    
    override func onDetach() {
        super.onDetach()
        
        getService(MyPureService.self)?.removeListener(self)
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        
        view.delegate = self
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        
        view?.delegate = nil
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.state = state
    }
    
    func myServiceViewAddPureValue(_ view: MyServiceView, value: Int) {
        getService(MyPureService.self)?.add(value)
    }
    
    func myServiceViewAddDirtyValue(_ view: MyServiceView, value: Int) {
        getService(MyDirtyService.self)?.add(value)
    }
}

extension MyServicePresenter: MyPureServiceListener, MyDirtyServiceNotification {
    func pureServiceResultDidChange(_ service: MyPureService) {
        setState { $0.pureResult = service.result }
    }
    
    func dirtyServiceResultDidChange(_ service: MyDirtyService) {
        setState { $0.dirtyResult = service.result }
    }
}

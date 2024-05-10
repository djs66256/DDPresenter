//
//  MyStatefulPresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

struct MyStatefulViewState: ViewState {
    var count = 0
}

class MyStatefulPresenter: RootViewStatePresenter<MyStatefulView, MyStatefulViewState>, MyStatefulViewDelegate {
    typealias View = MyStatefulView
    typealias ViewState = MyStatefulViewState
    
    override func onAttach() {
        super.onAttach()
        
        // create children presenters
        // get service and add listeners
    }
    
    override func onDetach() {
        super.onDetach()
        
        // remove service listeners
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
    
    func myStatefulViewDidTap(_ view: MyStatefulView) {
        setState { state in
            state.count += 1
        }
    }
}

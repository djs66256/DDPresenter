//
//  MyAnimationPresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

struct MyAnimationViewState: ViewState {
    var normalProgress: Double = 0
    var springProgress: Double = 0
}

class MyAnimationPresenter: RootViewStatePresenter<MyAnimationView, MyAnimationViewState>, MyAnimationViewDelegate {
    typealias View = MyAnimationView
    typealias ViewState = MyAnimationViewState
    
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
    
    func myAnimationViewDidTapNormal(_ view: MyAnimationView) {
        setState { $0.normalProgress = 1 - $0.normalProgress } context: { context in
            context.animated = true
            context.layoutIfNeeded = true
            context.animator = UIViewDefaultAnimator(duration: 1)
        }
    }
    
    func myAnimationViewDidTapSpring(_ view: MyAnimationView) {
        setState { $0.springProgress = 1 - $0.springProgress } context: { context in
            context.animated = true
            context.layoutIfNeeded = true
            context.animator = UIViewSpringAnimator(duration: 1, bounce: 0.5, initialSpringVelocity: 1)
        }
    }
}

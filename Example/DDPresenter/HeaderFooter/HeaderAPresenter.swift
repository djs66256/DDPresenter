//
//  HeaderAPresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/9/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class HeaderAPresenter: UICollectionViewFlowItemSelfHolderPresenter<HeaderAReusableView> {
    typealias View = HeaderAReusableView
    
    struct State {
        var text: String = ""
    }
    
    @MainActor var state: State = State() {
        didSet {
            setState {}
        }
    }
    
    required init() {
        super.init()
        
        layoutInfo.calculateSizeAutomatically = false
    }
    
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 40)
    }
    
    override func onUpdate(view: HeaderAReusableView, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.label.text = state.text
    }
}

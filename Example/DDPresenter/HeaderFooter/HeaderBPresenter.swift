//
//  HeaderBPresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/9/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class HeaderBPresenter: UICollectionViewFlowItemSelfHolderPresenter<HeaderBReusableView> {
    typealias View = HeaderBReusableView
    
    
    required init() {
        super.init()
        
        layoutInfo.calculateSizeAutomatically = false
    }
    
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 60)
    }
    
}

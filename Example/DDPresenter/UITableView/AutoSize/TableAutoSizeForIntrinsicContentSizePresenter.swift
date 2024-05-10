//
//  TableAutoSizeForIntrinsicContentSizePresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class TableAutoSizeForIntrinsicContentSizePresenter: UITableViewCellSelfHolderPresenter<TableAutoSizeForIntrinsicContentSizeTableCell>, UITableViewAutoSizeNotification {
    typealias View = TableAutoSizeForIntrinsicContentSizeTableCell
    
    required init() {
        super.init()
        
        layoutInfo.calculateSizeAutomatically = true
        layoutInfo.layoutType = .intrinsicContentSize
    }
    
    @MainActor var isLarge: Bool = false {
        didSet {
            setState {} context: { ctx in
                ctx.invalidateContentSize = true
                ctx.animated = true
            }
        }
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.isDetail = isLarge
    }
    
    func styleSwitchToLarge(_ large: Bool) {
        self.isLarge = large
    }
}

//
//  TableDiffBlockPresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter
import RandomColorSwift

class TableDiffBlockPresenter: UITableViewCellSelfHolderPresenter<TableDiffBlockTableCell> {
    typealias View = TableDiffBlockTableCell
    
    struct State {
        var index: Int = 0
        var color = randomColor()
    }
    
    @MainActor var state = State() {
        didSet {
            setState {}
        }
    }
    
    init(index: Int) {
        super.init()
        
        self.state.index = index
        self.layoutInfo.calculateSizeAutomatically = false
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func calculateHeight(containerSize: CGSize) -> CGFloat {
        return 44
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.label.text = "\(state.index)"
        view.backgroundColor = state.color
    }
}

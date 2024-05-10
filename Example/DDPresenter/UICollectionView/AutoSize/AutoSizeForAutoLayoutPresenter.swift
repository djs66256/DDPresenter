//
//  AutoSizeForAutoLayoutPresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

fileprivate let smallText = "We Reached the South Side of Pinnacle Ridge… What’s Next?"
fileprivate let largeText = """
We planned quite a drive on Wednesday, with lots of twists and turns over very bumpy terrain, so the team was delighted to learn everything completed as planned when we received our downlink at ~4 am Pacific Time this morning! The successful drive means Curiosity is now parked on the south side of Pinnacle Ridge, the final area of upper Gediz Vallis ridge that we planned to investigate before we cross Gediz Vallis channel. We visited the north side of Pinnacle Ridge last week and collected all sorts of data that tell us a lot about the composition and textures of the rocks that form the ridge.

We had a big decision to make this morning: Now that we can see the south side of Pinnacle Ridge is traversable, should we drive onto it to get additional contact science data on the Gediz Vallis ridge rocks, or should we continue to drive along Gediz Vallis channel towards our planned channel crossing spot? Driving onto Pinnacle Ridge at this location could give us an opportunity to learn more about the materials that make up the ridge and the role of water in this area, but it could also take several sols and not tell us much more than what we already learned from our investigation on the north face of Pinnacle Ridge.
"""

class AutoSizeForAutoLayoutPresenter: UICollectionViewFlowItemSelfHolderPresenter<AutoSizeForAutoLayoutCell>, UICollectionViewAutoSizeNotification {
    typealias View = AutoSizeForAutoLayoutCell
    
    required init() {
        super.init()
        
        layoutInfo.calculateSizeAutomatically = true
        layoutInfo.layoutType = .autoLayout
    }
    
    @MainActor var text: String = smallText {
        didSet {
            setState {} context: { ctx in
                ctx.invalidateContentSize = true
                ctx.animated = true
            }
        }
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.label.text = text
    }
    
    func styleSwitchToLarge(_ large: Bool) {
        text = large ? largeText : smallText
    }
}

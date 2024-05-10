//
//  AutoSizeForIntrinsicContentSizeCell.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class AutoSizeForIntrinsicContentSizeCell: UICollectionViewCell {
    
    var isDetail: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemRed
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: isDetail ? 200 : 100)
    }
}

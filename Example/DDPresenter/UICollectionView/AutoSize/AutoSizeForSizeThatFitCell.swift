//
//  AutoSizeForSizeThatFitCell.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class AutoSizeForSizeThatFitCell: UICollectionViewCell {
    
    var isDetail: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemGreen
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: isDetail ? 200 : 100)
    }
}

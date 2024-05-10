//
//  DiffBlockCell.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class DiffBlockCell: UICollectionViewCell {
    
    lazy var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.textColor = .black
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

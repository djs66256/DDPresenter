//
//  AutoSizeForAutoLayoutCell.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class AutoSizeForAutoLayoutCell: UICollectionViewCell {
    
    lazy var label = UILabel()
    lazy var button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black.withAlphaComponent(0.1)

        label.numberOfLines = 0
        contentView.addSubview(label)
        
        button.setTitle("Go to", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        contentView.addSubview(button)
        
        label.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(button.snp.top).offset(-20)
        }
        
        button.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//
//  HeaderAReusableView.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/9/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class HeaderAReusableView: UICollectionReusableView {
    
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .blue
        
        label.text = "Header A"
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

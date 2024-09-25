//
//  HeaderBReusableView.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/9/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class HeaderBReusableView: UICollectionReusableView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .yellow
        
        label.text = "Header B"
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

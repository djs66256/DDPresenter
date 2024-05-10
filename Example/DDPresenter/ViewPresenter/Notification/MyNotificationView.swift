//
//  MyNotificationView.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class MyNotificationView: UIView {
    
    lazy var label = UILabel()
    lazy var input = UITextField()
    lazy var line = UIView()
    lazy var resultLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        label.font = .systemFont(ofSize: 24)
        label.text = "Send message: "
        addSubview(label)
        
        input.font = .boldSystemFont(ofSize: 32)
        input.placeholder = "Text Input:"
        input.text = ""
        input.layer.borderColor = UIColor.systemBlue.cgColor
        input.layer.borderWidth = 1
        addSubview(input)
        
        line.backgroundColor = .gray
        addSubview(line)
        
        resultLabel.font = .boldSystemFont(ofSize: 24)
        resultLabel.textAlignment = .left
        resultLabel.numberOfLines = 0
        addSubview(resultLabel)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(100)
            make.left.right.equalToSuperview().inset(10)
        }
        
        input.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(input.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(1)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(10)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  MyStatefulView.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

protocol MyStatefulViewDelegate: AnyObject {
    func myStatefulViewDidTap(_ view: MyStatefulView)
}

class MyStatefulView: UIView {
    
    weak var delegate: MyStatefulViewDelegate?
    
    lazy var label = UILabel()
    lazy var button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white

        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 48)
        addSubview(label)
        
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 32)
        button.addTarget(self, action: #selector(self.onButton), for: .touchUpInside)
        addSubview(button)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(100)
            make.left.right.equalToSuperview().inset(10)
        }
        
        button.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-100)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var state = MyStatefulViewState() {
        didSet {
            label.text = "\(state.count)"
        }
    }
    
    @objc func onButton() {
        delegate?.myStatefulViewDidTap(self)
    }
}

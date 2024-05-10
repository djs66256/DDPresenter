//
//  MyServiceView.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

protocol MyServiceViewDelegate: AnyObject {
    func myServiceViewAddPureValue(_ view: MyServiceView, value: Int)
    func myServiceViewAddDirtyValue(_ view: MyServiceView, value: Int)
}

class MyServiceView: UIView {
    class InputView: UIView {
        let label = UILabel()
        let input = UITextField()
        let resultLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            label.font = .systemFont(ofSize: 24)
            label.numberOfLines = 0
            addSubview(label)
            
            input.font = .boldSystemFont(ofSize: 32)
            input.text = "1"
            input.layer.borderColor = UIColor.systemBlue.cgColor
            input.layer.borderWidth = 1
            addSubview(input)
            
            resultLabel.font = .boldSystemFont(ofSize: 24)
            addSubview(resultLabel)
            
            label.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
            }
            
            input.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(5)
                make.left.bottom.equalToSuperview()
                make.right.equalTo(resultLabel.snp.left).offset(-5)
            }
            
            resultLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            resultLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            resultLabel.snp.makeConstraints { make in
                make.bottom.right.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    weak var delegate: MyServiceViewDelegate?
    lazy var pureInputView = InputView()
    lazy var dirtyInputView = InputView()
    lazy var button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        
        pureInputView.label.text = "Pure service add : "
        addSubview(pureInputView)
        
        dirtyInputView.label.text = "Dirty service add Pure value and : "
        addSubview(dirtyInputView)
        
        button.titleLabel?.font = .boldSystemFont(ofSize: 32)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Caculate", for: .normal)
        button.addTarget(self, action: #selector(self.onButton), for: .touchUpInside)
        addSubview(button)
        
        pureInputView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(100)
            make.left.right.equalToSuperview().inset(10)
        }
        
        dirtyInputView.snp.makeConstraints { make in
            make.top.equalTo(pureInputView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(10)
        }
        
        button.snp.makeConstraints { make in
            make.top.equalTo(dirtyInputView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var state = MyServiceViewState() {
        didSet {
            pureInputView.resultLabel.text = " = \(state.pureResult)"
            dirtyInputView.resultLabel.text = " = \(state.dirtyResult)"
        }
    }
    
    @objc func onButton() {
        delegate?.myServiceViewAddPureValue(self, value: Int(pureInputView.input.text ?? "") ?? 0)
        delegate?.myServiceViewAddDirtyValue(self, value: Int(dirtyInputView.input.text ?? "") ?? 0)
    }
}

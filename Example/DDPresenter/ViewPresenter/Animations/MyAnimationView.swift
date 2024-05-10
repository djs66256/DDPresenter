//
//  MyAnimationView.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

protocol MyAnimationViewDelegate: AnyObject {
    func myAnimationViewDidTapNormal(_ view: MyAnimationView)
    func myAnimationViewDidTapSpring(_ view: MyAnimationView)
}

class MyAnimationView: UIView {
    
    class TrackView: UIView {
        static let blockSize = CGSize(width: 40, height: 40)
        lazy var block = UIView()
        
        var progress: CGFloat = 0 {
            didSet {
                if oldValue != progress {
                    setNeedsLayout()
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .black.withAlphaComponent(0.1)
            block.backgroundColor = .systemRed
            addSubview(block)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            block.frame = CGRect(x: (self.frame.width - Self.blockSize.width) * progress,
                                 y: 0,
                                 width: Self.blockSize.width,
                                 height: Self.blockSize.height)
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            CGSize(width: max(size.width, Self.blockSize.width), height: max(size.height, Self.blockSize.height))
        }
        
        override var intrinsicContentSize: CGSize {
            CGSize(width: UIView.noIntrinsicMetric, height: Self.blockSize.height)
        }
    }
    
    weak var delegate: MyAnimationViewDelegate?
    lazy var normalTrack = TrackView()
    lazy var springTrack = TrackView()
    lazy var normalButton = UIButton()
    lazy var springButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(normalTrack)
        addSubview(springTrack)
        
        normalButton.setTitle("Perform Normal Animation", for: .normal)
        normalButton.setTitleColor(.systemBlue, for: .normal)
        normalButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        normalButton.addTarget(self, action: #selector(self.onNormalButton), for: .touchUpInside)
        addSubview(normalButton)
        
        springButton.setTitle("Perform Spring Animation", for: .normal)
        springButton.setTitleColor(.systemBlue, for: .normal)
        springButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        springButton.addTarget(self, action: #selector(self.onSpringButton), for: .touchUpInside)
        addSubview(springButton)
        
        normalTrack.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(100)
            make.left.right.equalToSuperview().inset(100)
            make.height.equalTo(TrackView.blockSize.height)
        }
        
        springTrack.snp.makeConstraints { make in
            make.top.equalTo(normalTrack.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(100)
            make.height.equalTo(TrackView.blockSize.height)
        }
        
        normalButton.snp.makeConstraints { make in
            make.top.equalTo(springTrack.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        springButton.snp.makeConstraints { make in
            make.top.equalTo(normalButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var state = MyAnimationViewState() {
        didSet {
            normalTrack.progress = state.normalProgress
            springTrack.progress = state.springProgress
        }
    }
    
    @objc func onNormalButton() {
        delegate?.myAnimationViewDidTapNormal(self)
    }
    
    @objc func onSpringButton() {
        delegate?.myAnimationViewDidTapSpring(self)
    }
}

//
//  UICollectionViewAutoSizeViewController.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

protocol UICollectionViewAutoSizeNotification {
    @MainActor func styleSwitchToLarge(_ large: Bool)
}

class UICollectionViewAutoSizeViewController: UICollectionFlowPageViewController {

    let section = UICollectionViewFlowSectionPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "switch", style: .plain, target: self, action: #selector(self.onSwitch))
        
        // Do any additional setup after loading the view.
        presenter.collectionViewPresenter.setSections([section])
        
        section.layoutInfo.apply {
            $0.inset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            $0.itemSpacing = 10
            $0.lineSpacing = 10
        }
        section.setItems([
            AutoSizeForAutoLayoutPresenter(),
            AutoSizeForIntrinsicContentSizePresenter(),
            AutoSizeForSizeThatFitPresenter()
        ])
    }

    var isLarge = false
    
    @objc func onSwitch() {
        isLarge = !isLarge
        notifyGlobal(listener: UICollectionViewAutoSizeNotification.self) {
            $0.styleSwitchToLarge(isLarge)
        }
    }
}

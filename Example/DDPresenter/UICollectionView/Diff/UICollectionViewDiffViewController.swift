//
//  UICollectionViewDiffViewController.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class UICollectionViewDiffViewController: UICollectionFlowPageViewController {

    let section = UICollectionViewFlowSectionPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "shuffle", style: .plain, target: self, action: #selector(self.onShuffle))
        
        // Do any additional setup after loading the view.
        presenter.collectionViewPresenter.setSections([section])
        section.layoutInfo.apply {
            $0.columnCount = 4
            $0.itemSpacing = 10
            $0.lineSpacing = 10
            $0.inset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        section.setItems((0...20).map({
            DiffBlockPresenter(index: $0)
        }))
    }

    @objc func onShuffle() {
        let randomItems = section.typedItems.shuffled()
        section.setItems(randomItems, animated: true)
    }
}

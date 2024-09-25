//
//  HeaderFooterViewController.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/9/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class HeaderFooterViewController: UICollectionFlowPageViewController {

    let section = UICollectionViewFlowSectionPresenter()

    override func presenterDidLoad() {
        super.presenterDidLoad()
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.minimumInteritemSpacing = 10
        
        let section2 = UICollectionViewFlowSectionPresenter()
        section2.items = [AutoSizeForSizeThatFitPresenter(), AutoSizeForSizeThatFitPresenter()]
        presenter.collectionViewPresenter.setSections([section, section2])
        section.items = [AutoSizeForSizeThatFitPresenter(), AutoSizeForSizeThatFitPresenter()]
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(self.onSwitch)),
            UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(self.onUpdate)),
        ]
    }

    var headerTag: Bool = false
    @objc func onSwitch() {
        headerTag.toggle()
        let header = headerTag ? HeaderAPresenter() : HeaderBPresenter()
        section.header = header
        
        let footer = !headerTag ? HeaderAPresenter() : HeaderBPresenter()
        section.footer = footer
        
        if headerTag {
            section.items.append(AutoSizeForSizeThatFitPresenter())
        } else {
            section.items.removeLast()
        }
    }
    
    var textTag: Bool = false
    @objc func onUpdate() {
        textTag.toggle()
        if let header = section.header as? HeaderAPresenter {
            header.state.text = textTag ? "Header A true": "Header A false"
        }
    }
}

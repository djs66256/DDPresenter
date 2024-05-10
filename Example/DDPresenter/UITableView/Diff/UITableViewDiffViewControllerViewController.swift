//
//  UITableViewDiffViewControllerViewController.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class UITableViewDiffViewControllerViewController: UITablePageDefaultViewController {

    let section = UITableViewSectionPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "shuffle", style: .plain, target: self, action: #selector(self.onShuffle))
        
        // Do any additional setup after loading the view.
        presenter.tableViewPresenter.setSections([section])
        
        section.setItems((0...10).map({
            TableDiffBlockPresenter(index: $0)
        }))
    }

    @objc func onShuffle() {
        let randomItems = section.typedItems.shuffled()
        section.setItems(randomItems, animated: true)
    }
}

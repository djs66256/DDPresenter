//
//  UITableViewAutoSizeViewControllerViewController.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

protocol UITableViewAutoSizeNotification {
    @MainActor func styleSwitchToLarge(_ large: Bool)
}

class UITableViewAutoSizeViewControllerViewController: UITablePageDefaultViewController {

    let section = UITableViewSectionPresenter()

    override func presenterDidLoad() {
        super.presenterDidLoad()
        
        // Do any additional setup after loading the presenter.
        
        // Register services.
        // register(service: TraceService.self) {
        //      TraceServiceImpl()
        // }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "switch", style: .plain, target: self, action: #selector(self.onSwitch))
        
        // Do any additional setup after loading the view.
        presenter.tableViewPresenter.setSections([section])
        
        section.setItems([
            TableAutoSizeForAutoLayoutPresenter(),
            TableAutoSizeForIntrinsicContentSizePresenter(),
            TableAutoSizeForSizeThatFitPresenter()
        ])
    }

    var isLarge = false
    
    @objc func onSwitch() {
        isLarge = !isLarge
        notifyGlobal(listener: UITableViewAutoSizeNotification.self) {
            $0.styleSwitchToLarge(isLarge)
        }
    }

}

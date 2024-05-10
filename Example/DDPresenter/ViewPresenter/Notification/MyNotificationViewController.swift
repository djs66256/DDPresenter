//
//  MyNotificationViewController.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class MyNotificationViewController: PageViewController<MyNotificationView, MyNotificationPresenter, MyNotificationView> {

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

        // Do any additional setup after loading the view.
    }

}

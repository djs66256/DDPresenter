//
//  MyServiceViewController.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

class MyServiceViewController: PageViewController<MyServiceView, MyServicePresenter, MyServiceView> {

    override func presenterDidLoad() {
        super.presenterDidLoad()
        
        // Do any additional setup after loading the presenter.
        
        // Register services.
        register(service: MyPureService.self) {
            MyPureServiceImpl()
        }
        register(service: MyDirtyService.self) {
            MyDirtyServiceImpl()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

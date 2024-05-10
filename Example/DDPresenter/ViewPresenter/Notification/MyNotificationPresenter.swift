//
//  MyNotificationPresenter.swift
//  DDPresenter_Example
//
//  Created by daniel on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DDPresenter

protocol MyTextNotification {
    @MainActor func myTextNotificationDidChange(_ text: String)
}

class MyNotificationEditingPresenter: ViewPresenter<UITextField> {
    
    var observer: Any?
    
    override func onBindView(_ view: UITextField) {
        super.onBindView(view)
        
        observer = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: .main) { [weak self] noti in
            guard let self, let view = self.view, (noti.object as? NSObject) === view else { return }
            notifyGlobal(listener: MyTextNotification.self) {
                $0.myTextNotificationDidChange(view.text ?? "")
            }
        }
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

class MyNotificationDisplayPresenter: ViewPresenter<UILabel>, MyTextNotification {
    
    @MainActor var text: String = "" {
        didSet {
            setState {}
        }
    }
    
    func myTextNotificationDidChange(_ text: String) {
        self.text = text
    }
    
    override func onUpdate(view: UILabel, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        view.text = "Received:\n\(text)"
    }
}

class MyNotificationPresenter: RootViewPresenter<MyNotificationView> {
    typealias View = MyNotificationView
    
    override func onAttach() {
        super.onAttach()
        
        typeBox(MyNotificationEditingPresenter())
        typeBox(MyNotificationDisplayPresenter())
    }
    
    override func onDetach() {
        super.onDetach()
        
        // remove service listeners
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        
        _ = unbox(type: MyNotificationDisplayPresenter.self)?.tryBindWeakView(view.resultLabel)
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        
        // view?.delegate = nil
    }
}

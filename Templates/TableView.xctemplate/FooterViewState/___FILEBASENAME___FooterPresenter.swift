//___FILEHEADER___

import UIKit
import DDPresenter

struct ___VARIABLE_productName___FooterViewState: ViewState {
    
}

class ___FILEBASENAME___: UITableViewHeaderFooterStatePresenter<___VARIABLE_productName___FooterView, ___VARIABLE_productName___FooterViewState> {
    typealias View = ___VARIABLE_productName___FooterView
    typealias ViewState = ___VARIABLE_productName___FooterViewState
    
    override func onAttachToRoot(_ presenter: RootViewPresentable) {
        super.onAttachToRoot(presenter)
        
        // Get service and add listeners
    }
    
    override func onDetachFromRoot(_ presenter: RootViewPresentable) {
        super.onDetachFromRoot(presenter)
        
        // Get service and remove listeners
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        
        // view.delegate = self
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        
        // view?.delegate = nil
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.state = state
    }
    
    // func update() {
    //      setState {
    //          $0.value = newValue
    //      }
    // }
    
    // func onDelegate() {
    //     getService(MyService.self)?.doSomething()
    //     notifyGlobal(listener: MyNotifier.self) {
    //         $0.onNotify()
    //     }
    // }
    
}

//___FILEHEADER___

import UIKit
import DDPresenter

struct ___VARIABLE_productName___ViewState: ViewState {
    
}

class ___FILEBASENAME___: RootViewStatePresenter<___VARIABLE_productName___View, ___VARIABLE_productName___ViewState> {
    typealias View = ___VARIABLE_productName___View
    typealias ViewState = ___VARIABLE_productName___ViewState
    
    override func onAttach() {
        super.onAttach()
        
        // create children presenters
        // get service and add listeners
    }
    
    override func onDetach() {
        super.onDetach()
        
        // remove service listeners
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

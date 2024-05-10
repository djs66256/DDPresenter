//___FILEHEADER___

import UIKit
import DDPresenter

struct ___VARIABLE_productName___ViewState: ViewState {
    
}

class ___FILEBASENAME___: UICollectionViewFlowItemSelfHolderStatePresenter<___VARIABLE_productName___Cell, ___VARIABLE_productName___ViewState> {
    typealias View = ___VARIABLE_productName___Cell
    typealias ViewState = ___VARIABLE_productName___ViewState
    
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
    
    override func onUnbindView(_ view: View) {
        super.onUnbindView(view)
        
        // view.delegate = nil
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

//___FILEHEADER___

import UIKit
import DDPresenter

class ___FILEBASENAME___: UICollectionViewFlowItemPresenterHolder<___VARIABLE_productName___Presenter, ___VARIABLE_productName___ReusableView> {
    typealias Presenter = ___VARIABLE_productName___Presenter
    
    override func onAttachToRoot(_ presenter: RootViewPresentable) {
        super.onAttachToRoot(presenter)
        
        // Get service and add listeners
    }
    
    override func onDetachFromRoot(_ presenter: RootViewPresentable) {
        super.onDetachFromRoot(presenter)
        
        // Get service and remove listeners
    }
    
    func onBindReusablePresenter(_ presenter: Presenter) {
        super.onBindReusablePresenter(presenter)
    }
    
    func onUnbindReusablePresenter(_ presenter: Presenter) {
        super.onUnbindReusablePresenter(presenter)
        
    }
    
    func onUpdate(presenter: Presenter, context: ViewUpdateContext) {
        super.onUpdate(presenter: presenter, context: context)
        // Update presenter state here
    }
    
    // func onDelegate() {
    //     getService(MyService.self)?.doSomething()
    //     notifyGlobal(listener: MyNotifier.self) {
    //         $0.onNotify()
    //     }
    // }
    
}

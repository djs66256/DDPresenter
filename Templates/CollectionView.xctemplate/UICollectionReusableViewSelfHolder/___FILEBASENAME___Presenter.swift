//___FILEHEADER___

import UIKit
import DDPresenter

class ___FILEBASENAME___: UICollectionViewFlowItemSelfHolderPresenter<___VARIABLE_productName___ReusableView> {
    typealias View = ___VARIABLE_productName___ReusableView
    
    @MainActor var state: Any? = nil {
        didSet {
            setState {}
        }
    }
    
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
        
        // Update view state here
    }
    
    // func onDelegate() {
    //     getService(MyService.self)?.doSomething()
    //     notifyGlobal(listener: MyNotifier.self) {
    //         $0.onNotify()
    //     }
    // }
    
}

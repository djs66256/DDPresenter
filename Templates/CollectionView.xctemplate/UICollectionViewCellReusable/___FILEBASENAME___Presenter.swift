//___FILEHEADER___

import UIKit
import DDPresenter

class ___FILEBASENAME___: UICollectionViewFlowReusableItemPresenter<___VARIABLE_productName___Cell> {
    typealias View = ___VARIABLE_productName___Cell
    
    @MainActor var state: Any? = nil {
        didSet {
            setState {}
        }
    }
    
    required init() {
        super.init()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear resources
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
    
    override func onUnbindView() {
        super.onUnbindView()
        
        // view?.delegate = nil
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

//___FILEHEADER___

import UIKit
import DDPresenter

class ___FILEBASENAME___: UITableViewCellPresenterHolder<___VARIABLE_productName___Presenter, ___VARIABLE_productName___TableCell> {
    typealias Presenter = ___VARIABLE_productName___Presenter
    
    override func onAttachToRoot(_ presenter: RootViewPresentable) {
        super.onAttachToRoot(presenter)
        
        // Get service and add listeners
    }
    
    override func onDetachFromRoot(_ presenter: RootViewPresentable) {
        super.onDetachFromRoot(presenter)
        
        // Get service and remove listeners
    }
    
    override func onBindReusablePresenter(_ presenter: Presenter) { }
    
    override func onUnbindReusablePresenter(_ presenter: Presenter) { }
    
    override open func onUpdate(presenter: Presenter, context: ViewUpdateContext) {
        super.onUpdate(presenter: presenter, context: context)
        
        // update presenter
    }
    
    // override func onWillDisplay() {}
    // override func onDidEndDisplaying() {}
    // override func onDidSelect() {}
}

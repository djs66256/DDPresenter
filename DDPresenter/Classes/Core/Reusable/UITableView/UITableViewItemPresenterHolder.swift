// MIT License
// 
// Copyright (c) 2024 Daniel
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public protocol UITableViewReusablePresenterHoldable: ReusableViewPresenterHoldable {
}

open class UITableViewReusablePresenterHolder: ReusableViewPresenterHolder, UITableViewReusablePresenterHoldable, UITableViewItemSizeCaculatable {
    public var itemClass: UIView.Type {
        fatalError("MUST override")
    }
    
    public var presenterClass: UITableViewReusableItemPresentable.Type {
        fatalError("MUST override")
    }
    
    public var usingReusablePresenterLayoutInfo: Bool = false
    
    public var layoutInfo = UITableViewCellLayoutInfo()
    
    open func calculateHeight(containerSize: CGSize) -> CGFloat { 0 }
    
    @MainActor func dryRunUpdateReusablePresenter(_ presenter: UITableViewReusableItemPresentable) -> Bool {
        return false
    }
    
    @MainActor var tableViewPresenter: UITableViewPresentable? {
        var p: Presenter? = superPresenter
        while p != nil {
            if let tp = p as? UITableViewPresentable {
                return tp
            }
            p = p?.superPresenter
        }
        return nil
    }
    
    @MainActor func findFrameInTableView() -> CGRect? {
        tableViewPresenter?.proxy?.rect(for: self)
    }
    
    @MainActor func selectInTableView(animated: Bool,
                           scrollPosition: UITableView.ScrollPosition) {
        tableViewPresenter?.proxy?.selectRow(for: self,
                                             animated: animated,
                                             scrollPosition: scrollPosition)
    }
    
    @MainActor func scrollToVisible(inset: UIEdgeInsets = .zero, animated: Bool) {
        tableViewPresenter?.proxy?.scrollToVisible(for: self, inset: inset, animated: animated)
    }
}


public protocol UITableViewCellPresenterHoldable: UITableViewReusablePresenterHoldable, UITableViewCellPresentable {}

open class UITableViewCellPresenterHolder<P, V>: UITableViewReusablePresenterHolder, UITableViewCellPresenterHoldable
where P: UITableViewReusableCellPresenter<V>, V: UITableViewCell {
    
    public override var itemClass: UIView.Type {
        V.self
    }
    
    public override var presenterClass: UITableViewReusableItemPresentable.Type {
        P.self
    }
    
    @MainActor open func onBindReusablePresenter(_ presenter: P) { }
    @MainActor open func onUnbindReusablePresenter(_ presenter: P) { }
    @MainActor open func onUpdate(presenter: P, context: ViewUpdateContext) { }
    
    @MainActor override func tryOnBindReusablePresenter(_ presenter: Presenter) {
        if let presenter = presenter as? P {
            onBindReusablePresenter(presenter)
        }
    }
    
    @MainActor override func tryOnUnbindReusablePresenter(_ presenter: Presenter) {
        if let presenter = presenter as? P {
            onUnbindReusablePresenter(presenter)
        }
    }
    
    @MainActor override func tryOnUpdate(presenter: Presenter, context: ViewUpdateContext) {
        if let presenter = presenter as? P {
            onUpdate(presenter: presenter, context: context)
        }
    }
    
    override func dryRunUpdateReusablePresenter(_ presenter: UITableViewReusableItemPresentable) -> Bool {
        if let presenter = presenter as? P {
            onUpdate(presenter: presenter, context: .dryRun)
            return true
        }
        return false
    }
    
    public var estimatedHeight: CGFloat = UITableView.automaticDimension
    // Display
    open func onWillDisplay() {}
    open func onDidEndDisplaying() {}
    
    // Highlight & select
    public var shouldHighlight: Bool = true
    open func onDidHighlight() {}
    open func onDidUnhighlight() {}
    public var shouldSelect: Bool = true
    open func onWillSelect() {}
    open func onDidSelect() {}
    public var shouldDeselect: Bool = true
    open func onWillDeselect() {}
    open func onDidDeselect() {}
    
    // Edit
    public var canEdit: Bool = false
    public var editStyle: UITableViewCell.EditingStyle = .none
    public var deleteConfirmationButtonTitle: String? = nil
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    public var editActions: [UITableViewRowAction]? = nil
    public var leadingSwipeActionsConfiguration: UISwipeActionsConfiguration? = nil
    public var trailingSwipeActionsConfiguration: UISwipeActionsConfiguration? = nil
    public var shouldIndentWhileEditing: Bool = false
    open func commitEditing(style: UITableViewCell.EditingStyle) {}
    open func onWillBeginEditing() {}
    open func onDidEndEditing() {}
    
    // Menu
    public var shouldShowMenu: Bool = false
    open func canPerformAction(action: Selector, with sender: Any?) -> Bool { false }
    open func performAction(action: Selector, with sender: Any?) {}
    
    // TODO: Focus
    
    // Mutliple selection
    public var shouldBeginMultipleSelectionInteraction: Bool = false
    open func didBeginMultipleSelectionInteraction() {}
    
    @MainActor public func deselectRow(animated: Bool) {
        tableViewPresenter?.proxy?.deselectRow(for: self, animated: animated)
    }
    
    @MainActor public func scrollToVisible(at position: UITableView.ScrollPosition, animated: Bool) {
        tableViewPresenter?.proxy?.scrollToRow(for: self, at: position, animated: animated)
    }
}

open class UITableViewReusableCellPresenter<View: UIView>: ReusableViewPresenter<View>, UITableViewReusableItemPresentable {
    public var layoutInfo = UITableViewCellLayoutInfo()
    
    open func calculateHeight(containerSize: CGSize) -> CGFloat { 0 }
}

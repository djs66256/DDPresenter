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

open class UITableViewBaseItemSelfHolderPresenter<View: UIView>: UITableViewReusablePresenterHolder, UITableViewReusableItemPresentable {
    
    @MainActor
    private final class ShadowPresenter: UITableViewReusableCellPresenter<View> {
        weak var shadowSource: UITableViewBaseItemSelfHolderPresenter<View>?
        
        public override func onBindView(_ view: View) {
            shadowSource?.onBindView(view)
        }
        
        public override func onUnbindView() {
            if let view {
                shadowSource?.onUnbindView(view)
            }
        }
        
        public override func onUpdate(view: View, context: ViewUpdateContext) {
            shadowSource?.onUpdate(view: view, context: context)
        }
    }
    
    required public override init() {
        super.init()
    }
    
    public override var itemClass: UIView.Type {
        View.self
    }
    
    public override var presenterClass: UITableViewReusableItemPresentable.Type {
        ShadowPresenter.self
    }
    
    open func prepareForReuse() {
        
    }
    
    override func dryRunUpdateReusablePresenter(_ presenter: UITableViewReusableItemPresentable) -> Bool {
        guard let p = presenter as? ShadowPresenter else {
            return false
        }
        
        p.shadowSource = self
        return true
    }
    
    @MainActor open func onBindView(_ view: View) { }
    @MainActor open func onUnbindView(_ view: View) { }
    @MainActor open func onUpdate(view: View, context: ViewUpdateContext) { }
    
    public override func setState(updater: () -> Void, context: ((inout ViewUpdateContext) -> Void)? = nil, completion: (() -> Void)? = nil) {
        for p in reusedPresenters {
            p.setState(updater: {}, context: context)
        }
        super.setState(updater: updater, context: context, completion: completion)
    }
    
    @MainActor private func onBindReusablePresenter(_ presenter: ShadowPresenter) {
        presenter.shadowSource = self
    }
    
    @MainActor private func onUnbindReusablePresenter(_ presenter: ShadowPresenter) {
        presenter.shadowSource = nil
    }
    
    @MainActor private func onUpdate(presenter: ShadowPresenter, context: ViewUpdateContext) {
        
    }
    
    override func tryOnBindReusablePresenter(_ presenter: Presenter) {
        if let presenter = presenter as? ShadowPresenter {
            onBindReusablePresenter(presenter)
        }
    }
    
    override func tryOnUnbindReusablePresenter(_ presenter: Presenter) {
        if let presenter = presenter as? ShadowPresenter {
            onUnbindReusablePresenter(presenter)
        }
    }
    
    override func tryOnUpdate(presenter: Presenter, context: ViewUpdateContext) {
        if let presenter = presenter as? ShadowPresenter {
            onUpdate(presenter: presenter, context: context)
        }
    }
    
    // MARK: - deprecated
    
    public final override func onBindView(_ view: ()) {
        super.onBindView(view)
    }
    
    public final override func onUnbindView() {
        super.onUnbindView()
    }
    
    public final override func onUpdate(view: (), context: ViewUpdateContext) {
        
    }
}

open class UITableViewCellSelfHolderPresenter<View: UITableViewCell>: UITableViewBaseItemSelfHolderPresenter<View>, UITableViewCellPresentable {
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


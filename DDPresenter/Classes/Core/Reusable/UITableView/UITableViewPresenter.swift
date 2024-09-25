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

public protocol UITableViewPresentable: CollectionPresentable {
    
    @MainActor var proxy: UITableViewDelegateProxy? { get }
    
    @MainActor var displayIndexTitles: Bool { get set }
    
    @MainActor func didEndMultipleSelectionInteraction()
}

open class UITableViewPresenter<V: UITableView>: CollectionPresenter<V, UITableViewSectionPresenter>, UITableViewPresentable {
    
    @MainActor public weak var scrollDelegate: UIScrollViewDelegate? {
        didSet { proxy?.scrollDelegate = scrollDelegate }
    }
    
    public var proxy: UITableViewDelegateProxy?
    
    public override var viewUpdatePipeline: ViewUpdatePipeline? {
        proxy?.updatePipline
    }
    
    open override func bindView(_ view: V) {
        super.bindView(view)
        setupView(view)
    }
    
    open override func bindWeakView(_ view: V) {
        super.bindWeakView(view)
        setupView(view)
    }
    
    @MainActor private func setupView(_ view: V) {
        if scrollDelegate == nil {
            scrollDelegate = view.delegate
        }
        proxy = UITableViewDelegateProxy(root: self, tableView: view)
        if let scrollDelegate {
            proxy?.scrollDelegate = scrollDelegate
        }
        self.proxy?.updatePipline.superPipeline = superPresenter?.viewUpdatePipeline
        setState {} context: {
            $0.reloadData()
            $0.forceDisableAnimation = true
        }
    }
    
    public override func unbindView() {
        super.unbindView()
        self.proxy?.updatePipline.superPipeline = nil
        proxy?.reset()
        proxy = nil
    }
    
    open override func onAttachToRoot(_ presenter: RootViewPresentable) {
        super.onAttachToRoot(presenter)
        viewUpdatePipeline?.superPipeline = superPresenter?.viewUpdatePipeline
    }
    
    open override func onDetachFromRoot(_ presenter: RootViewPresentable) {
        super.onDetachFromRoot(presenter)
        viewUpdatePipeline?.superPipeline = nil
    }
    
    public override func updateViewIfNeeded() {
        viewUpdatePipeline?.updateViewIfNeeded(synchronize: true)
    }
    
    public var displayIndexTitles: Bool =  false
    
    open func didEndMultipleSelectionInteraction() {}
}

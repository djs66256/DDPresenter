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

// MARK: - Presenter

//public protocol UICollectionReusableViewPresentable: ReusablePresentable {}

open class UICollectionViewItemSelfHolderPresenter<View: UICollectionReusableView>: UICollectionViewReusablePresenterHolder, UICollectionViewItemPresentable {
    
    @MainActor
    private final class ShadowPresenter: UICollectionViewReusableItemPresenter<View> {
        weak var shadowSource: UICollectionViewItemSelfHolderPresenter<View>?
        
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
    
    public override var itemClass: UICollectionReusableView.Type {
        View.self
    }
    
    public override var presenterClass: UICollectionViewItemPresentable.Type {
        ShadowPresenter.self
    }
    
    public func prepareForReuse() {
        
    }
    
    override func dryRunUpdateReusablePresenter(_ presenter: UICollectionViewItemPresentable) -> Bool {
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

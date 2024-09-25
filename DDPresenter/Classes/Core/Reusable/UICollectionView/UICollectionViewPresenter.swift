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

public protocol UICollectionViewPresentable: CollectionPresentable {
    @MainActor var collectionView: UICollectionView? { get }
    @MainActor var proxy: UICollectionViewDelegateProxy? { get }
}

open class UICollectionViewPresenter<V: UICollectionView, SectionType: UICollectionViewSectionPresentable>:
    CollectionPresenter<V, SectionType>, UICollectionViewPresentable {
    
    @MainActor public var collectionView: UICollectionView? {
        view
    }
    
    public var defaultLayoutProxyType: UICollectionViewDelegateProxy.Type?
    
    @MainActor public weak var scrollDelegate: UIScrollViewDelegate? {
        didSet { proxy?.scrollDelegate = scrollDelegate }
    }
    
    @MainActor public private(set) var proxy: UICollectionViewDelegateProxy?
    
    public override var viewUpdatePipeline: ViewUpdatePipeline? {
        proxy?.updatePipline
    }
    
    @MainActor open func bindView(_ view: V, layoutProxy: UICollectionViewDelegateProxy.Type) {
        super.bindView(view)
        setupView(view, proxy: layoutProxy.init(root: self, collectionView: view))
    }
    
    open override func bindView(_ view: V) {
        super.bindView(view)
        setupView(view)
    }
    
    open override func bindWeakView(_ view: V) {
        super.bindWeakView(view)
        setupView(view)
    }
    
    @MainActor private func setupView(_ view: V, proxy: UICollectionViewDelegateProxy? = nil) {
        if scrollDelegate == nil {
            scrollDelegate = view.delegate
        }
        self.proxy = proxy ??
            defaultLayoutProxyType?.init(root: self, collectionView: view) ??
            UICollectionViewFlowLayoutProxy(root: self, collectionView: view)
        if let scrollDelegate {
            self.proxy?.scrollDelegate = scrollDelegate
        }
        self.proxy?.updatePipline.superPipeline = superPresenter?.viewUpdatePipeline
        setState {} context: {
            $0.reloadData()
            $0.forceDisableAnimation = true
        }
    }
    
    public override func unbindView() {
        super.unbindView()
        proxy?.updatePipline.superPipeline = nil
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
    
    @MainActor public func sectionPresenter(at index: Int) -> SectionType? {
        if let proxy {
            if index < proxy.sectionCount() {
                return proxy.sectionPresenter(at: index)
            }
        }
        return nil
    }
    
    @MainActor public func itemPresenter(at indexPath: IndexPath) -> UICollectionViewReusablePresenterHoldable? {
        if let proxy {
            if indexPath.section < proxy.sectionCount() {
                if indexPath.item < proxy.itemCount(at: indexPath.section) {
                    return proxy.itemPresenter(at: indexPath)
                }
            }
        }
        return nil
    }
}

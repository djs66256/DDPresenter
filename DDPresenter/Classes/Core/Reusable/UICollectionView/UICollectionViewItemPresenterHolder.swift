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

public protocol UICollectionViewReusablePresenterHoldable: ReusableViewPresenterHoldable {
    /// Ruesable view class, will create and reuse when update data.
    /// `UITableViewCell`, `UICollectionViewCell`, `UICollectionReusableView`, etc.
    var itemClass: UICollectionReusableView.Type { get }
    var presenterClass: UICollectionViewItemPresentable.Type { get }
    
    @MainActor var canMove: Bool { get }
    
    @MainActor var shouldHighlight: Bool { get }
    @MainActor func onDidHighlighted()
    @MainActor func onDidUnhighlight()
    
    @MainActor var shouldSelect: Bool { get }
    @MainActor var shouldDeselect: Bool { get }
    @MainActor func onDidSelect()
    @MainActor func onDidDeselect()
    
    @MainActor func onWillDisplay()
    @MainActor func onDidEndDisplaying()
}

open class UICollectionViewReusablePresenterHolder: ReusableViewPresenterHolder, UICollectionViewReusablePresenterHoldable, UICollectionItemSizeCaculatable {
    public var itemClass: UICollectionReusableView.Type { 
        fatalError("MUST override")
    }
    
    public var presenterClass: UICollectionViewItemPresentable.Type {
        fatalError("MUST override")
    }
    
    public var usingReusablePresenterLayoutInfo: Bool = false
    
    public var layoutInfo = UICollectionItemFlowLayoutInfo()
    
    open func calculateSize(containerSize: CGSize) -> CGSize {
        .zero
    }
    
    @MainActor func dryRunUpdateReusablePresenter(_ presenter: UICollectionViewItemPresentable) -> Bool {
        return false
    }
    
    public var canMove: Bool = false
    
    public var shouldHighlight: Bool = true
    open func onDidHighlighted() {}
    open func onDidUnhighlight() {}
    
    public var shouldSelect: Bool = true
    public var shouldDeselect: Bool = true
    open func onDidSelect() {}
    open func onDidDeselect() {}
    
    open func onWillDisplay() {}
    open func onDidEndDisplaying() {}
    
    @MainActor public var selectedInCollectionView: Bool {
        get {
            collectionViewPresenter?.proxy?.isSelected(for: self) ?? false
        }
        set {
            if newValue {
                collectionViewPresenter?.proxy?.select(presenter: self,
                                                       animated: false,
                                                       scrollPosition: [.centeredHorizontally, .centeredVertically])
            }
            else {
                collectionViewPresenter?.proxy?.deselect(presenter: self, animated: false)
            }
        }
    }
    
    @MainActor public func selectedInCollectionView(animated: Bool,
                                                    scrollPosition: UICollectionView.ScrollPosition) {
        collectionViewPresenter?.proxy?.select(presenter: self,
                                               animated: animated,
                                               scrollPosition: scrollPosition)
    }
    
    @MainActor public func deselectedInCollectionView(animated: Bool) {
        collectionViewPresenter?.proxy?.deselect(presenter: self, animated: animated)
    }
    
    @MainActor public func scrollToVisible(position: UICollectionView.ScrollPosition, animated: Bool) {
        collectionViewPresenter?.proxy?.scrollToVisible(for: self, position: position, animated: animated)
    }
    
    @MainActor public func scrollToVisible(inset: UIEdgeInsets = .zero, animated: Bool) {
        collectionViewPresenter?.proxy?.scrollToVisible(for: self, inset: inset, animated: animated)
    }
    
    @MainActor public func findLayoutAttributes() -> UICollectionViewLayoutAttributes? {
        collectionViewPresenter?.proxy?.layoutAttributes(for: self)
    }
    
    @MainActor private var collectionViewPresenter: UICollectionViewPresentable? {
        var p: Presenter = self
        while let superPresenter = p.superPresenter {
            if let collectionViewPresenter = superPresenter as? UICollectionViewPresentable {
                return collectionViewPresenter
            }
            p = superPresenter
        }
        return nil
    }
}

open class UICollectionViewItemPresenterHolder<P, View>
    : UICollectionViewReusablePresenterHolder
where View: UICollectionReusableView, P: UICollectionViewReusableItemPresenter<View> {
    public override var itemClass: UICollectionReusableView.Type {
        View.self
    }
    
    public override var presenterClass: UICollectionViewItemPresentable.Type {
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
    
    override func dryRunUpdateReusablePresenter(_ presenter: UICollectionViewItemPresentable) -> Bool {
        if let presenter = presenter as? P {
            onUpdate(presenter: presenter, context: .dryRun)
            return true
        }
        return false
    }
}


open class UICollectionViewReusableItemPresenter<View: UICollectionReusableView>: ReusableViewPresenter<View>, UICollectionViewItemPresentable {
    
    public var layoutInfo = UICollectionItemFlowLayoutInfo()
    
    open func calculateSize(containerSize: CGSize) -> CGSize {
        .zero
    }
}


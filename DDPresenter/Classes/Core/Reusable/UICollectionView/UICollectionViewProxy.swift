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

import UIKit

extension UICollectionItemFlowLayoutInfo.LayoutType {
    var sizeCaculatorLayoutType : SizeCaculator.LayoutType {
        switch self {
        case .autoLayout: .autoLayout
        case .sizeThatFits: .sizeThatFits
        case .intrinsicContentSize: .intrinsicContentSize
        }
    }
}

extension UICollectionItemFlowLayoutInfo.SizeFitting {
    func fitting(with containerSize: CGSize) -> Fitting {
        let fitting: Fitting
        switch self {
        case .auto: fitting = .init(width: containerSize.width, height: containerSize.height)
        case .containerWidth: fitting = .width(containerSize.width)
        case .containerHeight: fitting = .height(containerSize.height)
        case .containerSize: fitting = .containerSize(containerSize)
        case .unlimited: fitting = .containerSize(CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
        }
        return fitting
    }
}

@MainActor
open class UICollectionViewDelegateProxy: NSObject, UpdatePipelineInvalidateContentSizeProtocol {
    public let collectionView: UICollectionView
    weak var scrollDelegate: UIScrollViewDelegate?
    let updater: ListViewUpdatePipeline
    var registrar: Engine.UICollectionViewCellRegistrar
    var sizeCalculator = SizeCaculator()
    var sizeCache = SizeCache()
    
    var updatePipline: ViewUpdatePipeline {
        updater
    }
    func reset() {
        updater.destroy()
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    private static func clearIfNeeded(collectionView: UICollectionView) {
        if collectionView.numberOfSections != 0 {
            // force update collection to empty list
            collectionView.delegate = nil
            collectionView.dataSource = nil
            collectionView.reloadData()
            collectionView.performBatchUpdates { } completion: { _ in }
        }
    }
    
    public required init(root: CollectionPresentable, collectionView: UICollectionView) {
        // Maybe collection view contains old data, we reload data here to reset the collection view.
        Self.clearIfNeeded(collectionView: collectionView)
        
        self.collectionView = collectionView
        self.updater = ViewUpdatePipelineBuilder.buildCollectionViewPipeline(presenter: root, collectionView: collectionView)
        self.registrar = Engine.UICollectionViewCellRegistrar(collectionView: collectionView)
        super.init()
        self.updater.invalidation = self
        scrollDelegate = collectionView.delegate
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    var dataSource: Engine.DataSource {
        updater.dataSource
    }
    
    func invalidateContentSize(_ pipeline: ViewUpdatePipeline, _ presenters: [Presenter]) {
        for presenter in presenters {
            sizeCache[presenter] = nil
        }
    }
    
    // A root presenter for calculating size of reusable presenter
    @MainActor
    class CalculatorRootViewPresenter: RootViewPresenter<Void> {
        
        var presenter: ReusablePresentable?
        
        weak var root: Presenter?
        
        init(root: Presenter?) {
            self.root = root
        }
        
        required public init() {
            fatalError("init() has not been implemented")
        }
        
        func bindReusablePresenter(_ presenter: ReusablePresentable) {
            self.presenter = presenter
            add(child: presenter)
        }
        
        func unbindReusablePresenter() {
            if let presenter = presenter {
                remove(child: presenter)
            }
        }
        
        private lazy var _viewUpdatePipeline = ViewUpdatePipelineBuilder.buildDryRunPipeline(presenter: self)
        override var viewUpdatePipeline: ViewUpdatePipeline? {
            return _viewUpdatePipeline
        }
        
        override func updateViewIfNeeded() {
            _viewUpdatePipeline.updateViewIfNeeded(synchronize: true)
        }
        
        override func getService<T>(_ type: T.Type) -> T? {
            root?.getService(type)
        }
    }
    lazy var caculatorRootPresenter = CalculatorRootViewPresenter(root: updater.rootPresenter)
    
    let visiblePresenters: NSMapTable<UIView, AnyObject> = .weakToStrongObjects()
    
    private func doCalculateSizeManually(for holder: UICollectionViewReusablePresenterHolder, presenter: UICollectionViewItemPresentable, in containerSize: CGSize) -> CGSize {
        caculatorRootPresenter.bindReusablePresenter(presenter)
        holder.dryRunUpdateReusablePresenter(presenter)
        caculatorRootPresenter.updateViewIfNeeded()
        let size = presenter.calculateSize(containerSize: containerSize)
        caculatorRootPresenter.unbindReusablePresenter()
        return size
    }
    
    private func doCalculateSizeAutomatically(for holder: UICollectionViewReusablePresenterHolder,
                                              presenter: ReusablePresentable,
                                              view: UIView,
                                              layoutType: SizeCaculator.LayoutType,
                                              fitting: Fitting) -> CGSize {
        var size: CGSize = .zero
        presenter.prepareForReuse()
        caculatorRootPresenter.bindReusablePresenter(presenter)
        if let presenter = presenter as? UICollectionViewItemPresentable,
           holder.dryRunUpdateReusablePresenter(presenter) {
            if presenter.tryBindView(view) {
                caculatorRootPresenter.updateViewIfNeeded()
                size = sizeCalculator.size(for: view,
                                           layoutType: layoutType,
                                           fitting: fitting)
                presenter.unbindView()
            }
            else {
                assert(false, "Reuse cell presenter \(presenter) can not bind cell \(view)")
            }
        }
        caculatorRootPresenter.unbindReusablePresenter()
        return size
    }
    
    public func calculateItemSizeAutomatically(_ holder: UICollectionViewReusablePresenterHolder,
                                               _ defaultLayoutType: SizeCaculator.LayoutType = .autoLayout,
                                               _ containerSize: CGSize) -> CGSize {
        calculateItemSize(presenter: holder, defaultLayoutType: defaultLayoutType, containerSize: containerSize)
    }
    
    public func calculateItemSize(presenter holder: UICollectionViewReusablePresenterHolder,
                                  defaultLayoutType: SizeCaculator.LayoutType = .autoLayout,
                                  containerSize: CGSize) -> CGSize {
        let viewClass = holder.itemClass
        let presenterClass = holder.presenterClass
        guard let cellPresenter = sizeCalculator.dequeuePresenter(for: presenterClass) as? UICollectionViewItemPresentable else {
            assert(false, "Cell presenter \(presenterClass.self) do not support caculate size.")
            return .zero
        }
        // If reused presenter is not automatical, just return it.
        if holder.usingReusablePresenterLayoutInfo {
            if cellPresenter.layoutInfo.calculateSizeAutomatically {
                let layoutType = cellPresenter.layoutInfo.layoutType.sizeCaculatorLayoutType
                let fitting = cellPresenter.layoutInfo.autoLayoutSizeFitting.fitting(with: containerSize)
                let cell = sizeCalculator.dequeueView(for: viewClass)
                return doCalculateSizeAutomatically(for: holder,
                                                    presenter: cellPresenter,
                                                    view: cell,
                                                    layoutType: layoutType,
                                                    fitting: fitting)
            }
            else {
                return doCalculateSizeManually(for: holder, presenter: cellPresenter, in: containerSize)
            }
        }
        else {
            let calcultor = holder
            if calcultor.layoutInfo.calculateSizeAutomatically {
                let layoutType = calcultor.layoutInfo.layoutType.sizeCaculatorLayoutType
                let fitting = calcultor.layoutInfo.autoLayoutSizeFitting.fitting(with: containerSize)
                let cell = sizeCalculator.dequeueView(for: viewClass)
                return doCalculateSizeAutomatically(for: holder,
                                                    presenter: cellPresenter,
                                                    view: cell,
                                                    layoutType: layoutType,
                                                    fitting: fitting)
            } else {
                return calcultor.calculateSize(containerSize: containerSize)
            }
        }
    }
    
    public func getCachedSize(for presenter: Presenter) -> CGSize? {
        return sizeCache[presenter]
    }
    
    public func setCachedSize(_ size: CGSize, for presenter: Presenter) {
        sizeCache[presenter] = size
    }
    
    public func invalidateLayout() {
        sizeCache.clearCache()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension UICollectionViewDelegateProxy: UICollectionViewDataSource {
    
    @available(iOS 6.0, *)
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataSource.sectionCount()
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.itemCount(at: section)
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let holder: UICollectionViewReusablePresenterHolder = dataSource.item(at: indexPath) {
            let cell = registrar.dequeueReusableCell(withReuseClass: holder.itemClass, for: indexPath)
            
            let reusablePresenter = registrar.dequeueReusablePresenter(presenter: holder,
                                                                       view: cell,
                                                                       withReuseClass: holder.presenterClass,
                                                                       for: indexPath)
            if let reusablePresenter = reusablePresenter {
                if holder.tryBindReusablePresenter(reusablePresenter) {
                    reusablePresenter.tryBindWeakView(cell)
                }
                else {
                    assert(false, "Holder presenter [\(holder)]  bind reusable presenter failed!")
                }
            }
            
            visiblePresenters.setObject(holder, forKey: cell)
            
            return cell
        }
        
        assert(false, "Dequeue cell failed!")
        return UICollectionViewCell()
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let holder: UICollectionViewReusablePresenterHolder = dataSource.supplementary(for: kind, at: indexPath) {
            let cell = registrar.dequeueReusableSupplementaryView(ofKind: kind,
                                                                  withReuseClass: holder.itemClass,
                                                                  for: indexPath)
            
            let reusablePresenter = registrar.dequeueReusablePresenter(presenter: holder,
                                                                       view: cell,
                                                                       withReuseClass: holder.presenterClass,
                                                                       for: indexPath)
            if let reusablePresenter = reusablePresenter {
                if holder.tryBindReusablePresenter(reusablePresenter) {
                    reusablePresenter.tryBindWeakView(cell)
                }
                else {
                    assert(false, "Holder presenter bind reusable presenter [\(holder)] failed!")
                }
            }
            
            visiblePresenters.setObject(holder, forKey: cell)
            
            return cell
        }
        
        assert(false, "Dequeue cell failed!")
        return UICollectionReusableView()
    }
    
    
    @available(iOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        return item?.canMove ?? false
    }
    
    @available(iOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dataSource.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    
    /// Returns a list of index titles to display in the index view (e.g. ["A", "B", "C" ... "Z", "#"])
    @available(iOS 14.0, *)
    open func indexTitles(for collectionView: UICollectionView) -> [String]? {
        dataSource.indexTitles()
    }
    
    
    /// Returns the index path that corresponds to the given title / index. (e.g. "B",1)
    /// Return an index path with a single index to indicate an entire section, instead of a specific item.
    @available(iOS 14.0, *)
    open func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        dataSource.indexPath(at: index)
    }
}

extension UICollectionViewDelegateProxy: UIScrollViewDelegate {
    @available(iOS 2.0, *)
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    @available(iOS 3.2, *)
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    
    // called on start of dragging (may require some time and or distance to move)
    @available(iOS 2.0, *)
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @available(iOS 5.0, *)
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    @available(iOS 2.0, *)
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    
    @available(iOS 2.0, *)
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    @available(iOS 2.0, *)
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    
    @available(iOS 2.0, *)
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    
    @available(iOS 2.0, *)
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        scrollDelegate?.viewForZooming?(in: scrollView)
    }
    
    @available(iOS 3.2, *)
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    @available(iOS 2.0, *)
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    
    @available(iOS 2.0, *)
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? false
    }
    
    @available(iOS 2.0, *)
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    @available(iOS 11.0, *)
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}

extension UICollectionViewDelegateProxy {
    
    public func section(for presenter: UICollectionViewSectionPresentable) -> Int? {
        dataSource.sectionIndex(for: presenter)
    }
    
    public func indexPath(forItem presenter: UICollectionViewReusablePresenterHoldable) -> IndexPath? {
        dataSource.indexPath(forItem: presenter)
    }
    
    public func indexPath(forSupplementary presenter: UICollectionViewReusablePresenterHoldable) -> (String, IndexPath)? {
        dataSource.indexPath(forSupplementary: presenter)
    }
    
    public func isSelected(for presenter: UICollectionViewReusablePresenterHoldable) -> Bool {
        if let indexPath = indexPath(forItem: presenter) {
            return collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false
        }
        return false
    }
    
    public func select(presenter: UICollectionViewReusablePresenterHoldable, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        if let indexPath = indexPath(forItem: presenter) {
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
    }
    
    public func deselect(presenter: UICollectionViewReusablePresenterHoldable, animated: Bool) {
        if let indexPath = indexPath(forItem: presenter) {
            collectionView.deselectItem(at: indexPath, animated: animated)
        }
    }
    
    public func layoutAttributes(for presenter: UICollectionViewReusablePresenterHoldable) -> UICollectionViewLayoutAttributes? {
        if let indexPath = indexPath(forItem: presenter) {
            return collectionView.layoutAttributesForItem(at: indexPath)
        }
        else if let (kind, indexPath) = indexPath(forSupplementary: presenter) {
            return collectionView.layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath)
        }
        return nil
    }
    
    public func scrollToVisible(for presenter: UICollectionViewReusablePresenterHoldable,
                                position: UICollectionView.ScrollPosition,
                                animated: Bool) {
        if let indexPath = indexPath(forItem: presenter) {
            collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
        }
        else if let (kind, indexPath) = indexPath(forSupplementary: presenter),
                let attr = collectionView.layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath) {
            collectionView.scrollRectToVisible(attr.frame, animated: animated)
        }
    }
    
    public func scrollToVisible(for presenter: UICollectionViewReusablePresenterHoldable, inset: UIEdgeInsets, animated: Bool) {
        if let attr = layoutAttributes(for: presenter) {
            collectionView.scrollRectToVisible(attr.frame.inset(by: inset), animated: animated)
        }
    }
}

extension UICollectionViewDelegateProxy: UICollectionViewDelegate {
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        return item?.shouldHighlight ?? false
    }
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        item?.onDidHighlighted()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        item?.onDidUnhighlight()
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        return item?.shouldSelect ?? false
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        return item?.shouldDeselect ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        item?.onDidSelect()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item: UICollectionViewReusablePresenterHolder? = dataSource.item(at: indexPath)
        item?.onDidDeselect()
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let item = visiblePresenters.object(forKey: cell) as? UICollectionViewReusablePresenterHolder {
            item.onWillDisplay()
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let item = visiblePresenters.object(forKey: view) as? UICollectionViewReusablePresenterHolder {
            item.onWillDisplay()
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let item = visiblePresenters.object(forKey: cell) as? UICollectionViewReusablePresenterHolder {
            item.onDidEndDisplaying()
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let item = visiblePresenters.object(forKey: view) as? UICollectionViewReusablePresenterHolder {
            item.onDidEndDisplaying()
        }
    }
    
    
    // These methods provide support for copy/paste actions on cells.
    // All three should be implemented if any are.
    /*
     @available(iOS, introduced: 6.0, deprecated: 13.0)
     func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     
     }
     
     @available(iOS, introduced: 6.0, deprecated: 13.0)
     func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     
     }
     
     @available(iOS, introduced: 6.0, deprecated: 13.0)
     func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    // support for custom transition layout
    /*
     @available(iOS 7.0, *)
     func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
     */
    
    // Focus
    /*
     @available(iOS 9.0, *)
     func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool
     
     @available(iOS 9.0, *)
     func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool
     
     @available(iOS 9.0, *)
     func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
     
     @available(iOS 9.0, *)
     func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath?
     
     /// Determines if the item at the specified index path should also become selected when focus moves to it.
     /// If the collection view's global selectionFollowsFocus is enabled, this method will allow you to override that behavior on a per-index path basis. This method is not called if selectionFollowsFocus is disabled.
     @available(iOS 15.0, *)
     func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool
     
     
     @available(iOS 15.0, *)
     func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
     
     @available(iOS, introduced: 9.0, deprecated: 15.0)
     func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
     
     
     @available(iOS 9.0, *)
     func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint // customize the content offset to be applied during transition or update animations
     
     */
    
    // Editing
    /* Asks the delegate to verify that the given item is editable.
     *
     * @param collectionView The collection view object requesting this information.
     * @param indexPath An index path locating an item in `collectionView`.
     *
     * @return `YES` if the item is editable; otherwise, `NO`. Defaults to `YES`.
     */
    /*
     @available(iOS 14.0, *)
     func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool
     
     
     // Spring Loading
     
     /* Allows opting-out of spring loading for an particular item.
      *
      * If you want the interaction effect on a different subview of the spring loaded cell, modify the context.targetView property.
      * The default is the cell.
      *
      * If this method is not implemented, the default is YES.
      */
     @available(iOS 11.0, *)
     func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
     
     
     // Multiple Selection
     
     /* Allows a two-finger pan gesture to automatically enable allowsMultipleSelection and start selecting multiple cells.
      *
      * After a multi-select gesture is recognized, this method will be called before allowsMultipleSelection is automatically
      * set to YES to allow the user to select multiple contiguous items using a two-finger pan gesture across the constrained
      * scroll direction.
      *
      * If the collection view has no constrained scroll direction (i.e., the collection view scrolls both horizontally and vertically),
      * then this method will not be called and the multi-select gesture will be disabled.
      *
      * If this method is not implemented, the default is NO.
      */
     @available(iOS 13.0, *)
     func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool
     
     
     /* Called right after allowsMultipleSelection is set to YES if -collectionView:shouldBeginMultipleSelectionInteractionAtIndexPath:
      * returned YES.
      *
      * In your app, this would be a good opportunity to update the state of your UI to reflect the fact that the user is now selecting
      * multiple items at once; such as updating buttons to say "Done" instead of "Select"/"Edit", for instance.
      */
     @available(iOS 13.0, *)
     func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath)
     
     
     /* Called when the multi-select interaction ends.
      *
      * At this point, the collection view will remain in multi-select mode, but this delegate method is called to indicate that the
      * multiple selection gesture or hardware keyboard interaction has ended.
      */
     @available(iOS 13.0, *)
     func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView)
     
     
     /**
      * @abstract Called when the interaction begins.
      *
      * @param collectionView  This UICollectionView.
      * @param indexPath       IndexPath of the item for which a configuration is being requested.
      * @param point           Location in the collection view's coordinate space
      *
      * @return A UIContextMenuConfiguration describing the menu to be presented. Return nil to prevent the interaction from beginning.
      *         Returning an empty configuration causes the interaction to begin then fail with a cancellation effect. You might use this
      *         to indicate to users that it's possible for a menu to be presented from this element, but that there are no actions to
      *         present at this particular time.
      */
     @available(iOS 13.0, *)
     func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?
     
     
     /**
      * @abstract Called when the interaction begins. Return a UITargetedPreview describing the desired highlight preview.
      *
      * @param collectionView  This UICollectionView.
      * @param configuration   The configuration of the menu about to be displayed by this interaction.
      */
     @available(iOS 13.0, *)
     func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
     
     
     /**
      * @abstract Called when the interaction is about to dismiss. Return a UITargetedPreview describing the desired dismissal target.
      * The interaction will animate the presented menu to the target. Use this to customize the dismissal animation.
      *
      * @param collectionView  This UICollectionView.
      * @param configuration   The configuration of the menu displayed by this interaction.
      */
     @available(iOS 13.0, *)
     func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
     
     
     /**
      * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
      *
      * @param collectionView  This UICollectionView.
      * @param configuration   Configuration of the currently displayed menu.
      * @param animator        Commit animator. Add animations to this object to run them alongside the commit transition.
      */
     @available(iOS 13.0, *)
     func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)
     
     
     /**
      * @abstract Called when the collection view is about to display a menu.
      *
      * @param collectionView  This UICollectionView.
      * @param configuration   The configuration of the menu about to be displayed.
      * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
      */
     @available(iOS 13.2, *)
     func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
     
     
     /**
      * @abstract Called when the collection view's context menu interaction is about to end.
      *
      * @param collectionView  This UICollectionView.
      * @param configuration   Ending configuration.
      * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
      */
     @available(iOS 13.2, *)
     func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
     
     
     /**
      * @abstract Return a valid @c UIWindowSceneActivationConfiguration to allow for the cell to be expanded into a new scene. Return nil to prevent the interaction from starting.
      *
      * @param collectionView The collection view
      * @param indexPath The index path of the cell being interacted with
      * @param point The centroid of the interaction in the collection view's coordinate space.
      */
     @available(iOS 15.0, *)
     func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIWindowScene.ActivationConfiguration?
     */
}

public extension UICollectionViewDelegateProxy {
    func rootPresenter<T>() -> T? {
        dataSource.root()
    }
    
    var indexes: [(String, IndexPath)]? {
        dataSource.indexes
    }
    
    func indexTitles() -> [String]? {
        dataSource.indexTitles()
    }
//    func indexPath(at index: Int) -> IndexPath {
//        dataSource.indexPath(at: index)
//    }
    
    func sectionCount() -> Int {
        dataSource.sectionCount()
    }
    
    func itemCount(at section: Int) -> Int {
        dataSource.itemCount(at: section)
    }
    
    func itemPresenter<T>(at indexPath: IndexPath) -> T? {
        dataSource.item(at: indexPath)
    }
    
    func sectionPresenter<T>(at index: Int) -> T? {
        dataSource.section(at: index)
    }
    
    func supplementaryPresenter<T>(for kind: String, at indexPath: IndexPath) -> T? {
        dataSource.supplementary(for: kind, at: indexPath)
    }
    
    func moveItem(at: IndexPath, to: IndexPath) {
        dataSource.moveItem(at: at, to: to)
    }
}

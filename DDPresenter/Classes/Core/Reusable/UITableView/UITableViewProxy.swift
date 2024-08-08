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

extension UITableViewCellLayoutInfo.LayoutType {
    var sizeCaculatorLayoutType: SizeCaculator.LayoutType {
        switch self {
        case .autoLayout: .autoLayout
        case .sizeThatFits: .sizeThatFits
        case .intrinsicContentSize: .intrinsicContentSize
        }
    }
}

extension UITableViewCellLayoutInfo.SizeFitting {
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
public class UITableViewDelegateProxy: NSObject, UpdatePipelineInvalidateContentSizeProtocol {
    
    let tableView: UITableView
    weak var scrollDelegate: UIScrollViewDelegate?
    let updater: ListViewUpdatePipeline
    var registrar: Engine.UITableViewCellRegistrar
    var sizeCalculator = SizeCaculator()
    var sizeCache = SizeCache()
    
    var updatePipline: ViewUpdatePipeline {
        updater
    }
    
    var dataSource: Engine.DataSource {
        updater.dataSource
    }
    
    func reset() {
        updater.destroy()
        tableView.delegate = nil
        tableView.dataSource = nil
    }
    
    static func clearTableView(_ tableView: UITableView) {
        if tableView.numberOfSections != 0 {
            tableView.delegate = nil
            tableView.dataSource = nil
            tableView.reloadData()
            if tableView.window != nil {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    init(root: CollectionPresentable, tableView: UITableView) {
        Self.clearTableView(tableView)
        self.tableView = tableView
        self.updater = ViewUpdatePipelineBuilder.buildTableViewPipeline(presenter: root, tableView: tableView)
        self.registrar = Engine.UITableViewCellRegistrar(tableView: tableView)
        super.init()
        self.updater.invalidation = self
        scrollDelegate = tableView.delegate
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func invalidateContentSize(_ pipeline: ViewUpdatePipeline, _ presenters: [Presenter]) {
        for presenter in presenters {
            sizeCache[presenter] = nil
        }
    }
    
    // A root presenter for calculating size of reusable presenter
    @MainActor class CalculatorRootViewPresenter: ViewPresenter<Void> {
        var presenter: ReusablePresentable?
        
        weak var root: Presenter?
        
        init(root: Presenter?) {
            self.root = root
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
    
    var indexes: [String: Int] = [:]
}

// MARK: - DataSource
public extension UITableViewDelegateProxy {
    func sectionCount() -> Int {
        dataSource.sectionCount()
    }
    
    func itemCount(at section: Int) -> Int {
        if section < sectionCount() {
            return dataSource.itemCount(at: section)
        }
        return Int.max
    }
    
    func itemPresenter<T>(at indexPath: IndexPath) -> T? {
        if indexPath.section < sectionCount() && 
            indexPath.row < itemCount(at: indexPath.section) {
            return dataSource.item(at: indexPath)
        }
        return nil
    }
    
    func sectionPresenter<T>(at section: Int) -> T? {
        if section < sectionCount() {
            return dataSource.section(at: section)
        }
        return nil
    }
    
    func headerPresenter<T>(at section: Int) -> T? {
        if section < sectionCount() {
            return dataSource.supplementary(for: CollectionElementKind.sectionHeader,
                                     at: IndexPath(item: 0, section: section))
        }
        return nil
    }
    
    func footerPresenter<T>(at section: Int) -> T? {
        if section < sectionCount() {
            return dataSource.supplementary(for: CollectionElementKind.sectionFooter,
                                     at: IndexPath(item: 0, section: section))
        }
        return nil
    }
    
    func sectionIndex(for presenter: CollectionSectionPresentable) -> Int? {
        dataSource.sectionIndex(for: presenter)
    }
    
    func indexPath(forItem presenter: ReusableViewPresenterHoldable) -> IndexPath? {
        dataSource.indexPath(forItem: presenter)
    }
    
    func sectionIndex(forHeader presenter: ReusableViewPresenterHoldable) -> Int? {
        dataSource.indexPath(forSupplementary: presenter)?.1.section
    }
    
    func sectionIndex(forFooter presenter: ReusableViewPresenterHoldable) -> Int? {
        dataSource.indexPath(forSupplementary: presenter)?.1.section
    }
}

// MARK: - Control
public extension UITableViewDelegateProxy {
    
    func rect(forSection presenter: CollectionSectionPresentable) -> CGRect? {
        if let section = sectionIndex(for: presenter) {
            return tableView.rect(forSection: section)
        }
        return nil
    }
    
    func rect(forHeader presenter: ReusableViewPresenterHoldable) -> CGRect? {
        if let section = sectionIndex(forHeader: presenter) {
            return tableView.rectForHeader(inSection: section)
        }
        return nil
    }
    
    func rect(forFooter presenter: ReusableViewPresenterHoldable) -> CGRect? {
        if let section = sectionIndex(forFooter: presenter) {
            return tableView.rectForFooter(inSection: section)
        }
        return nil
    }
    
    func rect(forRow presenter: ReusableViewPresenterHoldable) -> CGRect? {
        if let indexPath = indexPath(forItem: presenter) {
            return tableView.rectForRow(at: indexPath)
        }
        return nil
    }
    
    func rect(for presenter: ReusableViewPresenterHoldable) -> CGRect? {
        rect(forRow: presenter) ??
        rect(forHeader: presenter) ??
        rect(forFooter: presenter)
    }
    
    func selectRow(for presenter: ReusableViewPresenterHoldable,
                   animated: Bool,
                   scrollPosition: UITableView.ScrollPosition) {
        if let indexPath = indexPath(forItem: presenter) {
            tableView.selectRow(at: indexPath,
                                animated: animated,
                                scrollPosition: scrollPosition)
        }
    }
    
    func deselectRow(for presenter: ReusableViewPresenterHoldable, animated: Bool) {
        if let indexPath = indexPath(forItem: presenter) {
            tableView.deselectRow(at: indexPath,
                                  animated: animated)
        }
    }
    
    func scrollToRow(for presenter: ReusableViewPresenterHoldable,
                     at position: UITableView.ScrollPosition,
                     animated: Bool) {
        if let indexPath = indexPath(forItem: presenter) {
            tableView.scrollToRow(at: indexPath, at: position, animated: animated)
        }
    }
    
    func scrollToVisible(for presenter: UITableViewReusablePresenterHolder,
                         inset: UIEdgeInsets,
                         animated: Bool) {
        if let frame = rect(forRow: presenter) {
            tableView.scrollRectToVisible(frame.inset(by: inset), animated: animated)
        }
    }
}

extension UITableViewDelegateProxy: UITableViewDelegate, UITableViewDataSource {
    
    
    @available(iOS 2.0, *)
    public func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.sectionCount()
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.itemCount(at: section)
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let holder: UITableViewReusablePresenterHolder = dataSource.item(at: indexPath) {
            let cell = registrar.dequeueCell(withReuseClass: holder.itemClass, for: indexPath)
            
            // Bind new presenter
            let reusablePresenter = registrar.dequeueReusablePresenter(presenter: holder,
                                                                       view: cell,
                                                                       withReuseClass: holder.presenterClass)
            if let reusablePresenter = reusablePresenter {
                if holder.tryBindReusablePresenter(reusablePresenter) {
                    reusablePresenter.tryBindWeakView(cell)
                }
                else {
                    assert(false, "Item presenter bind reusable presenter [\(holder)] failed!")
                }
            }
            
            visiblePresenters.setObject(holder, forKey: cell)
            
            return cell
        }
        return UITableViewCell()
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let holder: UITableViewReusablePresenterHolder = headerPresenter(at: section) {
            let cell = registrar.dequeueHeaderFooterView(withReuseClass: holder.itemClass)
            guard let cell else {
                return nil
            }
            
            // Bind new presenter
            let reusablePresenter = registrar.dequeueReusablePresenter(presenter: holder,
                                                                       view: cell,
                                                                       withReuseClass: holder.presenterClass)
            if let reusablePresenter = reusablePresenter {
                if holder.tryBindReusablePresenter(reusablePresenter) {
                    reusablePresenter.tryBindWeakView(cell)
                }
                else {
                    assert(false, "Item presenter bind reusable presenter [\(holder)] failed!")
                }
            }
            
            visiblePresenters.setObject(holder, forKey: cell)
            
            return cell
        }
        
        return nil
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let holder: UITableViewReusablePresenterHolder = footerPresenter(at: section) {
            
            let cell = registrar.dequeueHeaderFooterView(withReuseClass: holder.itemClass)
            guard let cell else {
                return nil
            }
            
            // Bind new presenter
            let reusablePresenter = registrar.dequeueReusablePresenter(presenter: holder,
                                                                       view: cell,
                                                                       withReuseClass: holder.presenterClass)
            if let reusablePresenter = reusablePresenter {
                if holder.tryBindReusablePresenter(reusablePresenter) {
                    reusablePresenter.tryBindWeakView(cell)
                }
                else {
                    assert(false, "Item presenter bind reusable presenter [\(holder)] failed!")
                }
            }
            
            visiblePresenters.setObject(holder, forKey: cell)
            
            return cell
        }
        
        return nil
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let presenter: UITableViewSectionPresentable = dataSource.section(at: section) {
            return presenter.headerTitle
        }
        return nil
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let presenter: UITableViewSectionPresentable = dataSource.section(at: section)  {
            return presenter.footerTitle
        }
        return nil
    }
    
    // Index
    
    @available(iOS 2.0, *)
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let root: UITableViewPresentable = dataSource.root() {
            if root.displayIndexTitles {
                indexes.removeAll()
                var titles: [String] = []
                for i in 0..<dataSource.sectionCount() {
                    if let section: UITableViewSectionPresentable = dataSource.section(at: i) {
                        if let title = section.indexTitle {
                            indexes[title] = i
                            titles.append(title)
                        }
                        
                    }
                }
                return titles
            }
        }
        return nil
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return indexes[title] ?? 0
    }
    
    
    // Data manipulation - insert and delete support
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.canEdit
        }
        return false
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.editStyle
        }
        return .none
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.commitEditing(style: editingStyle)
        }
    }
    
    @available(iOS 3.0, *)
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.deleteConfirmationButtonTitle
        }
        return nil
    }
    
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.editActions
        }
        return nil
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.leadingSwipeActionsConfiguration
        }
        return nil
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.trailingSwipeActionsConfiguration
        }
        return nil
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return item.shouldIndentWhileEditing
        }
        return false
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            item.onWillBeginEditing()
        }
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath,
           let item: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            item.onDidEndEditing()
        }
    }
    
    
    // Data manipulation - reorder / moving support
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // TODO: reorder
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let presenter = visiblePresenters.object(forKey: cell) as? UITableViewCellPresentable {
            presenter.onWillDisplay()
        }
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let presenter = visiblePresenters.object(forKey: cell) as? UITableViewCellPresentable {
            presenter.onDidEndDisplaying()
        }
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let presenter = visiblePresenters.object(forKey: view) as? UITableViewHeaderFooterPresentable {
            presenter.onWillDisplay()
        }
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let presenter = visiblePresenters.object(forKey: view) as? UITableViewHeaderFooterPresentable {
            presenter.onWillDisplay()
        }
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let presenter = visiblePresenters.object(forKey: view) as? UITableViewHeaderFooterPresentable {
            presenter.onDidEndDisplaying()
        }
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let presenter = visiblePresenters.object(forKey: view) as? UITableViewHeaderFooterPresentable {
            presenter.onDidEndDisplaying()
        }
    }
    
    // MARK: - Size
    private var containerSize: CGSize {
        CGSize(width: tableView.frame.width - tableView.contentInset.left - tableView.contentInset.right,
               height: .infinity)
    }
    
    
    private func doCalculateSizeManually(for holder: UITableViewReusablePresenterHolder, presenter: UITableViewReusableItemPresentable, in containerSize: CGSize) -> CGSize {
        caculatorRootPresenter.bindReusablePresenter(presenter)
        holder.dryRunUpdateReusablePresenter(presenter)
        caculatorRootPresenter.updateViewIfNeeded()
        let height = presenter.calculateHeight(containerSize: containerSize)
        caculatorRootPresenter.unbindReusablePresenter()
        return CGSize(width: containerSize.width, height: height)
    }
    
    private func doCalculateSizeAutomatically(for holder: UITableViewReusablePresenterHolder,
                                              presenter: ReusablePresentable,
                                              view: UIView,
                                              layoutType: SizeCaculator.LayoutType,
                                              fitting: Fitting) -> CGSize {
        var size: CGSize = .zero
        presenter.prepareForReuse()
        caculatorRootPresenter.bindReusablePresenter(presenter)
        if let presenter = presenter as? UITableViewReusableItemPresentable,
           holder.dryRunUpdateReusablePresenter(presenter) {
            if presenter.tryBindView(view) {
                caculatorRootPresenter.updateViewIfNeeded()
                size = sizeCalculator.size(for: view,
                                           layoutType: layoutType,
                                           fitting: .init(width: containerSize.width, height: containerSize.height))
                presenter.unbindView()
            }
            else {
                assert(false, "Reuse cell presenter \(presenter) can not bind cell \(view)")
            }
        }
        caculatorRootPresenter.unbindReusablePresenter()
        return size
    }
    
    public func calculateItemSize(presenter holder: UITableViewReusablePresenterHolder,
                                  containerSize: CGSize) -> CGSize {
        let viewClass = holder.itemClass
        let presenterClass = holder.presenterClass
        
        guard let cellPresenter = sizeCalculator.dequeuePresenter(for: presenterClass) as? UITableViewReusableItemPresentable else {
            assert(false, "Cell presenter \(presenterClass.self) do not support caculate size.")
            return .zero
        }
        
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
                let fitting = cellPresenter.layoutInfo.autoLayoutSizeFitting.fitting(with: containerSize)
                let cell = sizeCalculator.dequeueView(for: viewClass)
                return doCalculateSizeAutomatically(for: holder,
                                                    presenter: cellPresenter,
                                                    view: cell,
                                                    layoutType: layoutType,
                                                    fitting: fitting)
            } else {
                let height = calcultor.calculateHeight(containerSize: containerSize)
                return CGSize(width: containerSize.width, height: height)
            }
        }
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let presenter: UITableViewReusablePresenterHolder = dataSource.item(at: indexPath) {
            if let cachedSize = sizeCache[presenter] {
                return cachedSize.height
            }
            else {
                let calculatedSize = calculateItemSize(presenter: presenter, containerSize: containerSize)
                sizeCache[presenter] = calculatedSize
                return calculatedSize.height
            }
        }
        return UITableView.automaticDimension
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let section: UITableViewSectionPresentable = dataSource.section(at: section) {
            if let presenter = section.supplementaries[CollectionElementKind.sectionHeader]?.first as? UITableViewReusablePresenterHolder {
                if let cachedSize = sizeCache[presenter] {
                    return cachedSize.height
                }
                else {
                    let calculatedSize = calculateItemSize(presenter: presenter, containerSize: containerSize)
                    sizeCache[presenter] = calculatedSize
                    return calculatedSize.height
                }
            }
            else if section.headerTitle != nil {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let section: UITableViewSectionPresentable = dataSource.section(at: section) {
            if let presenter = section.supplementaries[CollectionElementKind.sectionFooter]?.first as? UITableViewReusablePresenterHolder {
                if let cachedSize = sizeCache[presenter] {
                    return cachedSize.height
                }
                else {
                    let calculatedSize = calculateItemSize(presenter: presenter, containerSize: containerSize)
                    sizeCache[presenter] = calculatedSize
                    return calculatedSize.height
                }
            }
            else if section.footerTitle != nil {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
    
    @available(iOS 7.0, *)
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.estimatedHeight
        }
        return 0
    }
    
    @available(iOS 7.0, *)
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let section: UITableViewSectionPresentable = dataSource.section(at: section) {
            if let presenter = section.supplementaries[CollectionElementKind.sectionHeader]?.first as? UITableViewHeaderFooterPresentable {
                return presenter.estimatedHeight
            }
            else if section.headerTitle != nil {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
    
    @available(iOS 7.0, *)
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let section: UITableViewSectionPresentable = dataSource.section(at: section) {
            if let presenter = section.supplementaries[CollectionElementKind.sectionFooter]?.first as? UITableViewHeaderFooterPresentable {
                return presenter.estimatedHeight
            }
            else if section.footerTitle != nil {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
    
//    @available(iOS 8.0, *)
//    optional func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.shouldHighlight
        }
        return false
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.onDidHighlight()
        }
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.onDidUnhighlight()
        }
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            if presenter.shouldSelect {
                presenter.onWillSelect()
                return indexPath
            } 
            else {
                return nil
            }
        }
        return indexPath
    }
    
    @available(iOS 3.0, *)
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            if presenter.shouldDeselect {
                presenter.onWillDeselect()
            }
            else {
                return nil
            }
        }
        return indexPath
    }
    
    @available(iOS 8.0, *)
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.onDidSelect()
        }
    }
    
    @available(iOS 3.0, *)
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.onDidDeselect()
        }
    }
    
    /**
     * @abstract Called to determine if a primary action can be performed for the row at the given indexPath.
     * See @c tableView:performPrimaryActionForRowAtIndexPath: for more details about primary actions.
     *
     * @param tableView This UITableView
     * @param indexPath NSIndexPath of the row
     *
     * @return `YES` if the primary action can be performed; otherwise `NO`. If not implemented defaults to `YES` when not editing
     * and `NO` when editing.
     */
//    @available(iOS 16.0, *)
//    optional func tableView(_ tableView: UITableView, canPerformPrimaryActionForRowAt indexPath: IndexPath) -> Bool
    
    /**
     * @abstract Called when the primary action should be performed for the row at the given indexPath.
     *
     * @discussion Primary actions allow you to distinguish between a change of selection (which can be based on focus changes or
     * other indirect selection changes) and distinct user actions. Primary actions are performed when the user selects a cell without extending
     * an existing selection. This is called after @c willSelectRow and @c didSelectRow , regardless of whether the cell's selection
     * state was allowed to change.
     *
     * As an example, use @c didSelectRowAtIndexPath for updating state in the current view controller (i.e. buttons, title, etc) and
     * use the primary action for navigation or showing another split view column.
     *
     * @param tableView This UITableView
     * @param indexPath NSIndexPath of the row to perform the action on
     */
//    @available(iOS 16.0, *)
//    optional func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath)
    
    
    
//    @available(iOS 8.0, *)
//    optional func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
//    
//    @available(iOS 8.0, *)
//    optional func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int
    
    @available(iOS, introduced: 5.0, deprecated: 13.0)
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.shouldShowMenu
        }
        return false
    }
    
    @available(iOS, introduced: 5.0, deprecated: 13.0)
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.canPerformAction(action: action, with: sender)
        }
        return false
    }
    
    @available(iOS, introduced: 5.0, deprecated: 13.0)
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            presenter.performAction(action: action, with: sender)
        }
    }
    
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
//    
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
//    
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
//    
//    @available(iOS 9.0, *)
//    optional func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    
    /// Determines if the row at the specified index path should also become selected when focus moves to it.
    /// If the table view's global selectionFollowsFocus is enabled, this method will allow you to override that behavior on a per-index path basis. This method is not called if selectionFollowsFocus is disabled.
//    @available(iOS 15.0, *)
//    optional func tableView(_ tableView: UITableView, selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool
//    
//    @available(iOS 11.0, *)
//    optional func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
    
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            return presenter.shouldBeginMultipleSelectionInteraction
        }
        return false
    }
    
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        if let presenter: UITableViewCellPresentable = dataSource.item(at: indexPath) {
            presenter.didBeginMultipleSelectionInteraction()
        }
    }
    
    @available(iOS 13.0, *)
    public func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        if let root: UITableViewPresentable = dataSource.root() {
            root.didEndMultipleSelectionInteraction()
        }
    }
    
    /**
     * @abstract Called when the interaction begins.
     *
     * @param tableView  This UITableView.
     * @param indexPath  IndexPath of the row for which a configuration is being requested.
     * @param point      Location of the interaction in the table view's coordinate space
     *
     * @return A UIContextMenuConfiguration describing the menu to be presented. Return nil to prevent the interaction from beginning.
     *         Returning an empty configuration causes the interaction to begin then fail with a cancellation effect. You might use this
     *         to indicate to users that it's possible for a menu to be presented from this element, but that there are no actions to
     *         present at this particular time.
     */
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?
    
    /**
     * @abstract Called when the interaction begins. Return a UITargetedPreview to override the default preview created by the table view.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu about to be displayed by this interaction.
     */
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
    
    /**
     * @abstract Called when the interaction is about to dismiss. Return a UITargetedPreview describing the desired dismissal target.
     * The interaction will animate the presented menu to the target. Use this to customize the dismissal animation.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu displayed by this interaction.
     */
//    @available(iOS 13.0, *)
//    optional func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
    
    /**
     * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
     *
     * @param tableView      This UITableView.
     * @param configuration  Configuration of the currently displayed menu.
     * @param animator       Commit animator. Add animations to this object to run them alongside the commit transition.
     */
//    @available(iOS 13.0, *)
//    optional func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)
    
    /**
     * @abstract Called when the table view is about to display a menu.
     *
     * @param tableView       This UITableView.
     * @param configuration   The configuration of the menu about to be displayed.
     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
     */
//    @available(iOS 14.0, *)
//    optional func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
    
    /**
     * @abstract Called when the table view's context menu interaction is about to end.
     *
     * @param tableView       This UITableView.
     * @param configuration   Ending configuration.
     * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
     */
//    @available(iOS 14.0, *)
//    optional func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
}

extension UITableViewDelegateProxy: UIScrollViewDelegate {
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

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

extension Engine {
    
    class PartialTrasactionPipeline: ListViewUpdatePipeline {
        @MainActor weak var superPipeline: ViewUpdatePipeline?
        private lazy var globalPipeline = GlobalViewUpdatePipeline.shared
        
        @MainActor var dataSource: DataSource
        @MainActor var root: CollectionPresentable?
        @MainActor var rootPresenter: Presenter?
        @MainActor weak var rootView: UIView?
        @MainActor weak var invalidation: UpdatePipelineInvalidateContentSizeProtocol?
        
        @MainActor private var transaction = PartialCompositeTrasaction()
        private var lock = NSLock()
        private var dirtyVersion: Int = 0
        @MainActor private var isUpdating = false
        @MainActor private var isDestroyed = false
        
        private let queue = DispatchQueue(label: "diff")
        @MainActor private let listView: ListUpdateProtocol
        
        @MainActor
        init(root: CollectionPresentable, collectionView: UICollectionView) {
            self.dataSource = DataSource(root: root)
            self.root = root
            self.rootPresenter = root
            self.listView = UICollectionViewUpdateResolver(collectionView: collectionView)
            self.rootView = collectionView
        }
        
        @MainActor
        init(root: CollectionPresentable, tableView: UITableView) {
            self.dataSource = DataSource(root: root)
            self.root = root
            self.rootPresenter = root
            self.listView = UITableViewUpdateResolver(tableView: tableView)
            self.rootView = tableView
        }
        
        @MainActor
        func destroy() {
            isDestroyed = true
        }
        
        @MainActor
        func markDirty(presenter: Presenter, context: ViewUpdateContext, _ completion: (() -> Void)?) {
            guard !isDestroyed else { return }
            
            if context.isBindingView {
                presenter.updateView(context: context)
                presenter.updateLayout(context: context)
                completion?()
                return
            }
            
            transaction.markDirty(presenter: presenter, context: context, completion)
            
            Logger.log("<PartialCompositeTrasaction> mark dirty: \(presenter), updating: \(isUpdating), invalidate data source: \(context.invalidateDataSource), invalidate content size: \(context.invalidateContentSize)")
            
            if !isUpdating {
                // When during updating, should not mark dirty, as it will collect it immediately.
                // Notify global pipeline to update it.
                globalPipeline.markDirty(self)
            }
        }
        
        @MainActor
        func updateViewPresenterIfNeeded(_ presenter: Presenter) {
            guard !isDestroyed else { return }
            
            if transaction.invalidateDataSource || transaction.invalidateContentSize {
                updateViewIfNeeded(synchronize: true)
            }
            else if let transaction = transaction.remove(for: presenter) {
                transaction.updateView()
                transaction.updateLayout()
                transaction.complete()
            }
        }
        
        @MainActor
        func updateViewIfNeeded(synchronize: Bool) {
            guard !isDestroyed else { return }
            guard transaction.isDirty else { return }
            
            if transaction.invalidateDataSource {
                guard let newData = collectNewDataSource() else { return }
                let oldData = dataSource
                
                // We use dirtyVersion to figure out whether dirty during async updating.
                withLock {
                    dirtyVersion += 1
                }
                
                if oldData.sections.isEmpty || newData.sections.isEmpty {
                    Logger.log("<PartialCompositeTrasaction> update view: reload data without differ")
                    doReloadDataSourceWithoutDiff(oldData: oldData, newData: newData, synchronize: synchronize)
                }
                else {
                    Logger.log("<PartialCompositeTrasaction> update view: reload data with differ")
                    doReloadDataSourceWithDiff(oldData: oldData, newData: newData, synchronize: synchronize) { finished in
                        // Do nothing
                    }
                }
            }
            else if transaction.invalidateContentSize {
                Logger.log("<PartialCompositeTrasaction> update view: invalidate content size")
                doUpdateListViewLayout(synchronize: synchronize)
            }
            else {
                Logger.log("<PartialCompositeTrasaction> update view: update item")
                doUpdateItemView(synchronize: synchronize)
            }
        }
        
        @MainActor
        private func doUpdateViewRecursively() -> PartialCompositeTrasaction {
            isUpdating = true
            defer {
                isUpdating = false
            }
            
            let finalTransaction = PartialCompositeTrasaction()
            
            var transaction = self.transaction
            self.transaction = PartialCompositeTrasaction()
            
            while transaction.isDirty {
                finalTransaction.merge(transaction)
                transaction.updateView()
                
                if self.transaction.invalidateDataSource {
                    globalPipeline.markDirty(self)
                    break;
                }
                transaction = self.transaction
                self.transaction = PartialCompositeTrasaction()
            }
            
            let presenters = finalTransaction.collectInvalidatedContentSizeItemPresenter()
            invalidation?.invalidateContentSize(self, presenters)
            
            return finalTransaction
        }
        
        @MainActor
        private func collectNewDataSource() -> DataSource? {
            guard let root = root else {
                return nil
            }
            
            typealias Section = DataSource.Section
            typealias Item = DataSource.Item
            
            let dataSource = DataSource(root: root)
            dataSource.sections = root.sections.map({
                Section(presenter: $0, items: $0.items.map({
                    Item(presenter: $0)
                }), supplementaries: { section in
                    var supplementaries = [String: [Item]]()
                    for (kind, origins) in section.supplementaries {
                        supplementaries[kind] = origins.map({ Item(presenter: $0) })
                    }
                    return supplementaries
                }($0))
            })
            return dataSource
        }
        
        @MainActor
        private func doReloadDataSourceWithoutDiff(oldData: Engine.DataSource,
                                                   newData: Engine.DataSource,
                                                   synchronize: Bool) {
            let oldSections = oldData.sections
            let newSections = newData.sections
            
            // clear size caches
            for section in newSections {
                transaction.invalidateContentSize(of: section)
            }
            
            // update & batch update list view
            let transaction = doUpdateViewRecursively()
            let context = transaction.reloadDataContext
            
            if context.forceDisableAnimation {
                self.dataSource = newData
                self.listView.reloadData()
            }
            performBatchUpdates(with: context, synchronize: synchronize) {
                if !context.forceDisableAnimation {
                    self.dataSource = newData
                    if oldSections.count == 0 {
                        self.listView.insertSections(IndexSet(integersIn: 0 ... newSections.count))
                    }
                    else {
                        self.listView.deleteSections(IndexSet(integersIn: 0 ..< oldSections.count))
                    }
                }
                transaction.updateLayout()
            } completion: {
                transaction.complete()
            }
        }
        
        @MainActor
        private func doReloadDataSourceWithDiff(oldData: Engine.DataSource,
                                                newData: Engine.DataSource,
                                                synchronize: Bool,
                                                _ completion: @escaping (Bool) -> Void) {
            if synchronize {
                let result = doDiff(oldData: oldData, newData: newData)
                doReloadDataSourceApplyDiff(with: result, synchronize: synchronize)
                completion(true)
            }
            else {
                let originDirtyVersion = withLock { dirtyVersion }
                queue.async { [weak self] in
                    guard let self, self.withLock({ self.dirtyVersion == originDirtyVersion }) else {
                        completion(false)
                        return
                    }
                    
                    let result = self.doDiff(oldData: oldData, newData: newData)
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self, self.withLock({ self.dirtyVersion == originDirtyVersion }) else {
                            completion(false)
                            return
                        }
                        guard !self.isDestroyed else { return }
                        
                        self.doReloadDataSourceApplyDiff(with: result, synchronize: synchronize)
                        completion(true)
                    }
                }
            }
        }
        
        private struct DiffResult {
            var oldData: Engine.DataSource
            var newData: Engine.DataSource
            var sectionResult: Differ.IndexDiffResult
            var itemResult: [Differ.IndexPathDiffResult]
        }
        
        private func doDiff(oldData: Engine.DataSource, newData: Engine.DataSource) -> DiffResult {
            let differ = Differ()
            let sectionResult = differ.diff(old: oldData.sections,
                                            new: newData.sections)
            var itemResults: [Differ.IndexPathDiffResult] = []
            for (newIndex, newSection) in newData.sections.enumerated() {
                if let oldIndex = sectionResult.oldIndex(of: newSection) {
                    let oldSection = oldData.sections[oldIndex]
                    let itemResult = differ.diff(oldSection: oldIndex,
                                                 newSection: newIndex,
                                                 oldItems: oldSection.items,
                                                 newItems: newSection.items)
                    itemResults.append(itemResult)
                }
            }
            return DiffResult(oldData: oldData,
                              newData: newData,
                              sectionResult: sectionResult,
                              itemResult: itemResults)
        }
        
        @MainActor
        private func doReloadDataSourceApplyDiff(with result: DiffResult,
                                                 synchronize: Bool) {
            let (newData, sectionResult, itemResults) = (result.newData, result.sectionResult, result.itemResult)
            // remove cache size
            for index in sectionResult.inserts {
                transaction.invalidateContentSize(of: newData.sections[index])
            }
            for itemDiffer in itemResults {
                for indexPath in itemDiffer.inserts {
                    let item = newData.sections[indexPath.section].items[indexPath.item]
                    transaction.invalidateContentSize(of: item)
                }
            }
            // update & batch update list view
            let transaction = doUpdateViewRecursively()
            let context = transaction.reloadDataContext
            
            performBatchUpdates(with: context, synchronize: synchronize) {
                self.dataSource = newData
                self.listView.performBatchUpdates(sectionDiffer: sectionResult,
                                                  itemDiffer: itemResults)
                transaction.updateLayout()
            } completion: {
                transaction.complete()
            }
        }
        
        @MainActor
        private func doUpdateListViewLayout(synchronize: Bool) {
            let transaction = doUpdateViewRecursively()
            assert(!transaction.invalidateDataSource, "Should not change data source when updating views")
            doUpdateListViewLayout(with: transaction, synchronize: synchronize)
        }
        
        @MainActor
        private func doUpdateListViewLayout(with transaction: PartialCompositeTrasaction, synchronize: Bool) {
            let context = transaction.invalidateContentSizeContext
            
            performBatchUpdates(with: context, synchronize: synchronize) {
                self.listView.invalidateLayout()
                transaction.updateLayout()
            } completion: {
                transaction.complete()
            }
        }
        
        @MainActor
        private func doUpdateItemView(synchronize: Bool) {
            let transaction = doUpdateViewRecursively()
            assert(!transaction.invalidateDataSource, "Should not change data source when updating views")
            // When updating view, if content size invalidated, then update view with layout.
            if transaction.invalidateContentSize {
                doUpdateListViewLayout(with: transaction, synchronize: synchronize)
            } else {
                // If no content size changes, just update view immediately.
                transaction.updateLayout()
                transaction.complete()
            }
        }
        
        @MainActor
        private func performBatchUpdates(with context: ViewUpdateContext,
                                         synchronize: Bool,
                                         updater: @escaping ()->Void,
                                         completion: @escaping () -> Void) {
            if context.forceDisableAnimation {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.listView.performBatchUpdates(updater) { _ in
                    CATransaction.commit()
                    completion()
                }
            }
            else {
                self.listView.performBatchUpdates(updater) { _ in
                    completion()
                }
            }
        }
        
        
        private func withLock<T>(_ closure: () -> T) -> T {
            lock.lock()
            let value = closure()
            lock.unlock()
            return value
        }
    }
    
}

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

extension Presenter {
    
    /// Find nearest reusable presenter holder.
    @MainActor fileprivate var nearestItemPresenter: ReusableViewPresenterHoldable? {
        var p: Presenter? = self
        while p != nil {
            if let itemPresenter = p as? ReusableViewPresenterHoldable {
                return itemPresenter
            }
            p = p!.superPresenter
        }
        return nil
    }
}

@MainActor
class PartialCompositeTrasaction: CompositeTransaction {
    
    private struct PresenterStore: Hashable {
        var presenter: Presenter
        init(_ presenter: Presenter) {
            self.presenter = presenter
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.presenter == rhs.presenter
        }
        var hashValue: Int {
            return presenter.hashValue
        }
        func hash(into hasher: inout Hasher) {
            presenter.hash(into: &hasher)
        }
    }
    private struct SectionPresenterStore: Hashable {
        var presenter: CollectionSectionPresentable
        init(_ presenter: CollectionSectionPresentable) {
            self.presenter = presenter
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.presenter == rhs.presenter
        }
        var hashValue: Int {
            return presenter.hashValue
        }
        func hash(into hasher: inout Hasher) {
            presenter.hash(into: &hasher)
        }
    }
    
    private var invalidateContentSizePresenters = Set<PresenterStore>()
    private var invalidateContentSizeSectionPresenters = Set<SectionPresenterStore>()
    
    func merge(_ other: PartialCompositeTrasaction) {
        merge(other as CompositeTransaction)
        invalidateContentSizePresenters.formUnion(other.invalidateContentSizePresenters)
        invalidateContentSizeSectionPresenters.formUnion(other.invalidateContentSizeSectionPresenters)
    }
    
    override func markDirty(presenter: Presenter, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        if context.invalidateDataSource {
            if let section = presenter as? CollectionSectionPresentable {
                // When section invalidate content size, we need to update supplementaries size.
                // And items size will update by differ results which are inserted.
                invalidateContentSizeSectionPresenters.insert(SectionPresenterStore(section))
            }
        }
        
        if context.invalidateContentSize {
            // Sub presenter may invalidate content size, we need to find the item presenter it attached to.
            if let item = presenter.nearestItemPresenter {
                invalidateContentSizePresenters.insert(PresenterStore(item))
            }
        }
        super.markDirty(presenter: presenter, context: context, completion)
    }
    
    func invalidateContentSize(of section: Engine.DataSource.Section) {
        for p in section.items {
            invalidateContentSizePresenters.insert(PresenterStore(p.presenter))
        }
        for (_, supplies) in section.supplementaries {
            for p in supplies {
                invalidateContentSizePresenters.insert(PresenterStore(p.presenter))
            }
        }
    }
    
    func invalidateContentSize(of item: Engine.DataSource.Item) {
        invalidateContentSizePresenters.insert(PresenterStore(item.presenter))
    }
    
    func collectInvalidatedContentSizeItemPresenter() -> [Presenter] {
        var presenters = invalidateContentSizePresenters.map({ $0.presenter as Presenter })
        for presenter in invalidateContentSizeSectionPresenters {
            for (_, ps) in presenter.presenter.supplementaries {
                presenters.append(contentsOf: ps)
            }
        }
        invalidateContentSizePresenters.removeAll()
        invalidateContentSizeSectionPresenters.removeAll()
        return presenters
    }
}

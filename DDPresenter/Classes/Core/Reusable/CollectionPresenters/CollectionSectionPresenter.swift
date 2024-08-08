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

/// Section presenter type, used by view of collection type.
public protocol CollectionSectionPresentable: Presenter {
    
    /// Items in this section
    @MainActor var items: [Presenter] { get }
    
    /// Supplementaries in this section
    @MainActor var supplementaries: [String: [Presenter]] { get }
}

/// SectionPresenter for view of collection type, like UITableView or UICollectionView.
open class CollectionSectionPresenter<ItemType: Presenter>: ViewPresenter<Void>, CollectionSectionPresentable {
    
    @MainActor public convenience init(items: [ItemType]) {
        self.init()
        self.items = items
    }
    
    private var _items: [ItemType] = []
    
    /// Item presenters. Rows in UITableView
    @MainActor public var items: [Presenter] {
        get { _items }
        set {
            assert(newValue is [ItemType], "Item type MUST match \(ItemType.self)")
            setItems(newValue as? [ItemType] ?? [])
        }
    }
    
    @MainActor public var typedItems: [ItemType] {
        get { _items }
        set {
            setItems(newValue)
        }
    }
    
    @MainActor public func setItems(_ newValue: [ItemType], animated: Bool = false, completion: (()->Void)? = nil) {
        let oldValue = _items
        _items = newValue
        // Remove old ones from children if not existing in new items.
        let newSet = Set(_items.map({ ObjectIdentifier($0) }))
        for old in oldValue {
            if !newSet.contains(ObjectIdentifier(old)) {
                remove(child: old)
            }
        }
        // Add new items to children, do nothing if already in chidren.
        for item in _items {
            // Only new item needs adding child.
            if item.superPresenter !== self {
                add(child: item)
            }
        }
        setState(updater: {}, context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }, completion: completion)
    }
    
    @MainActor var _supplementaries: [String: [ItemType]] = [:]
    
    /// Supplementary view presenters. Not available in UITableView, and just for storage of header & footer.
    @MainActor public var supplementaries: [String: [Presenter]] {
        _supplementaries
    }
    
    /// Supplementary view presenters. Not available in UITableView, and just for storage of header & footer.
    @MainActor public var typedSupplementaries: [String: [ItemType]] {
        _supplementaries
    }
    
    /// Set supplementary with kind
    /// - Parameters:
    ///   - kind: Type of supplementary
    ///   - supplementaries: Supplementary view presenters
    ///   - animated: Whether update with animtion.
    @MainActor public func setSupplementary(_ kind: String,
                                 _ supplementaries: [ItemType]?,
                                 animated: Bool = false,
                                 completion: (()->Void)? = nil) {
        guard let supplementaries = supplementaries else {
            removeSupplementary(kind)
            return
        }

        // Remove old ones from children if not existing in supplementaries
        let newSet = Set(supplementaries.map({ ObjectIdentifier($0) }))
        if let olds = _supplementaries[kind] {
            for old in olds {
                if newSet.contains(ObjectIdentifier(old)) {
                    remove(child: old)
                }
            }
        }
        // Add new supplementaries to children, do nothing if already in chidren.
        for supplementary in supplementaries {
            // Only new supplementary needs adding child.
            if supplementary.superPresenter !== self {
                add(child: supplementary)
            }
        }
        setState(updater: {
            self._supplementaries[kind] = supplementaries
        }, context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }, completion: completion)
    }
    
    /// Remove supplementary by kind
    /// - Parameter kind: Type of supplementary
    @MainActor public func removeSupplementary(_ kind: String, animated: Bool = false) {
        if let olds = _supplementaries[kind] {
            for old in olds {
                remove(child: old)
            }
        }
        
        setState {
            self._supplementaries[kind] = nil
        } context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }
    }
    
}


// Use the same name for UITableView & UICollectionView
enum CollectionElementKind {
    static let sectionHeader = UICollectionView.elementKindSectionHeader
    static let sectionFooter = UICollectionView.elementKindSectionFooter
}

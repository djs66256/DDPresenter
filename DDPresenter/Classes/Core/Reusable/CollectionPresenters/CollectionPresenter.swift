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

/// Base presenter for UICollectionView or UITableView
public protocol CollectionPresentable: Presenter {
    
    /// Sections in this collection view.
    @MainActor var sections: [CollectionSectionPresentable] { get }
}

open class CollectionPresenter<View, SectionType: CollectionSectionPresentable>: ViewPresenter<View>, CollectionPresentable {
    public override init() {
        super.init()
        
        // Section presenters donot need bind view.
        autoBindChildrenPresenterViews = false
    }
    
    @MainActor private var _sections: [SectionType] = []
    @MainActor public var sections: [CollectionSectionPresentable] {
        _sections
    }
    
    @MainActor public var typedSections: [SectionType] {
        get { _sections }
        set { setSections(newValue) }
    }
    
    @MainActor public func setSections(_ sections: [SectionType], animated: Bool = false, completion: (()->Void)? = nil) {
        // If new sections are already in the parent, do not need remove then add,
        // so just remove children not exist in the new sections.
        let oldValue = _sections
        let newSet = Set(sections.map({ ObjectIdentifier($0) }))
        for old in oldValue {
            if !newSet.contains(ObjectIdentifier(old)) {
                remove(child: old)
            }
        }
        _sections = sections
        for section in sections {
            add(child: section)
        }
        setState(updater: {}, context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }, completion: completion)
    }
}

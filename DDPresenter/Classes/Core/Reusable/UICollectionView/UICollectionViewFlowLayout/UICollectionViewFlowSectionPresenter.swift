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

/// Config flow layout for section
public struct UICollectionViewFlowSectionLayoutInfo: UICollectionViewLayoutInfo {
    public var inset: UIEdgeInsets = .zero
    public var lineSpacing: CGFloat = 0
    public var itemSpacing: CGFloat = 0
    public var columnCount: Int = 1
    public init() {}
}

public protocol UICollectionViewFlowSectionPresentable: UICollectionViewSectionPresentable {
    var layoutInfo: UICollectionViewFlowSectionLayoutInfo { get }
}

open class UICollectionViewFlowSectionPresenter: CollectionSectionPresenter<UICollectionViewReusablePresenterHolder>, UICollectionViewFlowSectionPresentable {
    public var layoutInfo = UICollectionViewFlowSectionLayoutInfo()
}

public extension UICollectionViewFlowSectionPresenter {
    
    @MainActor var header: UICollectionViewReusablePresenterHolder? {
        get {
            typedSupplementaries[CollectionElementKind.sectionHeader]?.first
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionHeader, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionHeader)
            }
        }
    }
    
    @MainActor var footer: UICollectionViewReusablePresenterHolder? {
        get {
            typedSupplementaries[CollectionElementKind.sectionFooter]?.first
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionFooter, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionFooter)
            }
        }
    }
}

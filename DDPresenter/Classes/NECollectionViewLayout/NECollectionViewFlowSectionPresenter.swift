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
import NECollectionViewLayout

/// Section presenter for NECollectionViewFlowLayout
open class NECollectionViewFlowSectionPresenter: CollectionSectionPresenter<UICollectionViewReusablePresenterHolder>, UICollectionViewSectionPresentable {

    public struct LayoutInfo: UICollectionViewLayoutInfo {
        public var inset: UIEdgeInsets = .zero
        public var lineSpacing: CGFloat = 0
        public var itemSpacing: CGFloat = 0
        public var columnCount: Double = 1

        public var additionZIndex: Int = 0
        public var headerPinToVisibleBounds: NECollectionViewFlowLayoutPinToVisibleBounds = .none
        public var footerPinToVisibleBounds: NECollectionViewFlowLayoutPinToVisibleBounds = .none

        public struct Background {
            public var visible: Bool = false
            public var inset: UIEdgeInsets = .zero
            public var includeSupplementarys: Bool = false
        }

        public var background: Background = Background()

        public var verticalAlignment: NECollectionViewFlowLayoutAlignment = .alignCenter
        public var horizontalAlignment: NECollectionViewFlowLayoutAlignment = .alignLeading

        public struct Scroll: UICollectionViewLayoutInfo {
            public enum HorizontalContentHeight {
                case auto
                case `static`(CGFloat)
            }

            public var direction: UICollectionView.ScrollDirection = .vertical
            public var horizontalHeight: HorizontalContentHeight = .auto
            public var pageEnable: Bool = false
            public var pageSize: CGSize = .zero
        }

        public var scroll: Scroll = Scroll()

        public init() {}
    }

    @MainActor public var layoutInfo = LayoutInfo() {
        didSet {
            setState(updater: {}, context: { $0.invalidateLayout = true })
        }
    }

    @MainActor private var proxy: NECollectionViewFlowLayoutProxy? {
        (superPresenter as? UICollectionViewPresentable)?.proxy as? NECollectionViewFlowLayoutProxy
    }

    @MainActor private var layout: NECollectionViewFlowLayout? {
        proxy?.collectionView.collectionViewLayout as? NECollectionViewFlowLayout
    }

    @MainActor public var contentOffset: CGPoint? {
        get {
            guard let layout, let proxy,
                  let section = proxy.section(for: self) else {
                return nil
            }
            return layout.contentOffsetForSection(at: section)
        }
        set {
            guard let newValue, let layout, let proxy,
                  let section = proxy.section(for: self) else {
                return
            }
            layout.setContentOffset(newValue, forSectionAt: section)
        }
    }

    @MainActor public var frame: CGRect? {
        guard let layout, let proxy,
              let section = proxy.section(for: self) else {
            return nil
        }
        return layout.frameForSection(at: section)
    }

    @MainActor open func didScroll(to contentOffset: CGPoint) {}

}

public extension NECollectionViewFlowSectionPresenter {

    @MainActor var header: UICollectionViewReusablePresenterHolder? {
        get {
            typedSupplementaries[UICollectionView.elementKindSectionHeader]?.first
        }
        set {
            if let newValue {
                setSupplementary(UICollectionView.elementKindSectionHeader, [newValue])
            } else {
                removeSupplementary(UICollectionView.elementKindSectionHeader)
            }
        }
    }

    @MainActor var footer: UICollectionViewReusablePresenterHolder? {
        get {
            typedSupplementaries[UICollectionView.elementKindSectionFooter]?.first
        }
        set {
            if let newValue {
                setSupplementary(UICollectionView.elementKindSectionFooter, [newValue])
            } else {
                removeSupplementary(UICollectionView.elementKindSectionFooter)
            }
        }
    }

    @MainActor var background: UICollectionViewReusablePresenterHolder? {
        get {
            typedSupplementaries[NECollectionElementKindSectionBackground]?.first
        }
        set {
            if let newValue {
                setSupplementary(NECollectionElementKindSectionBackground, [newValue])
            } else {
                removeSupplementary(NECollectionElementKindSectionBackground)
            }
        }
    }

}

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

public class NECollectionViewFlowLayoutProxy: UICollectionViewDelegateProxy, NECollectionViewDelegateFlowLayout {

    private var flowLayout: NECollectionViewFlowLayout? {
        collectionView.collectionViewLayout as? NECollectionViewFlowLayout
    }

    private var containerSize: CGSize {
        assert(flowLayout != nil)
        let inset = collectionView.contentInset
        return CGSize(width: collectionView.frame.width - inset.left - inset.right, height: .infinity)
    }

    private func containerSize(at section: Int) -> CGSize {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            let inset = p.layoutInfo.inset
            let containerSize = self.containerSize
            var size = CGSize(width: containerSize.width - inset.left - inset.right,
                              height: containerSize.height - inset.top - inset.bottom)
            let columnCount = p.layoutInfo.columnCount
            if columnCount > 1 {
                if p.layoutInfo.scroll.direction == .horizontal {
                    size.width = floor((size.width - CGFloat(columnCount - 1) * p.layoutInfo.itemSpacing) / CGFloat(columnCount))
                } else {
                    size.height = floor((size.height - CGFloat(columnCount - 1) * p.layoutInfo.itemSpacing) / CGFloat(columnCount))
                }
            }
            return size
        }

        return .zero
    }

    private func transform(for layoutType: UICollectionItemFlowLayoutInfo.LayoutType) -> SizeCaculator.LayoutType {
        switch layoutType {
        case .autoLayout: .autoLayout
        case .sizeThatFits: .sizeThatFits
        case .intrinsicContentSize: .intrinsicContentSize
        }
    }

    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let item: UICollectionViewReusablePresenterHolder = itemPresenter(at: indexPath) {
            if let cachedSize = getCachedSize(for: item) {
                return cachedSize
            } else {
                let containerSize = containerSize(at: indexPath.section)
                let calculatedSize = calculateItemSize(presenter: item, containerSize: containerSize)
                setCachedSize(calculatedSize, for: item)
                return calculatedSize
            }
        }
        return .zero
    }

    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.inset
        }

        return .zero
    }

    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.lineSpacing
        }

        return 0
    }

    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.itemSpacing
        }

        return 0
    }

    public func headerPresenter(at section: Int) -> UICollectionViewReusablePresenterHolder? {
        supplementaryPresenter(for: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section))
    }

    public func footerPresenter(at section: Int) -> UICollectionViewReusablePresenterHolder? {
        supplementaryPresenter(for: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section))
    }

    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let item: UICollectionViewReusablePresenterHolder = headerPresenter(at: section) {
            if let cachedSize = getCachedSize(for: item) {
                return cachedSize
            } else {
                let calculatedSize = calculateItemSize(presenter: item, containerSize: containerSize)
                setCachedSize(calculatedSize, for: item)
                return calculatedSize
            }
        }

        return .zero
    }

    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let item: UICollectionViewReusablePresenterHolder = footerPresenter(at: section) {
            return calculateItemSize(presenter: item, containerSize: containerSize)
        }

        return .zero
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               scrollViewDidScrollToContentOffset contentOffset: CGPoint, forSectionAt section: Int) {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            p.didScroll(to: contentOffset)
        }
    }

    /// Addtion z index for all item in the section. For example, default 0 will be ( 0 + addition ) zIndex.
    /// May used for more complex custom layout.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               additionZIndexForSectionAt section: Int) -> Int {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.additionZIndex
        }
        return 0
    }

    /// The section header pin to visible bounds config.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               headerPinToVisibleBoundsForSectionAt section: Int) -> NECollectionViewFlowLayoutPinToVisibleBounds {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.headerPinToVisibleBounds
        }
        return .none
    }

    /// The section footer pin to visible bounds config.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               footerPinToVisibleBoundsForSectionAt section: Int) -> NECollectionViewFlowLayoutPinToVisibleBounds {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.footerPinToVisibleBounds
        }
        return .none
    }

    /// Show a background view in the section below the items.
    /// Once return YES, you MUST return a supplementary view of NECollectionElementKindSectionBackground.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               backgroundVisibleForSectionAt section: Int) -> Bool {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.background.visible && {
                let background: Presenter? = supplementaryPresenter(for: NECollectionElementKindSectionBackground, at: IndexPath(item: 0, section: section))
                return background != nil
            }()
        }
        return false
    }

    /// Define the background size. If return YES, the size will contains the header & footer.
    /// Otherwise it is just the items size, without SectionInsets.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               backgroundIncludeSupplementarysForSectionAt section: Int) -> Bool {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.background.includeSupplementarys
        }
        return false
    }

    /// This method gives you a change to modify the background size that calculate by above configs.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               backgroundInsetsForSectionAt section: Int) -> UIEdgeInsets {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.background.inset
        }
        return .zero
    }

    /// Declare the horizontal aligment of a line in the section.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               alignHorizontalForSectionAt section: Int) -> NECollectionViewFlowLayoutAlignment {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.horizontalAlignment
        }
        return .alignLeading
    }

    /// Declare the vertical aligment of a line in the section.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               alignVerticalForSectionAt section: Int) -> NECollectionViewFlowLayoutAlignment {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.verticalAlignment
        }
        return .alignCenter
    }

    /// Declare the scroll direction of the section. Default Vertical.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               scrollDirectionForSectionAt section: Int) -> UICollectionView.ScrollDirection {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.scroll.direction
        }
        return .horizontal
    }

    /// Declare the content height of the section, when scroll direction Horizontal. Default 0.
    /// Return 0 means use items max height, and location in one line.
    /// When is not 0, layout will effect by vertical alignment and horizontal alignment.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               heightForScrollHorizontalSectionAt section: Int) -> CGFloat {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            switch p.layoutInfo.scroll.horizontalHeight {
            case .auto: return 0
            case .static(let value): return value
            }
        }
        return 0
    }

    /// Enable page scroll in the section.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               pageEnableForSectionAt section: Int) -> Bool {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.scroll.pageEnable
        }
        return false
    }

    /// Decide the page width of the scroll view. Default CGSizeZero.
    /// Zero means the page size is equal to the frame.
    /// Height is no meaning now, for preversed usage.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               layout: UICollectionViewLayout,
                               pageSizeForSectionAt section: Int) -> CGSize {
        if let p: NECollectionViewFlowSectionPresenter = sectionPresenter(at: section) {
            return p.layoutInfo.scroll.pageSize
        }
        return .zero
    }

}

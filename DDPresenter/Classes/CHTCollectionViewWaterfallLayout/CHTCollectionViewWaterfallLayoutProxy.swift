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
import CHTCollectionViewWaterfallLayout

/// Layout proxy for CHTCollectionViewWaterfallLayout.
/// Must use CHTCollectionViewWaterfallSectionPresenter for section presenters.
public class CHTCollectionViewWaterfallLayoutProxy : UICollectionViewDelegateProxy, CHTCollectionViewDelegateWaterfallLayout {
    
    
    /// Container size for caculate cell size.
    /// - Parameter section: section index
    /// - Returns: Max container size for cell, and the height is infinity.
    private func containerSize(for section: Int) -> CGSize {
        // Waterfall use visible width to determine column width.
        let maxWidth = collectionView.frame.width
        if let p: CHTCollectionViewWaterfallSectionPresenter = sectionPresenter(at: section), p.layoutInfo.columnCount >= 1 {
            // Width - insets.horizontal - all item spacing
            let contentWidth = (maxWidth -
                                p.layoutInfo.inset.left - p.layoutInfo.inset.right -
                                max(0, p.layoutInfo.itemSpacing * CGFloat((p.layoutInfo.columnCount - 1))))
            return CGSize(width: contentWidth / CGFloat(p.layoutInfo.columnCount), height: .infinity)
        }
        return CGSize(width: maxWidth, height: .infinity)
    }
    
    private func transform(for layoutType: UICollectionItemFlowLayoutInfo.LayoutType) -> SizeCaculator.LayoutType {
        switch layoutType {
        case .autoLayout: .autoLayout
        case .sizeThatFits: .sizeThatFits
        case .intrinsicContentSize: .intrinsicContentSize
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let p: UICollectionViewReusablePresenterHolder = self.itemPresenter(at: indexPath) {
            let containerSize = containerSize(for: indexPath.section)
            return calculateItemSize(presenter: p, containerSize: containerSize)
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               heightForHeaderIn section: Int) -> CGFloat {
        if let p: CHTCollectionViewWaterfallSectionPresenter = self.sectionPresenter(at: section) {
            return p.layoutInfo.headerHeight
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               heightForFooterIn section: Int) -> CGFloat {
        if let p: CHTCollectionViewWaterfallSectionPresenter = self.sectionPresenter(at: section) {
            return p.layoutInfo.footerHeight
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetsFor section: Int) -> UIEdgeInsets {
        if let p: CHTCollectionViewWaterfallSectionPresenter = self.sectionPresenter(at: section) {
            return p.layoutInfo.inset
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingFor section: Int) -> CGFloat {
        if let p: CHTCollectionViewWaterfallSectionPresenter = self.sectionPresenter(at: section) {
            return p.layoutInfo.itemSpacing
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               columnCountFor section: Int) -> Int {
        if let p: CHTCollectionViewWaterfallSectionPresenter = self.sectionPresenter(at: section) {
            return p.layoutInfo.columnCount
        }
        return 1
    }
}

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

open class UICollectionViewFlowLayoutProxy: UICollectionViewDelegateProxy, UICollectionViewDelegateFlowLayout {
    
    private var flowLayout: UICollectionViewFlowLayout? {
        collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var containerSize: CGSize {
        assert(flowLayout != nil)
        if let flowLayout = flowLayout {
            let inset = collectionView.contentInset
            if flowLayout.scrollDirection == .horizontal {
                return CGSize(width: .infinity, height: collectionView.frame.height - inset.top - inset.bottom)
            }
            else {
                return CGSize(width: collectionView.frame.width - inset.left - inset.right, height: .infinity)
            }
        }
        return .zero
    }
    
    private func containerSize(at section: Int) -> CGSize {
        if let flowLayout = flowLayout,
           let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            let inset = p.layoutInfo.inset
            let containerSize = self.containerSize
            var size = CGSize(width: containerSize.width - inset.left - inset.right,
                              height: containerSize.height - inset.top - inset.bottom)
            let columnCount = p.layoutInfo.columnCount
            if columnCount > 1 {
                if flowLayout.scrollDirection == .vertical {
                    size.width = floor((size.width - CGFloat(columnCount - 1) * p.layoutInfo.itemSpacing) / CGFloat(columnCount))
                }
                else {
                    size.height = floor((size.height - CGFloat(columnCount - 1) * p.layoutInfo.itemSpacing) / CGFloat(columnCount))
                }
            }
            return size
        }
        
        return .zero
    }
    
//    private func calculateItemSize(_ presenter: UICollectionViewReusablePresenterHolder, containerSize: CGSize) -> CGSize {
//        let info = presenter.layoutInfo
//        if info.calculateSizeAutomatically {
//            return calculateItemSize(presenter, containerSize)
//        }
//        else {
//            return presenter.calculateSize(containerSize: containerSize)
//        }
//    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let item: UICollectionViewReusablePresenterHolder = dataSource.item(at: indexPath) {
            if let cachedSize = sizeCache[item] {
                return cachedSize
            }
            else {
                let containerSize = containerSize(at: indexPath.section)
                let calculatedSize = calculateItemSize(presenter: item, containerSize: containerSize)
                sizeCache[item] = calculatedSize
                return calculatedSize
            }
        }
        return .zero
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            return p.layoutInfo.inset
        }
        
        return .zero
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            return p.layoutInfo.lineSpacing
        }
        
        return 0
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            return p.layoutInfo.itemSpacing
        }
        
        return 0
    }
    
    public func headerPresenter(at section: Int) -> UICollectionViewReusablePresenterHolder? {
        dataSource.supplementary(for: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section))
    }
    
    public func footerPresenter(at section: Int) -> UICollectionViewReusablePresenterHolder? {
        dataSource.supplementary(for: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section))
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let item: UICollectionViewReusablePresenterHolder = headerPresenter(at: section) {
            if let cachedSize = sizeCache[item] {
                return cachedSize
            }
            else {
                let calculatedSize = calculateItemSize(presenter: item, containerSize: containerSize)
                sizeCache[item] = calculatedSize
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
}


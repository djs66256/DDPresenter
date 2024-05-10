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

protocol CHTCollectionViewWaterfallSectionPresentable: UICollectionViewSectionPresentable {}

/// The section presenter used by CHTCollectionViewWaterfallLayout.
open class CHTCollectionViewWaterfallSectionPresenter:
    CollectionSectionPresenter<UICollectionViewReusablePresenterHolder>, CHTCollectionViewWaterfallSectionPresentable {
    
    /// Section configurations for CHTCollectionViewWaterfallLayout.
    public struct LayoutInfo: UICollectionViewLayoutInfo {
        public var inset: UIEdgeInsets = .zero
        public var itemSpacing: CGFloat = 0
        public var columnCount: Int = 1
        public var headerHeight: CGFloat = 0
        public var footerHeight: CGFloat = 0
        public init() {}
    }
    
    @MainActor public var layoutInfo = LayoutInfo() {
        didSet {
            setState(updater: {}, context: {
                // Any changes should relayout collection view.
                $0.invalidateLayout = true
            })
        }
    }
}

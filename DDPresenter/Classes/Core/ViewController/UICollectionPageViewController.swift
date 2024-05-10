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

/// PageViewController for UICollectionView, like UICollectionViewController.
open class UICollectionPageViewController<P, V, LayoutType, SectionType>: 
    PageViewController<V, P, V>
where P: UICollectionViewRootPresenter<V, SectionType>,
      V: UICollectionView,
      LayoutType: UICollectionViewLayout,
      SectionType: UICollectionViewSectionPresentable
{
    
    /// Override for custom UICollectionView type
    /// - Returns: UICollectionView instance
    open override func makeView() -> V {
        V(frame: .zero, collectionViewLayout: collectionViewLayout)
    }
    
    @MainActor public lazy var collectionViewLayout: LayoutType = makeCollectionViewLayout()
    
    /// Override for custom UICollectionViewLayout
    /// - Returns: UICollectionView instance
    @MainActor open func makeCollectionViewLayout() -> LayoutType {
        LayoutType()
    }
}

/// A default implementary of PageViewController for UICollectionView with flow layout
public typealias UICollectionFlowPageViewController
= UICollectionPageViewController<UICollectionViewRootPresenter<UICollectionView, UICollectionViewFlowSectionPresenter>,
                                 UICollectionView,
                                 UICollectionViewFlowLayout,
                                 UICollectionViewFlowSectionPresenter>

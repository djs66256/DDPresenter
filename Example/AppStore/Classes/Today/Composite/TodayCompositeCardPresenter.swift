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

import UIKit
import DDPresenter

struct TodayCompositeCardConstants {
    static let headerHeight: CGFloat = 120
    static let cellHeight: CGFloat = 60
    static let inset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    
    static func height(cellCount: Int) -> CGFloat {
        headerHeight + cellHeight * CGFloat(cellCount) + inset.top + inset.bottom
    }
}

class TodayCompositeCardPresenter: UICollectionViewFlowReusableItemPresenter<TodayCompositeCardCell> {
    
    typealias View = TodayCompositeCardCell
    
    private lazy var sectionPresenter = UICollectionViewFlowSectionPresenter()
    private lazy var collectionViewPresenter = UICollectionViewFlowPresenter()
    @MainActor private var itemPresenters: [TodayCompositeInnerPresenterHolder] = [] {
        didSet {
            sectionPresenter.setItems(itemPresenters)
        }
    }
    
    @MainActor var appInfos: [AppInfo] = [] {
        didSet {
            if appInfos != oldValue {
                itemPresenters = appInfos.map { appInfo in
                    let p = TodayCompositeInnerPresenterHolder()
                    p.appInfo = appInfo
                    return p
                }
                setState {} context: { ctx in
                    ctx.invalidateContentSize = true
                }
            }
        }
    }
    @MainActor var expandIndex: Int? {
        didSet {
            if expandIndex != oldValue {
                for (index, presenter) in itemPresenters.enumerated() {
                    presenter.selected = index == expandIndex
                }
                setState {} context: { ctx in
                    ctx.invalidateContentSize = true
                }
            }
        }
    }
    
    required init() {
        super.init()
        
        sectionPresenter.header = TodayCompositeHeaderPresenter()
        sectionPresenter.layoutInfo.inset = TodayCompositeCardConstants.inset
        collectionViewPresenter.setSections([sectionPresenter])
        add(child: collectionViewPresenter)
        
        layoutInfo.calculateSizeAutomatically = false
    }
    
    override func calculateSize(containerSize: CGSize) -> CGSize {
        let height = (sectionPresenter.header?.calculateSize(containerSize: containerSize).height ?? 0) +
        sectionPresenter.layoutInfo.inset.top +
        sectionPresenter.layoutInfo.inset.bottom +
        itemPresenters.reduce(0.0, { partialResult, holder in
            partialResult + holder.calculateSize(containerSize: containerSize).height
        })
        return CGSize(width: containerSize.width, height: height)
    }
    
}

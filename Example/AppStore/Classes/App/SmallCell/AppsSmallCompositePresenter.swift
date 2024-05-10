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

class AppsSmallCompositePresenter: UICollectionViewFlowReusableItemPresenter<AppsSmallCompositeCell> {
    typealias View = AppsSmallCompositeCell
    
    let collectionPresenter = UICollectionViewFlowPresenter()
    let sectionPresenter = UICollectionViewFlowSectionPresenter()
    @MainActor var itemPresenters: [AppsSmallAppPresenterHolder] = [] {
        didSet {
            sectionPresenter.setItems(itemPresenters)
        }
    }
    
    @MainActor var apps: [AppInfo] = [] {
        didSet {
            itemPresenters = apps.map {
                let p = AppsSmallAppPresenterHolder()
                p.app = $0
                return p
            }
        }
    }
    
    required init() {
        super.init()
        
        layoutInfo.calculateSizeAutomatically = false
        
        add(child: collectionPresenter)
        collectionPresenter.setSections([sectionPresenter])
    }
    
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: itemPresenters.reduce(0.0, {
            $0 + $1.calculateSize(containerSize: containerSize).height
        }))
    }
    
    override func onAttachToRoot(_ presenter: RootViewPresentable) {
        super.onAttachToRoot(presenter)
        
        // Get service and add listeners
    }
    
    override func onDetachFromRoot(_ presenter: RootViewPresentable) {
        super.onDetachFromRoot(presenter)
        
        // Get service and remove listeners
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        
        // view.delegate = self
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        
        // view?.delegate = nil
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        // Update view state here
    }
    
    // func onDelegate() {
    //     getService(MyService.self)?.doSomething()
    //     notifyGlobal(listener: MyNotifier.self) {
    //         $0.onNotify()
    //     }
    // }
    
}

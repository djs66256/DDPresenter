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

class AppsLargeAppPresenterHolder: UICollectionViewFlowItemPresenterHolder<AppsLargeAppPresenter, AppsLargeAppCell> {
    typealias Presenter = AppsLargeAppPresenter
    
    @MainActor var app: AppInfo? {
        didSet {
            setState {}
        }
    }
    
    override init() {
        super.init()
        
        layoutInfo.calculateSizeAutomatically = false
    }
    
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 20 + containerSize.width * 0.8)
    }
    
    override func onUpdate(presenter: Presenter, context: ViewUpdateContext) {
        super.onUpdate(presenter: presenter, context: context)
        
        presenter.app = app
    }
    
}

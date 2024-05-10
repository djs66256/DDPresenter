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

public class RedBookHomePageViewController: CHCollectionWaterfallPageViewController<UICollectionView> {

    let section = CHTCollectionViewWaterfallSectionPresenter()

    public override func presenterDidLoad() {
        super.presenterDidLoad()
        
        // Do any additional setup after loading the presenter.
        
        // Register services.
        // register(service: TraceService.self) {
        //      TraceServiceImpl()
        // }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        presenter.collectionViewPresenter.setSections([section])
        section.layoutInfo.apply { layoutInfo in
            layoutInfo.columnCount = 2
            layoutInfo.itemSpacing = 10
            layoutInfo.inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        
        let items = HomeItem.mock.map { data in
            let p = HomeCardPresenterHolder()
            p.item = data
            return p
        }
        section.setItems(items)
    }

}

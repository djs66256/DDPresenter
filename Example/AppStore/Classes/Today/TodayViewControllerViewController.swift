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

class TodayViewControllerViewController: UICollectionFlowPageViewController {

    let section = UICollectionViewFlowSectionPresenter()

    override func presenterDidLoad() {
        super.presenterDidLoad()
        
        // Do any additional setup after loading the presenter.
        
        // Register services.
        register(service: TodayDataLoaderService.self) {
            TodayDataLoaderServiceImpl()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        section.layoutInfo.apply {
            $0.itemSpacing = 10
            $0.lineSpacing = 10
            $0.inset = UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 15)
        }
        section.header = TodayHeaderPresenter()
//        section.setItems([
//            {
//                let p = TodayLargestCardPresenterHolder()
//                p.appInfo = .mock().mockDownloadSuccess(duration: Double.random(in: 10...20))
//                return p
//            }(),
//            {
//                let p = TodaySmallCardPresenterHolder()
//                p.appInfo = .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
//                return p
//            }(),
//            {
//                let p = TodayCompositeCardPresenterHolder()
//                p.appInfos = [
//                    .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
//                    .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
//                    .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
//                ]
//                return p
//            }()
//        ])
//        presenter.collectionViewPresenter.setSections([section])
        
        // Load data and update collection view
        getService(TodayDataLoaderService.self)?.loadData({ [weak self] data in
            guard let self else { return }
            section.setItems(data.map { $0.buildPresenter() }) { [weak self] in
                guard let self else { return }
                // You should scroll to visible after update view
                // section.typedItems[4].scrollToVisible(animated: true)
            }
            
            presenter.collectionViewPresenter.setSections([section])
        })
    }

}

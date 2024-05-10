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

class AppViewControllerViewController: NECollectionFlowPageViewController<UICollectionView> {


    override func presenterDidLoad() {
        super.presenterDidLoad()
        
        // Do any additional setup after loading the presenter.
        
        // Register services.
        register(service: AppsDataLoaderService.self) {
            AppsDataLoaderServiceImpl()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task(priority: .low) {
            if let data = await getService(AppsDataLoaderService.self)?.loadData() {
                await MainActor.run {
                    var sections: [NECollectionViewFlowSectionPresenter] = []
                    for sectionData in data {
                        let section = NECollectionViewFlowSectionPresenter()
                        section.layoutInfo.columnCount = 1.1
                        let spacing: CGFloat = 10
                        section.layoutInfo.apply { layoutInfo in
                            layoutInfo.itemSpacing = spacing
                            layoutInfo.lineSpacing = spacing
                            layoutInfo.verticalAlignment = .alignLeading
                            layoutInfo.inset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
                            layoutInfo.scroll.apply {
                                $0.direction = .horizontal
                                $0.pageEnable = true
                                $0.pageSize = CGSize(width: (view.frame.width - 2 * spacing) / 1.1, height: 1)
                            }
                        }
                        if let title = sectionData.title {
                            let header = AppsHeaderPresenter()
                            header.title = title
                            section.header = header
                        }
                        
                        var items: [UICollectionViewReusablePresenterHolder] = []
                        if sectionData.isLarge {
                            for app in sectionData.apps {
                                let p = AppsLargeAppPresenterHolder()
                                p.app = app
                                items.append(p)
                            }
                        }
                        else {
                            for i in (0..<Int(ceil(Double(sectionData.apps.count) / 3.0))) {
                                let start = 3 * i
                                let apps = sectionData.apps[(start..<min(sectionData.apps.count, (start + 3)))]
                                if !apps.isEmpty {
                                    let p = AppsSmallCompositePresenterHolder()
                                    p.apps = Array(apps)
                                    items.append(p)
                                }
                            }
                        }
                        section.setItems(items)
                        sections.append(section)
                    }
                    presenter.collectionViewPresenter.setSections(sections)
                }
            }
        }
        
    }

}

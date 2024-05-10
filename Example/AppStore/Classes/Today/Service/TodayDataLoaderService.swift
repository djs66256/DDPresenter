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

protocol TodayItem: TodayItemPresenterBuilder {
    
}

protocol TodayItemPresenterBuilder {
    @MainActor func buildPresenter() -> UICollectionViewReusablePresenterHolder
}

protocol TodayDataLoaderService: Service {
    func loadData(_ completion: @escaping ([TodayItem])->Void)
}

class TodayDataLoaderServiceImpl: DirtyService, TodayDataLoaderService {
    static let mock: [TodayItem] = [
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                        style: .largest),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                            style: .small),
        TodayCompositeItem(appInfos: [
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        ]),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                        style: .largest),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                        style: .largest),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                        style: .largest),
        TodayCompositeItem(appInfos: [
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        ]),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                        style: .largest),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                            style: .small),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                        style: .largest),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                            style: .small),
        TodayCompositeItem(appInfos: [
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        ]),
        TodayCompositeItem(appInfos: [
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10)),
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        ]),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                            style: .small),
        TodaySingleItem(appInfo: .mock().mockDownloadSuccess(duration: Double.random(in: 3...20)),
                        style: .largest),
    ]
    
    func loadData(_ completion: @escaping ([TodayItem]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(Self.mock)
        }
    }
    
}

private struct TodaySingleItem: TodayItem {
    enum Style {
        case largest, small
    }
    let appInfo: AppInfo
    let style: Style
    
    init(appInfo: AppInfo, style: Style) {
        self.appInfo = appInfo
        self.style = style
    }
    
    func buildPresenter() -> DDPresenter.UICollectionViewReusablePresenterHolder {
        switch style {
        case .largest:
            let p = TodayLargestCardPresenterHolder()
            p.appInfo = appInfo
            return p
        case .small:
            let p = TodaySmallCardPresenterHolder()
            p.appInfo = appInfo
            return p
        }
    }
    
    
}

private struct TodayCompositeItem: TodayItem {
    let appInfos: [AppInfo]
    
    func buildPresenter() -> DDPresenter.UICollectionViewReusablePresenterHolder {let p = TodayCompositeCardPresenterHolder()
        p.appInfos = appInfos
        return p
    }
}

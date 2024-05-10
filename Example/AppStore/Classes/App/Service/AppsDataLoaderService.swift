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

struct AppsSectionModel {
    var isLarge: Bool = false
    var title: String?
    var apps: [AppInfo]
    
    fileprivate static let mock =
    [
        AppsSectionModel(isLarge: true, title: nil, apps: (0...8).map { _ in
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        } ),
        AppsSectionModel(title: "Mother's Day Limited-time Offers", apps: (0...8).map { _ in
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        } ),
        AppsSectionModel(title: "Popular Apps", apps: (0...13).map { _ in
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        } ),
        AppsSectionModel(title: "Top Free Apps", apps: (0...9).map { _ in
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        } ),
        AppsSectionModel(title: "15 Everyone's Favourite", apps: (0...8).map { _ in
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        } ),
        AppsSectionModel(isLarge: true, title: "Don't Miss These Events", apps: (0...8).map { _ in
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        } ),
        AppsSectionModel(title: "The Best Apps for iOS 17", apps: (0...8).map { _ in
                .mock().mockDownloadSuccess(duration: Double.random(in: 4...10))
        } ),
    ]
}

protocol AppsDataLoaderService: Service {
    func loadData() async -> [AppsSectionModel]
}

class AppsDataLoaderServiceImpl: DirtyService, AppsDataLoaderService {
    func loadData() async -> [AppsSectionModel] {
        return AppsSectionModel.mock
    }
}



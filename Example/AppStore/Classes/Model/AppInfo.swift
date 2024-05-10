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
import Service
import RandomColorSwift

class AppInfo: Identifiable, Equatable {
    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID = UUID()
    
    var name: String?
    var detailInfo: String?
    var icon: UIImage?
    
    static func mock(id: UUID = UUID()) -> AppInfo {
        let info = AppInfo()
        info.id = id
        info.name = randomString(in: 10...20)
        info.detailInfo = randomString(in: 20...50)
        info.icon = .imageFromColor(randomColor())
        return info
    }
    
    func mockDownloadSuccess(duration: Double = 0.4) -> Self {
        if let download = ServiceManager.shared.getService(DownloadService.self) {
            download.mockDownload(resource: self, duration: duration, result: .success(AppResult()))
        }
        return self
    }
}

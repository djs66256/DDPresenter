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

struct User: Equatable {
    var id: String = UUID().uuidString
    var name: String = randomString(in: 5...10)
    var avatar: UIImage? = .imageFromColor(randomColor(), size: CGSize(width: 1, height: 1))
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

struct HomeItem: Equatable {
    
    var id: String = UUID().uuidString
    var coverImage: UIImage? = .imageFromColor(randomColor(), size: CGSize(width: 100, height: .random(in: (100...200))))
    var title: String? = randomString(in: 20...30)
    var user: User = User()
    var liked: Bool = false
    var likeCount: Int = .random(in: 0...1000)

    static func == (lhs: HomeItem, rhs: HomeItem) -> Bool {
        lhs.id == rhs.id
    }
    
    static let mock = (0...50).map { _ in
        HomeItem()
    }
}

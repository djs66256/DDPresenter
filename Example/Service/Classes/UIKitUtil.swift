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

public extension UIImage {
    class func imageFromColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let render = UIGraphicsImageRenderer(size: size, format: .default())
        return render.image { render in
            color.setFill()
            render.fill(CGRect(origin: .zero, size: size))
        }
    }
}

public func randomString(in range: Range<Int>) -> String {
    let length = Int.random(in: range)
    return randomString(in: length)
}
public func randomString(in range: ClosedRange<Int>) -> String {
    let length = Int.random(in: range)
    return randomString(in: length)
}
public func randomString(in length: Int) -> String {
    let letters = Array("abc defg hijkl mnopqrstu vwxy zABCD EFGHIJ KLMNOPQ RSTU VWXYZ012 34567 89")
    var s = ""
    for _ in 0 ..< length {
        s.append(letters.randomElement()!)
    }
    return s
}

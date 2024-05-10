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

public protocol UITableViewSectionPresentable: CollectionSectionPresentable {
    @MainActor var headerTitle: String? { get }
    @MainActor var footerTitle: String? { get }
    @MainActor var indexTitle: String? { get }
}

open class UITableViewSectionPresenter: CollectionSectionPresenter<UITableViewReusablePresenterHolder>, UITableViewSectionPresentable {
    public var headerTitle: String? = nil
    public var footerTitle: String? = nil
    public var indexTitle: String? = nil
}


public extension UITableViewSectionPresenter {
    
    @MainActor var header: UITableViewReusablePresenterHolder? {
        get {
            typedSupplementaries[CollectionElementKind.sectionHeader]?.first
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionHeader, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionHeader)
            }
        }
    }
    
    @MainActor var footer: UITableViewReusablePresenterHolder? {
        get {
            typedSupplementaries[CollectionElementKind.sectionFooter]?.first
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionFooter, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionFooter)
            }
        }
    }
}

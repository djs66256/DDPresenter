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

public protocol ViewAutoBindable {
    @MainActor func findView<T>() -> T?
}

@MainActor
struct ViewAutoBinder {
    func findChildView<T>(presenter: Presenter) -> T? {
        if let customView = presenter.anyView as? ViewAutoBindable {
            return customView.findView()
        }
        else if let view = nearestUIView(presenter: presenter) {
            // Child presenter & super presenter are bound to same view.
            // Child presenter is a shadow presenter at this situation.
            if let v = view as? T {
                return v
            }
            return findViewBFS(views: view.subviews)
        }
        else {
            return nil
        }
    }
    
    private func nearestUIView(presenter: Presenter?) -> UIView? {
        guard let presenter = presenter else {
            return nil
        }
        
        if let view = presenter.anyView as? UIView {
            return view
        }
        else {
            return nearestUIView(presenter: presenter.superPresenter)
        }
    }
    
    private func findViewBFS<T>(views: [UIView]) -> T? {
        if (views.isEmpty) {
            return nil
        }
            
        var subviews = [UIView]()
        for view in views {
            if let v = view as? T {
                return v
            }
            subviews.append(contentsOf: view.subviews)
        }
        return findViewBFS(views: subviews)
    }
}

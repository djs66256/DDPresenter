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

open class UITableViewRootPresenter<V: UITableView>: RootViewPresenter<V> {
    @MainActor public let tableViewPresenter = UITableViewPresenter<V>()
    
    open override func onAttach() {
        super.onAttach()
        
        add(child: tableViewPresenter)
    }
    
    open override func onBindView(_ view: V) {
        super.onBindView(view)
        
        if !tableViewPresenter.tryBindWeakView(view) {
            assert(false, "Bind view failed!")
        }
    }
    
    open override func onUnbindView() {
        super.onUnbindView()
        
        tableViewPresenter.unbindView()
    }
}

/// PageViewController for UITableView, like UITableViewController.
open class UITablePageViewController<P: UITableViewRootPresenter<V>, V: UITableView>: PageViewController<V, P, V> {
    
    @MainActor open var tableViewStyle: UITableView.Style {
        .plain
    }
    
    open override func makeView() -> V {
        V(frame: UIScreen.main.bounds, style: tableViewStyle)
    }
}

public typealias UITablePageDefaultViewController = UITablePageViewController<UITableViewRootPresenter<UITableView>, UITableView>

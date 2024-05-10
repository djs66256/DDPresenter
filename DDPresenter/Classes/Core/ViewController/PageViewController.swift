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

/// Base view controller for presenter tree.
/// - `FrameView`: The `controller.view` type, `UIView` by default.
/// - `Presenter`: The root presenter. You can use `RootViewPresenter` directly.
/// - `View`: The root presenter view type. Usually is the same as FrameView.
///           You can use custom view when using custom root presenter
open class PageViewController<FrameView: UIView, Presenter, View>: UIViewController,  ServiceRegistrar, Notifier
where Presenter: RootViewPresenter<View> {
    
    private var _presenter: Presenter!
    
    /// Root presenter
    @MainActor public var presenter: Presenter {
        get {
            loadPresenterIfNeeded()
            return _presenter
        }
    }
    
    /// Root presenter view, may eqaul to `self.view`
    @MainActor public var presenterView: View? {
        loadViewIfNeeded()
        return presenter.view
    }
    
    /// The same as `self.view`, but return FrameView type.
    @MainActor public var frameView: FrameView {
        loadViewIfNeeded()
        return view as! FrameView
    }
    
    /// Create root presenter. You can override if custom presenter has different constructor.
    /// - Returns: Root presenter
    @MainActor open func makePresenter() -> Presenter {
        Presenter.init()
    }
    
    /// Create view.
    /// - Returns: View
    @MainActor open func makeView() -> FrameView {
        FrameView(frame: UIScreen.main.bounds)
    }
    
    @MainActor open func bindView(_ view: FrameView) {
        if !presenter.tryBindWeakView(view) {
            assert(false, "\(view.debugDescription) does not conform to presenter view type (\(View.self))")
        }
    }
    
    @MainActor public var isPresentLoaded: Bool = false
    @MainActor public func loadPresenterIfNeeded() {
        if !isPresentLoaded {
            isPresentLoaded = true
            _presenter = makePresenter()
            presenterDidLoad()
            _presenter.attach()
        }
    }
    
    @MainActor public func unloadPresenterIfNeeded() {
        if isPresentLoaded {
            _presenter.detachAllPresentersRecursive()
            _presenter.detach()
            isPresentLoaded = false
            _presenter = nil
        }
    }
    
    /// When presenter loaded. Before `viewDidLoad()`. You should register services here.
    @MainActor open func presenterDidLoad() {
        
    }
    
    open override func loadView() {
        view = makeView()
        bindView(view as! FrameView)
    }
    
    // MARK: - PageViewControllerLifecycle
    
    /// Notify lifecycle global or manully. When time comsuming, register listener manually is a better way to optimise.
    open var notifyLifecycleManually: Bool = false
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notify(listener: PageViewControllerLifecycle.self,
               scope: notifyLifecycleManually ? .manually : .global,
               from: self) {
            $0.viewWillAppear(animated)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notify(listener: PageViewControllerLifecycle.self,
               scope: notifyLifecycleManually ? .manually : .global,
               from: self)  {
            $0.viewDidAppear(animated)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notify(listener: PageViewControllerLifecycle.self,
               scope: notifyLifecycleManually ? .manually : .global,
               from: self)  {
            $0.viewWillDisappear(animated)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        notify(listener: PageViewControllerLifecycle.self,
               scope: notifyLifecycleManually ? .manually : .global,
               from: self)  {
            $0.viewDidDisappear(animated)
        }
    }
    
    deinit {
        if let presenter = _presenter {
            // We should detach all presenters when destroyed.
            performOnMainActorSync {
                presenter.detach()
            }
        }
    }

    // MARK: - messages & services
    
    public func getService<T>(_ type: T.Type) -> T? {
        presenter.getService(type)
    }
    
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T?) {
        presenter.register(service: service, lazy: lazy, builder)
    }

    public func unregister<T>(service: T.Type) {
        presenter.unregister(service: service)
    }

    @MainActor public func add<T>(listener: T.Type) {
        presenter.add(listener: listener, object: self)
    }

    @MainActor public func remove<T>(listener: T.Type) {
        presenter.remove(listener: listener, object: self)
    }

    @MainActor public func removeAllListeners() {
        presenter.removeAllListeners(of: self)
    }

    @MainActor public func notify<T>(listener: T.Type, scope: NotifyScope, from notifier: AnyObject?, _ closure: (T) -> Void) {
        presenter.notify(listener: listener, scope: scope, from: notifier, closure)
    }
}



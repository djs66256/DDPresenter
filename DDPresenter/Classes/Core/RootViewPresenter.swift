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

public protocol RootViewPresentable: Presenter, NotifyRegistrar { }

/// The root node of presenter tree.
open class RootViewPresenter<View>: GroupedViewPresenter<View>, RootViewPresentable, ServiceRegistrar {

    required public override init() {
        super.init()
    }
    
    @MainActor private var _viewUpdatePipeline: ViewUpdatePipeline?
    
    public private(set) lazy var serviceManager: ServiceRegistrar = ServiceManager(provider: self)
    
    public let notifyManager = NotifyManager()
    
    public override var viewUpdatePipeline: ViewUpdatePipeline? { _viewUpdatePipeline }
    
    open override func bindView(_ view: View) {
        _viewUpdatePipeline = ViewUpdatePipelineBuilder.buildDefaultPipeline(presenter: self, view: view as? UIView)
        
        super.bindView(view)
    }
    
    public override func bindWeakView(_ view: View) {
        _viewUpdatePipeline = ViewUpdatePipelineBuilder.buildDefaultPipeline(presenter: self, view: view as? UIView)
        
        super.bindWeakView(view)
    }
    
    public override func unbindView() {
        super.unbindView()
        
        _viewUpdatePipeline?.destroy()
        _viewUpdatePipeline = nil
    }
    
    /// Root presenter's root presenter is self.
    public final override var rootPresenter: RootViewPresentable? { self }
    
    /// Root presenter does not has any super presenter.
    public final override var superPresenter: Presenter? {
        set {  }
        get { nil }
    }
    
    /// Root presenter should update all presenters in the tree.
    public override func updateViewIfNeeded() {
        _viewUpdatePipeline?.updateViewIfNeeded(synchronize: true)
    }
    
    /// Root presenter do not has super presenters.
    /// Use this method instead of `func onAttachTo(_ presenter: Presenter)`
    @MainActor open func onAttach() {
        
    }
    
    /// Root presenter do not has super presenters.
    /// Use this method instead of `func onDetachFrom(_ presenter: Presenter)`
    @MainActor open func onDetach() {
        
    }
    
    @MainActor var _hasAttached: Bool = false
    
    /// Has attach to view controller.
    public override var hasAttached: Bool {
        _hasAttached
    }
    
    /// Attach to view controller.
    @MainActor public func attach() {
        _hasAttached = true
        onAttach()
    }
    
    /// Detach from view controller.
    @MainActor public func detach() {
        onDetach()
        _hasAttached = false
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    public override func onAttachTo(_ presenter: Presenter) {
        fatalError()
    }
    @available(*, unavailable)
    public override func onDetachFrom(_ presenter: Presenter) {
        fatalError()
    }
    
    @available(*, unavailable)
    override func attachSuperPresenter(_ superPresenter: Presenter) {
        fatalError()
    }
    
    @available(*, unavailable)
    public override func detachSuperPresenter() {
        fatalError()
    }
    
    // MARK: - Notifier & Service
    public override func notify<T>(listener: T.Type, scope: NotifyScope, from: AnyObject?, _ closure: (T) -> Void) {
        switch scope {
        case .global: fallthrough
        case .reusable: fallthrough
        case .children: fallthrough
        case .childrenAndSelf:
            notifyManager.notify(listener: listener, from: from, closure)
            super.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        case .parents:
            notifyManager.notify(listener: listener, from: from, closure)
            super.notify(listener: listener, scope: .parents, from: from, closure)
        case .manually:
            notifyManager.notify(listener: listener, from: from, closure)
        }
    }
    
    /// Add lisenter manually. At sometime, you can add listener yourself to optimize.
    /// - Parameters:
    ///   - listener: The message to be send
    ///   - object: The object listens to the message.
    @MainActor public func add<T>(listener: T.Type, object: AnyObject) {
        notifyManager.add(listener: listener, object: object)
    }
    
    /// Remove lisenter manually.
    /// - Parameters:
    ///   - listener: The message to be send
    ///   - object: The object listens to the message.
    @MainActor public func remove<T>(listener: T.Type, object: AnyObject) {
        notifyManager.remove(listener: listener, object: object)
    }
    
    @MainActor public func removeAllListeners(of object: AnyObject) {
        notifyManager.removeAllListeners(of: object)
    }
    
    /// Register the service.
    /// - Parameters:
    ///   - service: Service type
    ///   - lazy: If true, service will be builded at first time getting this service.
    ///   - builder: The builder to create the implementary of the service.
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T?) {
        serviceManager.register(service: service, lazy: lazy, builder)
    }
    
    /// Unregister the service.
    /// - Parameter service: Service type
    public func unregister<T>(service: T.Type) {
        serviceManager.unregister(service: service)
    }
    
    public override func getService<T>(_ type: T.Type) -> T? {
        if let s = serviceManager.getService(type) {
            return s
        }
        return nil
    }
}

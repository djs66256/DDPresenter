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

/// Presenter is a state container to driven view updating.
/// You should put all states here, not only in the view.
open class Presenter: Notifier, ServiceProvider, Hashable {
    @MainActor(unsafe) public init() {}
    
    // MARK: - Presenter tree
    @MainActor private var _children = [Presenter]()
    @MainActor public var children: [Presenter] { _children }
    
    @MainActor public var hasAttached: Bool { superPresenter != nil }
    @MainActor public private(set) weak var superPresenter: Presenter?
    
    @MainActor public var hasAttachedRoot: Bool { rootPresenter != nil }
    @MainActor public private(set) weak var rootPresenter: RootViewPresentable? = nil
    
    /// Attached to a super presenter
    /// - Parameter presenter: super presenter
    @MainActor open func onAttachTo(_ presenter: Presenter) { }
    
    /// Will detach from super presenter
    /// - Parameter presenter: super presenter
    @MainActor open func onDetachFrom(_ presenter: Presenter) { }
    
    /// Attached to root presenter. You should only call `getService` and `notify` after this point.
    /// - Parameter presenter: root presenter
    @MainActor open func onAttachToRoot(_ presenter: RootViewPresentable) { }
    
    /// Will detach from root presenter. You should never call `getService` and `notify` after this point
    /// - Parameter presenter: root presenter
    @MainActor open func onDetachFromRoot(_ presenter: RootViewPresentable) { }
    
    /// Add a child presenter to this presenter.
    /// - Parameter child: child presenter to be added
    @MainActor public func add(child: Presenter) {
        if let sp = child.superPresenter {
            if sp === self {
                // If already contains child, just move it to the last position
                _children.removeAll(where: { $0 == child })
                _children.append(child)
            }
            else {
                // If child is under other presenter, remove from parent then add to children.
                child.removeFromSuper()
                _children.append(child)
                child.attachSuperPresenter(self)
            }
        }
        else {
            _children.append(child)
            child.attachSuperPresenter(self)
        }
    }
    
    /// Remove a child presenter.
    /// - Parameter child: child presenter to be removed
    @MainActor public func remove(child: Presenter) {
        // Only remove child in this presenter.
        if let sp = child.superPresenter, sp === self {
            child.detachSuperPresenter()
            _children.removeAll(where: { $0 == child })
        }
    }
    
    /// Remove all children presenters
    @MainActor public func removeAllChildrenPresenter() {
        for child in _children {
            child.detachSuperPresenter()
        }
        _children.removeAll()
    }
    
    /// Remove from super presenter if added to a super persenter.
    @MainActor public func removeFromSuper() {
        if let presenter = superPresenter {
            presenter.remove(child: self)
        }
    }
    
    /// Detach all
    @MainActor func detachAllPresentersRecursive() {
        for child in _children {
            child.detachAllPresentersRecursive()
        }
        _children.removeAll()
        
        detachSuperPresenter()
    }
    
    @MainActor func attachSuperPresenter(_ superPresenter: Presenter) {
        if hasAttached {
            detachSuperPresenter()
        }
        
        self.superPresenter = superPresenter
        onAttachTo(superPresenter)
        
        // If super presenter has attached root presenter, self should attach to root automatically.
        if let rootPresenter = superPresenter.rootPresenter {
            attachRootPresenter(rootPresenter)
        }
        
        // Try auto bind view if needed.
        if superPresenter.hasBoundView, superPresenter.autoBindChildrenPresenterViews {
            tryAutoBindView()
        }
    }
    
    @MainActor func detachSuperPresenter() {
        if hasBoundView {
            unbindView()
        }
        
        if let superPresenter {
            onDetachFrom(superPresenter)
        }
        
        detachRootPresenter()
        
        superPresenter = nil
    }
    
    @MainActor func attachRootPresenter(_ rootPresenter: RootViewPresentable) {
        self.rootPresenter = rootPresenter
        onAttachToRoot(rootPresenter)
        for child in _children {
            child.attachRootPresenter(rootPresenter)
        }
    }
    
    @MainActor func detachRootPresenter() {
        if let rootPresenter {
            for child in _children {
                child.detachRootPresenter()
            }
            onDetachFromRoot(rootPresenter)
            self.rootPresenter = nil
        }
    }
    
    // MARK: - View tree
    
    /// The pipeline to update the view. Any state changes will notify pipeline to mark self dirty,
    /// and pipeline will flush dirty presenters and update its view.
    @MainActor var viewUpdatePipeline: ViewUpdatePipeline? {
        (superPresenter)?.viewUpdatePipeline
    }
    
    /// Update view state with context.
    /// - Parameter context: The context in this update transaction. Context will merge when several state changes.
    @MainActor func updateView(context: ViewUpdateContext) {
        fatalError("override")
    }
    
    /// Update view layout with context.
    /// - Parameter context: The context in this update transaction. Context will merge when several state changes.
    @MainActor func updateLayout(context: ViewUpdateContext) {
        fatalError("override")
    }
    
    @MainActor public var hasBoundView: Bool { fatalError("override") }
    
    /// View thats bound to this presenter. View can be any type, even Void.
    @MainActor public var anyView: Any? { fatalError("override") }
    
    /// After `setState`, update pipeline will call `updateViewIfNeeded` at sometime later.
    /// You should never override yourself.
    /// Notice: update view of this presenter when not root presenter, otherwise updating all view-tree.
    @MainActor public func updateViewIfNeeded() { fatalError("override") }
    
    /// State changed, notify pipeline to update view at sometime future.
    /// You can update immediately by calling `updateViewIfNeeded()`.
    /// - Parameters:
    ///   - updater: The updater to update state of this presenter.
    ///   - context: The context of this update action.
    ///   - completion: Called when updating view completed, but not animation completed. Use animator to know when animation completed.
    @MainActor public func setState(updater: ()->Void,
                                    context: ((inout ViewUpdateContext)->Void)? = nil,
                                    completion: (() -> Void)? = nil) {}
    
    /// Try to bind a view, if binding failed, it will do nothing.
    /// It will call `onBindView(_:)` if bind view successly.
    /// - Returns: Bind result, false means can not bind this view.
    @MainActor public func tryBindView(_ view: Any) -> Bool { fatalError("override") }
    
    /// The same as `tryBindView(_ view: Any) -> Bool`, but will store view by weak reference.
    /// - Returns: Bind result
    @MainActor public func tryBindWeakView(_ view: AnyObject) -> Bool { fatalError("override") }
    
    /// Auto bind view if true.
    @MainActor public var autoBindView: Bool = true
    @MainActor public var autoBindChildrenPresenterViews: Bool = true
    
    /// Try to bind view by auto matching the view type. Using BFS search the children views.
    /// It maybe bind error view when has same type views.
    /// You can set `autoBindView` to false to disable it, and `autoBindChildrenPresenterViews` to disable children presenters.
    @MainActor public func tryAutoBindView() { fatalError("override") }
    
    /// Unbind view, do nothing if not bind any view.
    /// It will call `onUnbindView()` if success unbind view.
    @MainActor public func unbindView() { fatalError("override") }
    
    // MARK: - Layouts
    
    @MainActor public func invalidateConstraints() {
        setState(updater: {}) { context in
            context.invalidateConstraints = true
        }
    }
    
    @MainActor public func invalidateLayout() {
        setState(updater: {}) { context in
            context.invalidateLayout = true
        }
    }
    
    @MainActor public func invalidateContentSize() {
        setState(updater: {}) { context in
            context.invalidateContentSize = true
        }
    }
    
    @MainActor public func updateConstraintsIfNeeded() {
        setState(updater: {}) { context in
            context.updateConstraintsIfNeeded = true
        }
        updateViewIfNeeded()
    }
    
    @MainActor public func layoutIfNeeded() {
        setState(updater: {}) { context in
            context.layoutIfNeeded = true
        }
        updateViewIfNeeded()
    }
    
    // MARK: - Notify & Service
    
    /// Make a notification to the presenters that can response to the message.
    /// Here we use protocol to send messages. Who implement the protocol means it should responds to the message.
    /// You should only notify after root presenter has attached.
    /// - Parameters:
    ///   - listener: The message to be send
    ///   - scope: Notify scope. At most time, we should not need to notify global.
    ///   - from: The object who send the message. This object should response the message send by itself.
    ///   - closure: Closure that can invoke the message.
    @MainActor open func notify<T>(listener: T.Type, scope: NotifyScope, from: AnyObject?, _ closure: (T) -> Void) {
        switch scope {
        case .global:
            rootPresenter?.notify(listener: listener, scope: scope, from: from, closure)
        case .reusable:
            // Let super presenter to determine which one is reusable presenter
            superPresenter?.notify(listener: listener, scope: scope, from: from, closure)
        case .children:
            _notifyChildren(listener: listener, from: from, closure)
        case .childrenAndSelf:
            _notifyChildrenAndSelf(listener: listener, from: from, closure)
        case .parents:
            _notifyParents(listener: listener, from: from, closure)
        case .manually:
            rootPresenter?.notify(listener: listener, scope: scope, from: from, closure)
        }
    }
    
    @MainActor private func _notifyChildren<T>(listener: T.Type, from: AnyObject?, _ closure: (T) -> Void) {
        for child in children {
            child.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        }
    }
    
    @MainActor private func _notifyChildrenAndSelf<T>(listener: T.Type, from: AnyObject?, _ closure:(T)->Void) {
        if let obj = self as? T, self !== from {
            closure(obj)
        }
        for child in children {
            child.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        }
    }
    
    @MainActor private func _notifyParents<T>(listener: T.Type, from: AnyObject?, _ closure: (T) -> Void) {
        if let responder = self as? T, self !== from {
            closure(responder)
        }
        superPresenter?.notify(listener: listener, scope: .parents, from: from, closure)
    }
    
    /// All logic should be placed in services, and used by protocol.
    /// It's an implement of IOC (Inversion of Control and Dependency Injection).
    /// And the scope is inside the presenter tree.
    /// At most time, you should use Service instead of calling implementary directly.
    /// You should only get service after root presenter has attached.
    /// - Parameter type: The protocol type of service.
    /// - Returns: nil if not registered, or before attached to root presenter
    @MainActor open func getService<T>(_ type: T.Type) -> T? {
        superPresenter?.getService(type)
    }
    
    // MARK: - Extension objects
    // private lazy var extensionObjects: [ObjectIdentifier: Any] = [:]
    // public func extensionObject<T: PresenterExtensionKey>(for key: T) -> T.ValueType {
    //     let key = ObjectIdentifier(T.self)
    //     if let value = extensionObjects[key] as? T.ValueType {
    //         return value
    //     }
    //     else {
    //         let value = T.create(by: self)
    //         extensionObjects[key] = value
    //         return value
    //     }
    // }
    //
    // public func extensionObject<T: PresenterExtensionKey>(for key: T, createIfNeeded: Bool) -> T.ValueType? {
    //     if createIfNeeded {
    //         return extensionObject(for: key)
    //     }
    //     else {
    //         return extensionObjects[ObjectIdentifier(T.self)] as? T.ValueType
    //     }
    // }
    
    public var hashValue: Int {
        ObjectIdentifier(self).hashValue
    }
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

public func == (lhs: Presenter, rhs: Presenter) -> Bool {
    lhs === rhs
}

public func != (lhs: Presenter, rhs: Presenter) -> Bool {
    lhs !== rhs
}

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

/// Presenter with view type
open class ViewPresenter<View>: Presenter {
    @MainActor private var _view: (()->View?)?
    @MainActor public var view: View? { _view?() }
    @MainActor public override var anyView: Any? {
        view
    }
    
    /// Binded a new view
    /// - Parameter view: view to bind
    @MainActor open func onBindView(_ view: View) { }
    
    /// Will unbind view
    @MainActor open func onUnbindView() { }
    
    /// All view updaters in this method, it will called because state changed by `setState`
    /// - Parameters:
    ///   - view: binded view
    ///   - context: this update action context, you should rarely need this
    @MainActor open func onUpdate(view: View, context: ViewUpdateContext) { }
    
    /// After `setState`, update pipeline will call `updateViewIfNeeded` at sometime.
    /// Then should update all view changes, and call `onUpdate(view:)`.
    /// You should never override this yourself.
    @MainActor public override func updateViewIfNeeded() {
        viewUpdatePipeline?.updateViewPresenterIfNeeded(self)
    }
    
    /// State changed, will perform update view at sometime future.
    /// - Parameters:
    ///   - updater: The updater to update state of this presenter.
    ///   - context: The context of this update action.
    ///   - completion: Called when update completion, after animation completion if animated.
    @MainActor public override func setState(updater: () -> Void,
                                             context: ((inout ViewUpdateContext) -> Void)? = nil,
                                             completion: (() -> Void)? = nil) {
        var ctx = ViewUpdateContext()
        context?(&ctx)
        
        needsUpdate = true
        needsUpdateLayout = true
        StateContext.beginUpdate()
        updater()
        StateContext.endUpdate()
        // Bind view do not need mark dirty, update immediately.
        viewUpdatePipeline?.markDirty(presenter: self, context: ctx, completion)
    }
    
    // MARK: - View
    
    /// Whether is any view binded.
    @MainActor public override var hasBoundView: Bool {
        _view != nil
    }
    
    /// Try to bind a view, if view is not the right type, it will do nothing.
    /// It will call `onBindView(_:)` if success bind view.
    /// - Returns: Bind result, false means can not bind this view.
    @MainActor public override func tryBindView(_ view: Any) -> Bool {
        if let view = view as? View {
            bindView(view)
            return true
        }
        return false
    }
    
    /// The same as `tryBindView(_ view: Any) -> Bool`, but will store view by weak reference.
    /// - Returns: Bind result
    @MainActor public override func tryBindWeakView(_ view: AnyObject) -> Bool {
        if let view = view as? View {
            bindWeakView(view)
            return true
        }
        return false
    }
    
    @MainActor public override func tryAutoBindView() {
        guard let superPresenter, autoBindView, view == nil else {
            return
        }
        
        if View.self == Void.self {
            bindView(() as! View)
        }
        else if let view: View = ViewAutoBinder().findChildView(presenter: superPresenter) {
            bindView(view)
        }
    }
    
    /// Bind a view.
    /// - Parameter view: view to bind
    @MainActor public func bindView(_ view: View) {
        if hasBoundView {
            unbindView()
        }
        _view = { view }
        onBindView(view)
        // Auto bind child presenter and view
        if autoBindChildrenPresenterViews {
            for child in children {
                child.tryAutoBindView()
            }
        }
        // update view when first binded
        setState { } context: { $0.bindView() }
    }
    
    /// Bind a weak view.
    /// - Parameter view: view to bind
    @MainActor public func bindWeakView(_ view: View) {
        let obj = view as AnyObject
        if hasBoundView {
            unbindView()
        }
        _view = { [weak obj] in obj as? View }
        onBindView(view)
        // Auto bind child presenter and view
        if autoBindChildrenPresenterViews {
            for child in children {
                child.tryAutoBindView()
            }
        }
        // update view when first binded
        setState { } context: { $0.bindView() }
    }
    
    /// Unbind view, do nothing if not bind any view.
    /// It will call `onUnbindView()` if success unbind view.
    @MainActor public override func unbindView() {
        if hasBoundView {
            onUnbindView()
            for child in children {
                child.unbindView()
            }
            _view = nil
        }
    }
    
    @MainActor private var needsUpdate = true
    override func updateView(context: ViewUpdateContext) {
        if needsUpdate {
            doUpdate(context: context)
            needsUpdate = false
        }
    }
    
    @MainActor func doUpdate(context: ViewUpdateContext) {
        if let view = view {
            onUpdate(view: view, context: context)
        }
    }
    
    @MainActor private var needsUpdateLayout = true
    override func updateLayout(context: ViewUpdateContext) {
        if needsUpdateLayout {
            doUpdateLayout(context: context)
            needsUpdateLayout = false
        }
    }
    
    @MainActor func doUpdateLayout(context: ViewUpdateContext) {
        if let v = view as? UIView {
            if context.invalidateConstraints {
                v.setNeedsUpdateConstraints()
            }
            if context.invalidateLayout {
                v.setNeedsLayout()
            }
            if context.updateConstraintsIfNeeded {
                v.updateConstraintsIfNeeded()
            }
            if context.layoutIfNeeded {
                v.layoutIfNeeded()
            }
        }
    }
}

@MainActor
fileprivate struct StateContext {
    private static var setStateCount: Int = 0
    static var isUpdating: Bool {
        setStateCount != 0
    }
    static func beginUpdate() {
        setStateCount += 1
    }
    static func endUpdate() {
        setStateCount -= 1
    }
}

/// A checker to make sure state value MUST be updated inside of setState{}
@propertyWrapper
@MainActor public struct StateChecker<T> {
    public var wrappedValue: T {
        willSet {
            assert(StateContext.isUpdating, "MUST update state value inside of setState{} !")
        }
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

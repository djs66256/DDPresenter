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

public protocol ReusableViewPresenterHoldable: Presenter {
    @MainActor func tryBindReusablePresenter(_ presenter: Presenter) -> Bool
    @MainActor func tryUnbindReusablePresenter(_ presenter: Presenter) -> Bool
}

/// Reusable presenter can not add to presenter tree directly. Because we do not know when reusable view will created,
/// and how many reusable views will be created. So we use a holder to hold reusable presenters.
/// It will not create reusable presenter until reusable view created, and unbind when view reused or destroyed.
open class ReusableViewPresenterHolder: ViewPresenter<Void>, ReusableViewPresenterHoldable {
    
    public override init() {
        super.init()
        autoBindView = false
    }
    
    /// Reusable presenters maybe more than one. When UICollectionViewCell animating,
    /// it will create another cell applying animations.
    @MainActor public private(set) var reusedPresenters: [Presenter] = []
    
    @MainActor func tryOnBindReusablePresenter(_ presenter: Presenter) {
        fatalError("MUST override")
    }
    
    @MainActor func tryOnUnbindReusablePresenter(_ presenter: Presenter) {
        fatalError("MUST override")
    }
    
    @MainActor func tryOnUpdate(presenter: Presenter, context: ViewUpdateContext) {
        fatalError("MUST override")
    }
    
    open override func onUnbindView() {
        super.onUnbindView()
        
        // When unbind view, unbind all reused presenters.
        unbindAllReusablePresenters()
    }
    
    @MainActor public func tryBindReusablePresenter(_ presenter: Presenter) -> Bool {
        if reusedPresenters.contains(where: { $0 == presenter }) {
            assert(false, "Cannot bind reusable presenter tiwce.")
            return false
        }
        bindReusablePresenter(presenter)
        return true
    }
    
    @MainActor public func bindReusablePresenter(_ presenter: Presenter) {
        presenter.removeFromSuper()
        add(child: presenter)
        reusedPresenters.append(presenter)
        
        tryOnBindReusablePresenter(presenter)
        
        // When bind presenter, update presenter immedately, donot need setState().
        var context = ViewUpdateContext()
        context.bindView()
        tryOnUpdate(presenter: presenter, context: context)
    }
    
    @MainActor public func tryUnbindReusablePresenter(_ presenter: Presenter) -> Bool {
        if reusedPresenters.contains(where: { $0 == presenter }) {
            unbindReusablePresenter(presenter)
            return true
        }
        return false
    }
    
    @MainActor public func unbindReusablePresenter(_ presenter: Presenter) {
        tryOnUnbindReusablePresenter(presenter)
        remove(child: presenter)
        reusedPresenters.removeAll(where: { $0 == presenter })
    }
    
    @MainActor public func unbindAllReusablePresenters() {
        for reusedPresenter in reusedPresenters {
            tryOnUnbindReusablePresenter(reusedPresenter)
            remove(child: reusedPresenter)
        }
        reusedPresenters.removeAll()
    }
    
    public override func setState(updater: () -> Void,
                                  context: ((inout ViewUpdateContext) -> Void)? = nil,
                                  completion: (() -> Void)? = nil) {
        needsUpdatePresenter = true
        super.setState(updater: updater, context: context, completion: completion)
    }
    
    @MainActor private var needsUpdatePresenter: Bool = false
    public override func updateView(context: ViewUpdateContext) {
        updateReusablePresenter(context: context)
        super.updateView(context: context)
    }
    
    @MainActor public func setNeedsUpdateReusablePresenter() {
        setState(updater: {})
    }
    
    @MainActor func updateReusablePresenter(context: ViewUpdateContext) {
        if needsUpdatePresenter {
            doUpdatePresenter(context: context)
            needsUpdatePresenter = false
        }
    }
    
    @MainActor private func doUpdatePresenter(context: ViewUpdateContext) {
        for presenter in reusedPresenters {
            tryOnUpdate(presenter: presenter, context: context)
        }
    }
    
    public override func notify<T>(listener: T.Type, scope: NotifyScope, from: AnyObject?, _ closure: (T) -> Void) {
        if scope == .reusable {
            // Notify scope in reuseable presenter, just notify bound presenter of it.
            self.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        }
        else {
            super.notify(listener: listener, scope: scope, from: from, closure)
        }
    }
}

public protocol ReusablePresentable: Presenter {
    @MainActor(unsafe) init()
    @MainActor func prepareForReuse()
}

open class ReusableViewPresenter<View>: ViewPresenter<View>, ReusablePresentable {
    required public override init() {
        super.init()
        autoBindView = false
    }
    
    @MainActor open func prepareForReuse() {
        
    }
}

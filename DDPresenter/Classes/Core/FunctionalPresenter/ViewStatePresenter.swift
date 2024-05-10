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

public protocol ViewState: Equatable {
    init()
}

public protocol ViewStatePresentable: Presenter {
    associatedtype StateType
    @MainActor var state: StateType { get }
    @MainActor func setState(updater: (inout StateType) -> Void,
                             context: ((inout ViewUpdateContext) -> Void)?,
                             completion: (() -> Void)?)
}

/// Presenter driven by ViewState. ViewState should be struct type.
open class ViewStatePresenter<View, StateType: ViewState>: ViewPresenter<View>, ViewStatePresentable {
    
    @StateChecker
    private var _state: StateType
    
    @MainActor(unsafe) public init(state: StateType) {
        _state = state
        super.init()
    }
    
    public override init() {
        _state = StateType()
        super.init()
    }
    
    @MainActor public var state: StateType {
        _state
    }
    
    @MainActor public func setState(updater: (inout StateType) -> Void,
                                    context: ((inout ViewUpdateContext) -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var copy = _state
        updater(&copy)
        if copy != _state {
            setState(updater: {
                _state = copy
            }, context: context, completion: completion)
        }
    }
}


open class RootViewStatePresenter<View, StateType: ViewState>: RootViewPresenter<View>, ViewStatePresentable {
    
    @StateChecker
    private var _state: StateType = StateType()
    
    required public init() {
        super.init()
    }
    
    public init(state: StateType) {
        _state = state
    }
    
    @MainActor public var state: StateType {
        _state
    }
    
    @MainActor public func setState(updater: (inout StateType) -> Void,
                                    context: ((inout ViewUpdateContext) -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var copy = _state
        updater(&copy)
        if copy != _state {
            setState(updater: {
                _state = copy
            }, context: context, completion: completion)
        }
    }
}

// MARK: - UICollectionView

open class UICollectionViewFlowReusableItemStatePresenter<View: UICollectionReusableView, StateType: ViewState>:
    UICollectionViewFlowReusableItemPresenter<View>, ViewStatePresentable {
    
    @StateChecker
    private var _state: StateType = StateType()
    
    required public init() {
        super.init()
    }
    
    public init(state: StateType) {
        _state = state
        super.init()
    }
    
    @MainActor public var state: StateType {
        _state
    }
    
    @MainActor public func setState(updater: (inout StateType) -> Void,
                                    context: ((inout ViewUpdateContext) -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var copy = _state
        updater(&copy)
        if copy != _state {
            setState(updater: {
                _state = copy
            }, context: context, completion: completion)
        }
    }
}

open class UICollectionViewFlowItemSelfHolderStatePresenter<View: UICollectionReusableView, StateType: ViewState>:
    UICollectionViewFlowItemSelfHolderPresenter<View>, ViewStatePresentable {
    
    @StateChecker
    private var _state: StateType = StateType()
    
    required public init() {
        super.init()
    }
    
    public init(state: StateType) {
        _state = state
        super.init()
    }
    
    @MainActor public var state: StateType {
        _state
    }
    
    @MainActor public func setState(updater: (inout StateType) -> Void,
                                    context: ((inout ViewUpdateContext) -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var copy = _state
        updater(&copy)
        if copy != _state {
            setState(updater: {
                _state = copy
            }, context: context, completion: completion)
        }
    }
}

// MARK: - UITableView

open class UITableViewReusableCellStatePresenter<View: UITableViewCell, StateType: ViewState>:
    UITableViewReusableCellPresenter<View>, ViewStatePresentable {
    
    @StateChecker
    private var _state: StateType = StateType()
    
    required public init() {
        super.init()
    }
    
    public init(state: StateType) {
        _state = state
        super.init()
    }
    
    @MainActor public var state: StateType {
        _state
    }
    
    @MainActor public func setState(updater: (inout StateType) -> Void,
                                    context: ((inout ViewUpdateContext) -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var copy = _state
        updater(&copy)
        if copy != _state {
            setState(updater: {
                _state = copy
            }, context: context, completion: completion)
        }
    }
}


open class UITableViewHeaderFooterStatePresenter<V: UITableViewHeaderFooterView, StateType: ViewState>:
    UITableViewHeaderFooterPresenter<V>, ViewStatePresentable {
    
    @StateChecker
    private var _state: StateType = StateType()
    
    required public init() {
        super.init()
    }
    
    public init(state: StateType) {
        _state = state
        super.init()
    }
    
    @MainActor public var state: StateType {
        _state
    }
    
    @MainActor public func setState(updater: (inout StateType) -> Void,
                                    context: ((inout ViewUpdateContext) -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var copy = _state
        updater(&copy)
        if copy != _state {
            setState(updater: {
                _state = copy
            }, context: context, completion: completion)
        }
    }
}

open class UITableViewCellSelfHolderStatePresenter<View: UITableViewCell, StateType: ViewState>:
    UITableViewCellSelfHolderPresenter<View>, ViewStatePresentable {
    
    @StateChecker
    private var _state: StateType = StateType()
    
    required public init() {
        super.init()
    }
    
    public init(state: StateType) {
        _state = state
        super.init()
    }
    
    @MainActor public var state: StateType {
        _state
    }
    
    @MainActor public func setState(updater: (inout StateType) -> Void,
                                    context: ((inout ViewUpdateContext) -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var copy = _state
        updater(&copy)
        if copy != _state {
            setState(updater: {
                _state = copy
            }, context: context, completion: completion)
        }
    }
}

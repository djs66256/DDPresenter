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

/// The context of transaction. It decides how view will be updated.
public struct ViewUpdateContext {
    
    /// Used when caculating size. You should prevent doing any time consuming callings.
    public var isDryRun: Bool = false
    
    /// Used when binding view. It will update view directly.
    public var isBindingView: Bool = false
    
    /// If true, will call `invalidateConstraints()` after updating view.
    public var invalidateConstraints: Bool = false
    
    /// If true, will call `invalidateLayout()` after updating view.
    public var invalidateLayout: Bool = false
    
    public var updateConstraintsIfNeeded: Bool = false
    
    /// If true, will call `layoutIfNeeded()` after updating view.
    public var layoutIfNeeded: Bool = false
    
    /// If true, will update view within an animation block.
    /// It will use animator in this context to perform animations.
    /// And `UIView.animate(..., { updateView() })` by default.
    public var animated: Bool = false
    
    /// If true, will force disable animations by `UIView.performWithoutAnimation()`
    /// When in UICollectionView/UITableView, it will disable insert/delete/replace animations.
    public var forceDisableAnimation: Bool = false
    
    // MARK: - For reusable view, UITableView, UICollectionView etc.
    
    /// DataSource is changed, should reload or batchUpdates UICollectionView or UITableView.
    public var invalidateDataSource: Bool = false
    
    /// ContentSize is changed, should update the UICollectionViewLayout, without reload all dataSource.
    /// Also it will clear size cache, and calculate new size when updating.
    public var invalidateContentSize: Bool = false
    
    /// Extra infos, can set any info you need to by pass to transactions.
    public var infos: [AnyHashable: Any] = [:]
    
    public subscript<KeyType>(_ key: KeyType.Type) -> KeyType.ValueType
    where KeyType : ViewUpdateContextInfoKey {
        get { infos[ObjectIdentifier(key)] as? KeyType.ValueType ?? KeyType.defaultValue}
        set { infos[ObjectIdentifier(key)] = newValue }
    }
    
    public init() {}
    
    public mutating func merge(_ context: ViewUpdateContext) {
        isDryRun = isDryRun || context.isDryRun
        isBindingView = isBindingView || context.isBindingView
        invalidateConstraints = invalidateConstraints || context.invalidateConstraints
        invalidateLayout = invalidateLayout || context.invalidateLayout
        updateConstraintsIfNeeded = updateConstraintsIfNeeded || context.updateConstraintsIfNeeded
        layoutIfNeeded = layoutIfNeeded || context.layoutIfNeeded
        animated = animated || context.animated
        forceDisableAnimation = forceDisableAnimation || context.forceDisableAnimation
        invalidateDataSource = invalidateDataSource || context.invalidateDataSource
        invalidateContentSize = invalidateContentSize || context.invalidateContentSize
        infos.merge(context.infos, uniquingKeysWith: { return $1 })
    }
}

public protocol ViewUpdateContextInfoKey {
    associatedtype ValueType
    static var defaultValue: ValueType { get }
}

// MARK: - ViewUpdateContext Builder
extension ViewUpdateContext {
    
    static public var dryRun: ViewUpdateContext {
        var context = ViewUpdateContext()
        context.isDryRun = true
        return context
    }
    
    /// Used when binding view, should update view immediately this time.
    @inlinable public mutating func bindView() {
        self.isBindingView = true
    }
    
    /// Used when update sections or items, should reload data source at this time.
    @inlinable public mutating func reloadData() {
        self.invalidateDataSource = true
    }
}

// MARK: - Animation

/// Animator for presenter to update views
public protocol ViewUpdateAnimator {
    
    /// Perform animation.
    /// - Parameters:
    ///   - presenter: The presenter to perform animation.
    ///   - context: The context of this transaction.
    ///   - updater: The view updating closure, should invoke it in the animation function.
    @MainActor func animate(with presenter: Presenter, context: ViewUpdateContext, _ updater: @escaping () -> Void)
}

extension ViewUpdateContext {
    private struct AnimatorKey: ViewUpdateContextInfoKey {
        typealias ValueType = ViewUpdateAnimator?
        static var defaultValue: ViewUpdateAnimator? { nil }
    }
    
    @MainActor public var animator: ViewUpdateAnimator? {
        set { self[AnimatorKey.self] = newValue }
        get { self[AnimatorKey.self] }
    }
    
    @MainActor func animate(_ presenter: Presenter, updater: @escaping () -> Void) {
        if self.forceDisableAnimation {
            UIView.performWithoutAnimation(updater)
        }
        else if self.animated {
            if let animator = self.animator {
                animator.animate(with: presenter, context: self, updater)
            } 
            else {
                UIView.animate(withDuration: 0.3, animations: updater)
            }
        }
        else {
            updater()
        }
    }
}

/// Default UIView animation
public struct UIViewDefaultAnimator: ViewUpdateAnimator {
    public var duration: TimeInterval = 0.3
    public var delay: TimeInterval = 0
    public var options: UIView.AnimationOptions = []
    public var completion: ((Bool) -> Void)? = nil
    public init(duration: TimeInterval,
                delay: TimeInterval = 0,
                options: UIView.AnimationOptions = [],
                completion: ((Bool) -> Void)? = nil) {
        self.duration = duration
        self.delay = delay
        self.options = options
        self.completion = completion
    }
    public func animate(with presenter: Presenter, context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: updater, completion: completion)
    }
}

/// Spring animation
public struct UIViewSpringAnimator: ViewUpdateAnimator {
    public var duration: TimeInterval = 0.5
    public var bounce: CGFloat = 0.0
    public var initialSpringVelocity: CGFloat = 0.0
    public var delay: TimeInterval = 0.0
    public var options: UIView.AnimationOptions = []
    public var completion: ((Bool) -> Void)? = nil
    public init(duration: TimeInterval,
                bounce: CGFloat = 0,
                initialSpringVelocity: CGFloat = 0,
                delay: TimeInterval = 0,
                options: UIView.AnimationOptions = [],
                completion: ((Bool) -> Void)? = nil) {
        self.duration = duration
        self.bounce = bounce
        self.initialSpringVelocity = initialSpringVelocity
        self.delay = delay
        self.options = options
        self.completion = completion
    }
    public func animate(with presenter: Presenter, context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        if #available(iOS 17.0, *) {
            UIView.animate(springDuration: duration,
                           bounce: bounce,
                           initialSpringVelocity: initialSpringVelocity,
                           delay: delay,
                           options: options,
                           animations: updater,
                           completion: completion)
        } else {
            UIView.animate(withDuration: duration,
                           delay: delay,
                           usingSpringWithDamping: bounce,
                           initialSpringVelocity: initialSpringVelocity,
                           options: options,
                           animations: updater,
                           completion: completion)
        }
    }
}

extension ViewUpdateAnimator {
    public static func animate(
        withDuration duration: TimeInterval,
        delay: TimeInterval = 0,
        options: UIView.AnimationOptions = [],
        completion: ((Bool) -> Void)? = nil
    ) -> ViewUpdateAnimator {
        UIViewDefaultAnimator(duration: duration, delay: delay, options: options, completion: completion)
    }
    
    public static func animate(
        springDuration duration: TimeInterval = 0.5,
        bounce: CGFloat = 0.0,
        initialSpringVelocity: CGFloat = 0.0,
        delay: TimeInterval = 0.0,
        options: UIView.AnimationOptions = [],
        completion: ((Bool) -> Void)? = nil
    ) -> ViewUpdateAnimator {
        UIViewSpringAnimator(duration: duration, 
                             bounce: bounce,
                             initialSpringVelocity: initialSpringVelocity,
                             delay: delay,
                             options: options,
                             completion: completion)
    }
}

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

@MainActor
public final class ViewPresenterIdentifierStore {
    fileprivate var presenterBuilders: [AnyHashable: ()->Presenter] = [:]
    fileprivate var presenters: [AnyHashable: Presenter] = [:]
    public init() { }
}

public protocol ViewPresenterIdentify: AnyObject {
    @MainActor var presenterStore: ViewPresenterIdentifierStore { get }
}

public extension ViewPresenterIdentify where Self : Presenter {
    
    /// Register the presenter with a key by lazy.
    /// - Returns: The key of the presenter registered.
    @MainActor func setLazyViewPresenter<P, V>(_ key: AnyHashable, _ value: @escaping ()->P) where P: ViewPresenter<V> {
        presenterStore.presenterBuilders[key] = { value() }
    }
    
    /// Register the presenter with a key.
    /// - Returns: The key of the presenter registered.
    @MainActor func setViewPresenter(_ key: AnyHashable, _ value: Presenter) {
        presenterStore.presenters[key] = value
        add(child: value)
    }
    
    /// Get the presenter registered by the key.
    /// - Returns: The key of the presenter registed.
    @MainActor func getViewPresenter(_ key: AnyHashable) -> Presenter? {
        if let p = presenterStore.presenters[key] {
            return p
        }
        else {
            if let gen = presenterStore.presenterBuilders[key] {
                let p = gen()
                setViewPresenter(key, p)
                return p
            }
        }
        return nil
    }
    
    /// Get the presenter registered by the key.
    /// - Returns: The key of the presenter registered.
    @MainActor func getViewPresenter<P, V>(_ key: AnyHashable) -> P? where P: ViewPresenter<V> {
        if let p = presenterStore.presenters[key] {
            return p as? P
        }
        else {
            if let gen = presenterStore.presenterBuilders[key] {
                let p = gen()
                setViewPresenter(key, p)
                return p as? P
            }
        }
        return nil
    }
    
    /// Remove the presenter with key.
    /// - Parameter key: The key of presenter to remove.
    @MainActor func removeViewPresenter(_ key: AnyHashable) {
        if let p = presenterStore.presenters[key] {
            remove(child: p)
        }
        presenterStore.presenters[key] = nil
    }
    
    
    /// Add child with type identifier. It's helpful when type is explict.
    /// ```swift
    /// // register lazy:
    /// typeBoxLazy({ MyViewPresenter() })
    ///
    /// // register immediately
    /// typeBox(MyViewPresenter())
    ///
    /// // get:
    /// if let presenter: MyViewPresenter = typeUnbox() {
    ///     ...
    /// }
    /// ```
    
    
    /// Register presenter with its type by lazy. Presenter will create when fisrt time getting it.
    @MainActor func typeBoxLazy<P, V>(_ value: @escaping ()->P) where P: ViewPresenter<V> {
        setLazyViewPresenter(ObjectIdentifier(P.self), value)
    }
    
    /// Register presenter with its type.
    @discardableResult
    @MainActor func typeBox<P, V>(_ value: P) -> P where P: ViewPresenter<V> {
        setViewPresenter(ObjectIdentifier(P.self), value)
        return value
    }
    
    /// Get the presenter registered with return type, and convert to this type if possible.
    /// It will register the presenter when call it first time.
    @MainActor func typeUnboxLazy<P, V>(_ value: @escaping ()->P) -> P? where P: ViewPresenter<V> {
        if let p: P = typeUnbox() {
            return p
        }
        typeBoxLazy(value)
        return typeUnbox()
    }
    
    /// Get the presenter registered with return type, and convert to this type if possible.
    /// - Returns: Presenter with type `T`
    @MainActor func typeUnbox<T>() -> T? {
        let p = getViewPresenter(ObjectIdentifier(T.self))
        return p as? T
    }
    
    /// Get the presenter registered with return type, and convert to this type if possible.
    /// - Returns: Presenter with type `T`
    @MainActor func unbox<T>(type: T.Type) -> T? {
        let p = getViewPresenter(ObjectIdentifier(T.self))
        return p as? T
    }
    
    /// Remove the presenter registered with type `T`.
    @MainActor func removeTypeBox<T>(_ type: T.Type) {
        removeViewPresenter(ObjectIdentifier(type))
    }
}

/// Provider a presenter that can manage children by id or type.
/// ```
/// presenter.getViewPresenter(id)
/// presenter.typeUnbox() as? MyViewPresenter
/// ```
open class GroupedViewPresenter<View>: ViewPresenter<View>, ViewPresenterIdentify {
    
    @MainActor public private(set) lazy var presenterStore = ViewPresenterIdentifierStore()
    
}




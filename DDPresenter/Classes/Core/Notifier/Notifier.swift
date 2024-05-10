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

public enum NotifyScope {
    case global             // Notify from root to all children presenters
    case reusable           // Notify to nearest reusable parent presenter and its children
    case children           // Notify to its chidren
    case childrenAndSelf    // Notify to its children and itself
    case parents            // Notify to its parents, until to root presenter
    case manually           // Nofity to listeners that added manually
}


public protocol Notifier: AnyObject {
    @MainActor func notify<T>(listener: T.Type,
                              scope: NotifyScope,
                              from notifier: AnyObject?,
                              _ closure:(T)->Void)
}

extension Notifier {
    
    /// Notify the message to all listeners.
    @MainActor public func notifyGlobal<T>(listener: T.Type, _ closure:(T)->Void) {
        notify(listener: listener, scope: .global, from: self, closure)
    }
    
    /// Notify the message to nearest reusable parent presenter and its children.
    @MainActor public func notifyReusable<T>(listener: T.Type, _ closure:(T)->Void) {
        notify(listener: listener, scope: .reusable, from: self, closure)
    }
    
    /// Notify the message to children presenters.
    @MainActor public func notifyChildren<T>(listener: T.Type, _ closure:(T)->Void) {
        notify(listener: listener, scope: .children, from: self, closure)
    }
    
    /// Notify the message to its prarents presenters.
    @MainActor public func notifyParents<T>(listener: T.Type, _ closure:(T)->Void) {
        notify(listener: listener, scope: .parents, from: self, closure)
    }
    
    /// Notify the message to listeners that add manually.
    @MainActor public func notifyManually<T>(listener: T.Type, _ closure:(T)->Void) {
        notify(listener: listener, scope: .manually, from: self, closure)
    }
    
    /// Notify the message, and the notifier is self.
    @MainActor public func notify<T>(listener: T.Type, scope: NotifyScope, _ closure:(T)->Void) {
        notify(listener: listener, scope: scope, from: self, closure)
    }
}

public protocol NotifyRegistrar {
    @MainActor func add<T>(listener: T.Type, object: AnyObject)
    @MainActor func remove<T>(listener: T.Type, object: AnyObject)
}

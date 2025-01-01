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

public final class NotifyManager: NotifyRegistrar {
    
    private class DummyNotifier {}
    private static let dummyNotifier = ObjectIdentifier(DummyNotifier.self)
    
    private struct ListenerObject: Hashable {
        var key: ObjectIdentifier
        weak var value: AnyObject?
        init<T: AnyObject>(_ value: T) {
            self.value = value
            self.key = ObjectIdentifier(value)
        }
        func unbox<T>() -> T? {
            return value as? T
        }
        
        static func == (lhs: NotifyManager.ListenerObject, rhs: NotifyManager.ListenerObject) -> Bool {
            lhs.key == rhs.key
        }
        
        var hashValue: Int {
            key.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            key.hash(into: &hasher)
        }
    }
    
    @MainActor private var listeners: [ObjectIdentifier: Set<ListenerObject>] = [:]
    
    @MainActor public func add<T>(listener: T.Type, object: AnyObject) {
        assert(object is T, "Object MUST implement type \(T.self)")
        if var container = listeners[ObjectIdentifier(listener)] {
            container.insert(ListenerObject(object))
        }
        else {
            var set = Set<ListenerObject>()
            set.insert(ListenerObject(object))
            listeners[ObjectIdentifier(listener)] = set
        }
    }
    
    @MainActor public func remove<T>(listener: T.Type, object: AnyObject) {
        assert(object is T, "Object MUST implement type \(T.self)")
        listeners[ObjectIdentifier(listener)]?.remove(ListenerObject(object))
    }
    
    @MainActor public func removeAllListeners(of object: AnyObject) {
        for key in listeners.keys {
            self.listeners[key]?.remove(ListenerObject(object))
        }
    }
    
    @MainActor public func notify<T>(listener: T.Type, from notifier: AnyObject?, _ closure:(T)->Void) {
        let from = {
            if let notifier = notifier {
                return ObjectIdentifier(notifier)
            }
            else {
                return NotifyManager.dummyNotifier
            }
        }()
        if let notifiees = listeners[ObjectIdentifier(listener)] {
            for notifiee in notifiees {
                if let realObject = notifiee.value as? T, notifiee.key != from {
                    closure(realObject)
                }
            }
        }
    }
}

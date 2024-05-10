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

public protocol Service {}

public protocol ServiceProvider {
    func getService<T>(_ type: T.Type) -> T?
}

/// Not pure service, needs other service or notify presenter tree messages.
/// You can use `getService()` and `notify()` directly in a dirty service.
open class DirtyService: Service, ServiceProvider, Notifier {
    private let lock = NSLock()
    private var _provider: (ServiceProvider & Notifier)? = nil
    
    public init() {}
    
    var provider: (ServiceProvider & Notifier)? {
        get { lock.withLock({ _provider })}
        set {
            lock.withLock {
                _provider = newValue
            }
        }
    }
    
    public func getService<T>(_ type: T.Type) -> T? {
        provider?.getService(type)
    }
    
    @MainActor public func notify<T>(listener: T.Type, scope: NotifyScope, from notifier: AnyObject?, _ closure: (T) -> Void) {
        provider?.notify(listener: listener, scope: scope, from: notifier, closure)
    }
    
}

public protocol ServiceRegistrar: ServiceProvider {
    func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T?)
    
    func unregister<T>(service: T.Type)
}

extension ServiceRegistrar {
    public func register<T>(service: T.Type, _ builder: @escaping () -> T?) {
        register(service: service, lazy: true, builder)
    }
}

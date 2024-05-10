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

public protocol ServiceProviderDowngrade {
    func getService<T>(_ type: T.Type) -> T?
}

public struct GlobalServiceConfig {
    /// If already have global service, `getService()` can use this to downgrade to global services.
    public static var serviceDowngrade: ServiceProviderDowngrade? = nil
}

/// DI system used in the presenter tree. You can register different implementary in view controllers.
final class ServiceManager: ServiceRegistrar {
    
    private weak var provider: (ServiceProvider & Notifier)?
    
    public init(provider: ServiceProvider & Notifier) {
        self.provider = provider
    }
    
    public func getService<T>(_ service: T.Type) -> T? {
        if let s = get(type: service) {
            return s
        }
        else {
            if let provider = GlobalServiceConfig.serviceDowngrade {
                return provider.getService(service)
            }
            return nil
        }
    }
    
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T?) {
        register(type: service, lazy: lazy, generator: builder)
    }
    
    public func unregister<T>(service: T.Type) {
        unregister(type: service)
    }
    
    // MARK: - Private
    
    private struct Key : Hashable {
        let type: Any.Type
        
        static func == (lhs: Key, rhs: Key) -> Bool {
            lhs.type == rhs.type
        }
        
        public func hash(into hasher: inout Hasher) {
            ObjectIdentifier(type).hash(into: &hasher)
        }
    }
    
    private struct Value {
        let service: Any?
        
        init(service: Any?) {
            self.service = service
        }
    }
    
    private struct Generator {
        let generator: () -> Any?
        
        func generate() -> Any? {
            generator()
        }
    }
    
    private let lock = NSRecursiveLock()
    private var services = [Key: Value]()
    private var serviceMetas = [Key: Generator]()
    
    private func get<T>(type: T.Type) -> T? {
        defer {
            lock.unlock()
        }
        lock.lock()
        
        let key = Key(type: type)
        if let value = services[key] {
            return value.service as? T
        }
        else {
            let service = generateNoLock(type: type)
            services[key] = Value(service: service)
            return service
        }
    }
    
    private func register<T>(type: T.Type, lazy: Bool, generator: @escaping ()->T?) {
        defer {
            lock.unlock()
        }
        lock.lock()
        let key = Key(type: type)
        let gen = Generator(generator: generator)
        serviceMetas[key] = gen
        
        if !lazy {
            let service = generateNoLock(type: type)
            services[key] = Value(service: service)
        }
    }
    
    private func unregister<T>(type: T.Type) {
        defer {
            lock.unlock()
        }
        lock.lock()
        let key = Key(type: type)
        serviceMetas[key] = nil
        services[key] = nil
    }
    
    private func generateNoLock<T>(type: T.Type) -> T? {
        if let gen = serviceMetas[Key(type: type)] {
            if let value = gen.generate() {
                assert(value is T, "Service \(value) is not implement \(T.self)")
                if let value = value as? DirtyService {
                    value.provider = ServiceHook(delegate: provider)
                }
                return value as? T
            }
        }
        return nil
    }
    
    private class ServiceHook: Notifier, ServiceProvider {
        weak var delegate: (Notifier & ServiceProvider)?
        init(delegate: (Notifier & ServiceProvider)?) {
            self.delegate = delegate
        }
        
        func getService<T>(_ type: T.Type) -> T? {
            delegate?.getService(type)
        }
        
        @MainActor func notify<T>(listener: T.Type, scope: NotifyScope, from notifier: AnyObject?, _ closure: (T) -> Void) {
            delegate?.notify(listener: listener, scope: scope, from: notifier, closure)
        }
    }
}


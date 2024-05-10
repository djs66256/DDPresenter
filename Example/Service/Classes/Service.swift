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

import DDPresenter

public struct ServiceInstaller {
    public init() {}
    
    public func installServices() {
        let registrar = ServiceManager.shared
        registrar.register(service: LikeService.self, { LikeServiceImpl() })
        registrar.register(service: DownloadService.self, { DownloadServiceImpl() })
    }
}

public class ServiceManager {
    public static let shared = ServiceManager()
    
    public func getService<T>(_ service: T.Type) -> T? {
        get(type: service)
    }
    
    public func register<T>(service: T.Type, lazy: Bool = true, _ builder: @escaping () -> T?) {
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
                return value as? T
            }
        }
        return nil
    }
}

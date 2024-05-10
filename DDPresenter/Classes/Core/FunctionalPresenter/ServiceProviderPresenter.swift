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

/// Presenter can provider new services in the children scope.
/// Service will replace global service at children scope.
open class ServiceProviderPresenter: ViewPresenter<()>, ServiceRegistrar {
    private lazy var serviceManager = ServiceManager(provider: self)
    
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T?) {
        serviceManager.register(service: service, lazy: lazy, builder)
    }
    
    public func unregister<T>(service: T.Type) {
        serviceManager.unregister(service: service)
    }
    
    open override func getService<T>(_ type: T.Type) -> T? {
        if let service = serviceManager.getService(type) {
            return service
        }
        else {
            return super.getService(type)
        }
    }
}

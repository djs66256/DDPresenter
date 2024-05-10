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

import UIKit
import Combine
import DDPresenter

public enum DownloadError: Error {
    case cancelled
    case networkingError
}

public protocol DownloadTaskRunable {
    func resume()
    func cancel()
}

public class DownloadTask<T>: DownloadTaskRunable {
    
    @Published
    public var isRunning: Bool = false
    
    @Published
    public var progress: Double = 0
    
    @Published
    public var completion: Result<T, DownloadError>?
    
    public func resume() {}
    public func cancel() {}
}

public protocol DownloadService: Service {
    func mockDownload<R: Identifiable, V>(resource: R, duration: Double, result: Result<V, DownloadError>)
    func download<R: Identifiable, V>(resource: R, resultType: V.Type) -> DownloadTask<V>
    func findDownloadedValue<R: Identifiable, V>(resource: R, resultType: V.Type) -> V?
    func findRunningTask<R: Identifiable, V>(resource: R, resultType: V.Type) -> DownloadTask<V>?
}

class DownloadServiceImpl: DownloadService {
    
    private class MockTask<R, T>: DownloadTask<T> {
        let resource: R
        let duration: Double
        let result: Result<T, DownloadError>
        
        init(resource: R, duration: Double, result: Result<T, DownloadError>) {
            self.resource = resource
            self.duration = duration
            self.result = result
        }
        
        var timer: Timer?
        override func resume() {
            isRunning = true
            
            var progress: Double = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] timer in
                guard let self else { return }
                progress += min(0.1 / duration, 1)
                self.progress = progress
                
                if progress >= 1 {
                    self.complete()
                }
            })
        }
        
        func complete() {
            timer?.invalidate()
            timer = nil
            self.isRunning = false
            self.completion = self.result
        }
        
        override func cancel() {
            timer?.invalidate()
            timer = nil
            self.isRunning = false
            self.completion = .failure(.cancelled)
        }
    }
    
    private struct Key: Hashable {
        let type: ObjectIdentifier
        let id: AnyHashable
        
        init(type: ObjectIdentifier, id: AnyHashable) {
            self.type = type
            self.id = id
        }
        init<R>(_ resource: R) where R : Identifiable {
            self.init(type: ObjectIdentifier(R.self), id: resource.id)
        }
    }
    
    private var mocks: [Key: () -> DownloadTaskRunable] = [:]
    
    func mockDownload<R, V>(resource: R, duration: Double, result: Result<V, DownloadError>) where R : Identifiable {
        mocks[Key(resource)] = {
            MockTask(resource: resource, duration: duration, result: result)
        }
    }
    
    private var cancelables: [AnyCancellable] = []
    private var runningTasks: [Key: DownloadTaskRunable] = [:]
    private var results: [Key: Any] = [:]
    
    func download<R, V>(resource: R, resultType: V.Type) -> DownloadTask<V> where R : Identifiable {
        if let runningTask = runningTasks[Key(resource)] {
            return runningTask as! DownloadTask<V>
        }
        else if let task = mocks[Key(resource)]?() as? MockTask<R, V> {
            runningTasks[Key(resource)] = task
            task.$completion.sink { [weak self] result in
                guard let result, let self else { return }
                runningTasks.removeValue(forKey: Key(resource))
                if case .success(let value) = result {
                    results[Key(resource)] = value
                }
            }.store(in: &cancelables)
            task.resume()
            return task
        }
        fatalError("MUST Mock download first!")
    }
    
    func findDownloadedValue<R: Identifiable, V>(resource: R, resultType: V.Type) -> V? {
        results[Key(resource)] as? V
    }
    
    func findRunningTask<R: Identifiable, V>(resource: R, resultType: V.Type) -> DownloadTask<V>? {
        if let runningTask = runningTasks[Key(resource)] {
            return runningTask as? DownloadTask<V>
        }
        return nil
    }
}

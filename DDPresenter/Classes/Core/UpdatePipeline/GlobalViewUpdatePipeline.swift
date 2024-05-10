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

public protocol ViewUpdatePipelineQueue {
    func async(_ closure: @escaping @MainActor () -> Void)
}

struct ViewUpdatePipelineDispatchQueue: ViewUpdatePipelineQueue {
    func async(_ closure: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async(execute: closure)
    }
}

@MainActor
public class GlobalViewUpdatePipeline {
    public static let shared = GlobalViewUpdatePipeline()
    
    public var queue: ViewUpdatePipelineQueue = ViewUpdatePipelineDispatchQueue()
    
    private struct PipelineWrapper: Hashable {
        let value: ViewUpdatePipeline
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.value === rhs.value
        }
        
        var hashValue: Int {
            ObjectIdentifier(value).hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            ObjectIdentifier(value).hash(into: &hasher)
        }
    }
    
    private var pipelines = Set<PipelineWrapper>()
    public private(set) var isDirty = false
    
    func markDirty(_ pipeline: ViewUpdatePipeline) {
        pipelines.insert(PipelineWrapper(value: pipeline))
        
        if !isDirty {
            isDirty = true
            queue.async {
                guard self.isDirty else { return }
                
                self.updateView(synchronize: false)
                self.isDirty = false
            }
        }
    }
    
    public func updateView(synchronize: Bool) {
        Logger.log("<GlobalViewUpdatePipeline> begin update view, synchronize: \(synchronize)")
        var pipelines = pipelines
        self.pipelines = Set<PipelineWrapper>()
        while !pipelines.isEmpty {
            for wrapper in pipelines {
                let pipeline = wrapper.value
                pipeline.updateViewIfNeeded(synchronize: synchronize)
            }
            
            pipelines = self.pipelines
            self.pipelines = Set<PipelineWrapper>()
        }
        Logger.log("<GlobalViewUpdatePipeline> end update view, synchronize: \(synchronize)")
    }
    
    func updateView(for pipeline: ViewUpdatePipeline, synchronize: Bool) {
        Logger.log("<GlobalViewUpdatePipeline> begin update view for \(pipeline), synchronize: \(synchronize)")
        if let wrapper = pipelines.remove(PipelineWrapper(value: pipeline)) {
            wrapper.value.updateViewIfNeeded(synchronize: synchronize)
        }
        Logger.log("<GlobalViewUpdatePipeline> end update view for \(pipeline), synchronize: \(synchronize)")
    }
}

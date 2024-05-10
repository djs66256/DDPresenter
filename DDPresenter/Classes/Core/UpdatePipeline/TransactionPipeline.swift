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
class TransactionPipeline: ViewUpdatePipeline {
    
    weak var superPipeline: ViewUpdatePipeline?
    weak var rootView: UIView?
    weak var rootPresenter: Presenter?
    
    private lazy var globalPipeline = GlobalViewUpdatePipeline.shared
    
    fileprivate var transaction = CompositeTransaction()
    private var isUpdating = false
    private var isDestroyed = false
    
    init(presenter: Presenter, view: UIView? = nil) {
        self.rootPresenter = presenter
        self.rootView = view
    }
    
    func destroy() {
        isDestroyed = true
    }
    
    func markDirty(presenter: Presenter, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        guard !isDestroyed else { return }
        
        if context.isBindingView {
            presenter.updateView(context: context)
            presenter.updateLayout(context: context)
            completion?()
            return
        }
        
        Logger.log("<TransactionPipeline> mark dirty: \(presenter), updating: \(isUpdating)")
        
        transaction.markDirty(presenter: presenter, context: context, completion)
        
        if !isUpdating {
            // When during updating, should not mark dirty, as it will collect it immediately.
            // Notify global pipeline to update it.
            globalPipeline.markDirty(self)
        }
    }
    
    func updateViewPresenterIfNeeded(_ presenter: Presenter) {
        guard !isDestroyed else { return }
        
        if let transaction = transaction.remove(for: presenter) {
            transaction.updateView()
            transaction.updateLayout()
            transaction.complete()
        }
    }
    
    func updateViewIfNeeded(synchronize: Bool) {
        guard !isDestroyed else { return }
        guard transaction.isDirty else { return }
        
        Logger.log("<TransactionPipeline> update view: synchronize \(synchronize)")
        
        let transaction = doUpdateViewRecursively()
        transaction.updateLayout()
        transaction.complete()
    }
    
    private func doUpdateViewRecursively() -> CompositeTransaction {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
        let finalTransaction = CompositeTransaction()
        // It may mark dirty during update view. Collect them until no updation.
        while self.transaction.isDirty {
            let transaction = self.transaction
            self.transaction = CompositeTransaction()
            
            transaction.updateView()
            finalTransaction.merge(transaction)
        }
        
        return finalTransaction
    }
}


class DryRunTransactionPipeline : TransactionPipeline {
    
    override func markDirty(presenter: Presenter, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        var context = ViewUpdateContext()
        context.isDryRun = true
        context.layoutIfNeeded = true
        
        transaction.markDirty(presenter: presenter, context: context, completion)
    }
}

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

public protocol ViewUpdateTransaction {
    @MainActor func updateView()
    @MainActor func updateLayout()
    @MainActor func complete()
}

@MainActor
class UpdateTransaction: ViewUpdateTransaction {
    var presenter: Presenter
    var context: ViewUpdateContext
    var completions: [() -> Void] = []
    
    init(presenter: Presenter, context: ViewUpdateContext, completion: (() -> Void)?) {
        self.presenter = presenter
        self.context = context
        self.completions = { if let completion { return [completion] } else { return [] } }()
    }
    
    func merge(context: ViewUpdateContext, completion: (() -> Void)?) {
        self.context.merge(context)
        if let completion {
            self.completions.append(completion)
        }
    }
    
    func merge(_ other: UpdateTransaction) {
        self.context.merge(other.context)
        self.completions.append(contentsOf: other.completions)
    }
    
    func updateView() {
        presenter.updateView(context: context)
    }
    
    func updateLayout() {
        presenter.updateLayout(context: context)
    }
    
    func complete() {
        for completion in completions {
            completion()
        }
    }
}

@MainActor
class CompositeTransaction {
    
    private struct Key: Hashable {
        var presenter: Presenter
        
        var hashValue: Int { presenter.hashValue }
        func hash(into hasher: inout Hasher) {
            presenter.hash(into: &hasher)
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.presenter == rhs.presenter
        }
    }
    
    private var transactions: [Key: UpdateTransaction] = [:]
    
    var isDirty: Bool { !transactions.isEmpty }
    
    func clear() {
        transactions.removeAll()
    }
    
    func remove(for presenter: Presenter) -> UpdateTransaction? {
        transactions.removeValue(forKey: Key(presenter: presenter))
    }
    
    func merge(_ other: CompositeTransaction) {
        for (key, value) in other.transactions {
            if let my = self.transactions[key] {
                my.merge(value)
            }
            else {
                self.transactions[key] = value
            }
        }
    }
    
    var invalidateDataSource: Bool {
        for (_, transaction) in transactions {
            if transaction.context.invalidateDataSource {
                return true
            }
        }
        return false
    }
    
    var invalidateContentSize: Bool {
        for (_, transaction) in transactions {
            if transaction.context.invalidateContentSize {
                return true
            }
        }
        return false
    }
    
    var mergedContext: ViewUpdateContext {
        var fullfill = ViewUpdateContext.fullfill
        for (_, transaction) in transactions {
            fullfill.merge(transaction.context)
        }
        return fullfill
    }
    
    var reloadDataContext: ViewUpdateContext {
        var fullfill = ViewUpdateContext.fullfill
        for (_, transaction) in transactions {
            if transaction.context.invalidateDataSource {
                fullfill.merge(transaction.context)
            }
        }
        return fullfill
    }
    
    var invalidateContentSizeContext: ViewUpdateContext {
        var fullfill = ViewUpdateContext.fullfill
        for (_, transaction) in transactions {
            if transaction.context.invalidateContentSize {
                fullfill.merge(transaction.context)
            }
        }
        return fullfill
    }
    
    func markDirty(presenter: Presenter, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        let key = Key(presenter: presenter)
        if let transaction = transactions[key] {
            transaction.merge(context: context, completion: completion)
        }
        else {
            let transaction = UpdateTransaction(presenter: presenter, context: context, completion: completion)
            transactions[key] = transaction
        }
    }
    
    func updateView() {
        for (key, transaction) in transactions {
            transaction.context.animate(key.presenter) {
                transaction.updateView()
            }
        }
    }
    
    func updateLayout() {
        for (key, transaction) in transactions {
            transaction.context.animate(key.presenter) {
                transaction.updateLayout()
            }
        }
    }
    
    func complete() {
        for (_, transaction) in transactions {
            transaction.complete()
        }
        transactions.removeAll()
    }
}

extension ViewUpdateContext {
    fileprivate static var fullfill: ViewUpdateContext {
        var context = ViewUpdateContext()
        context.animated = true
        return context
    }
}

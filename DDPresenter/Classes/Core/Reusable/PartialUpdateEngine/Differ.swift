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

extension Engine {
    
    struct Differ {
        
        struct IndexDiffResult {
            struct Move {
                var from: Int
                var to: Int
            }
            
            var inserts: IndexSet = IndexSet()
            var deletes: IndexSet = IndexSet()
            var moves: [Move] = []
            
            var hasChanges: Bool {
                inserts.count == 0 && deletes.count == 0 && moves.count == 0
            }
            
            fileprivate var oldIndexes: [ObjectIdentifier: Int] = [:]
            fileprivate var newIndexes: [ObjectIdentifier: Int] = [:]
            
            func oldIndex<T: EngineViewPresenterReadable>(of obj: T) -> Int? {
                oldIndexes[obj]
            }
            func newIndex<T: EngineViewPresenterReadable>(of obj: T) -> Int? {
                newIndexes[obj]
            }
        }
        
        struct IndexPathDiffResult {
            struct Move {
                var from: IndexPath
                var to: IndexPath
            }
            
            var inserts: [IndexPath] = []
            var deletes: [IndexPath] = []
            var moves: [Move] = []
            
            var hasChanges: Bool {
                inserts.count == 0 && deletes.count == 0 && moves.count == 0
            }
        }
        
        
        typealias Section = Engine.DataSource.Section
        typealias Item = Engine.DataSource.Item
        
        func diff<T: EngineViewPresenterReadable>(old: [T], new: [T]) -> IndexDiffResult {
            var result = IndexDiffResult()
            if old.count == 0, new.count == 0 {
                // do nothing
            }
            else if old.count == 0 {
                result.inserts = IndexSet(integersIn: 0 ..< new.count)
            }
            else if new.count == 0 {
                result.deletes = IndexSet(integersIn: 0 ..< old.count)
            }
            else {
                var oldIndexes: [ObjectIdentifier: Int] = [:]
                oldIndexes.reserveCapacity(old.count)
                var newIndexes: [ObjectIdentifier: Int] = [:]
                newIndexes.reserveCapacity(new.count)
                
                for (i, s) in old.enumerated() {
                    oldIndexes[s] = i
                }
                for (i, s) in new.enumerated() {
                    newIndexes[s] = i
                }
                
                var deleteOffsets: [Int] = []
                deleteOffsets.reserveCapacity(old.count)
//                var insertOffsets: [Int] = []
//                insertOffsets.reserveCapacity(new.count)
                
                
                var deletes = IndexSet()
                var inserts = IndexSet()
                var moves: [IndexDiffResult.Move] = []
                
                var runningOffset = 0
                for (oldIndex, section) in old.enumerated() {
                    deleteOffsets.append(runningOffset)
                    if newIndexes[section] == nil {
                        deletes.insert(oldIndex)
                        runningOffset += 1
                    }
                }
                
                runningOffset = 0
                for (newIndex, section) in new.enumerated() {
//                    insertOffsets[newIndex] = runningOffset
                    if let oldIndex = oldIndexes[section] {
                        let calculatedIndex = oldIndex - deleteOffsets[oldIndex] + runningOffset
                        if calculatedIndex != newIndex {
                            moves.append(IndexDiffResult.Move(from: oldIndex, to: newIndex))
                        }
                    }
                    else {
                        inserts.insert(newIndex)
                        runningOffset += 1
                    }
                }
                
                result.deletes = deletes
                result.inserts = inserts
                result.moves = moves
                result.oldIndexes = oldIndexes
                result.newIndexes = newIndexes
            }
            
            return result
        }
        
        func diff(oldSection: Int, newSection: Int, oldItems: [Item], newItems: [Item]) -> IndexPathDiffResult {
            let indexResult = diff(old: oldItems, new: newItems)
            var result = IndexPathDiffResult()
            result.deletes = indexResult.deletes.map({ IndexPath(item: $0, section: oldSection) })
            result.inserts = indexResult.inserts.map({ IndexPath(item: $0, section: newSection) })
            result.moves = indexResult.moves.map({
                IndexPathDiffResult.Move(from: IndexPath(item: $0.from, section: oldSection),
                                         to: IndexPath(item: $0.to, section: newSection))
            })
            return result
        }
    }
    
}

fileprivate extension Dictionary where Key == ObjectIdentifier {
    
    typealias Section = Engine.DataSource.Section
    typealias Item = Engine.DataSource.Item
    
    subscript(_ key: Presenter) -> Value? {
        set {
            self[ObjectIdentifier(key)] = newValue
        }
        get {
            return self[ObjectIdentifier(key)]
        }
    }
    
    subscript(_ key: EngineViewPresenterReadable) -> Value? {
        set {
            self[ObjectIdentifier(key.presenter)] = newValue
        }
        get {
            return self[ObjectIdentifier(key.presenter)]
        }
    }
    
    subscript(_ key: Section) -> Value? {
        set {
            self[ObjectIdentifier(key.presenter)] = newValue
        }
        get {
            return self[ObjectIdentifier(key.presenter)]
        }
    }
    
    subscript(_ key: Item) -> Value? {
        set {
            self[ObjectIdentifier(key.presenter)] = newValue
        }
        get {
            return self[ObjectIdentifier(key.presenter)]
        }
    }
}

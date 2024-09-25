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

protocol ListUpdateProtocol {
    typealias IndexDiffResult = Engine.Differ.IndexDiffResult
    typealias IndexPathDiffResult = Engine.Differ.IndexPathDiffResult
    func invalidateLayout()
    func reloadData()
    func layoutIfNeeded()
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func performBatchUpdates(_ updater: ()->Void, completion: @escaping (Bool)->Void)
    func performBatchUpdates(sectionDiffer: IndexDiffResult, itemDiffer: [IndexPathDiffResult])
}

extension Engine {
    struct UICollectionViewUpdateResolver: ListUpdateProtocol {
        
        let collectionView: UICollectionView
        
        func invalidateLayout() {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        
        func reloadData() {
            collectionView.reloadData()
        }
        
        func layoutIfNeeded() {
            collectionView.layoutIfNeeded()
        }
        
        func insertSections(_ sections: IndexSet) {
            collectionView.insertSections(sections)
        }
        
        func deleteSections(_ sections: IndexSet) {
            collectionView.deleteSections(sections)
        }
        
        func performBatchUpdates(_ updater: () -> Void, completion: @escaping (Bool) -> Void) {
            do {
                try collectionView.performBatchUpdates(updater, completion: completion)
            }
            catch {
                Logger.log("<UICollectionViewUpdateResolver> performBatchUpdates failed: \(error)")
            }
        }
        
        func performBatchUpdates(sectionDiffer: IndexDiffResult, itemDiffer: [IndexPathDiffResult]) {
            for differ in itemDiffer {
                if differ.deletes.count > 0 {
                    collectionView.deleteItems(at: differ.deletes)
                }
                if differ.inserts.count > 0 {
                    collectionView.insertItems(at: differ.inserts)
                }
                for move in differ.moves {
                    collectionView.moveItem(at: move.from, to: move.to)
                }
            }
            if sectionDiffer.deletes.count > 0 {
                collectionView.deleteSections(sectionDiffer.deletes)
            }
            if sectionDiffer.inserts.count > 0 {
                collectionView.insertSections(sectionDiffer.inserts)
            }
            for move in sectionDiffer.moves {
                collectionView.moveSection(move.from, toSection: move.to)
            }
            if !sectionDiffer.reloads.isEmpty {
                collectionView.reloadSections(sectionDiffer.reloads)
            }
        }
        
    }
    
    struct UITableViewUpdateResolver: ListUpdateProtocol {
        
        let tableView: UITableView
        
        func invalidateLayout() {
            tableView.setNeedsLayout()
        }
        
        func reloadData() {
            tableView.reloadData()
        }
        
        func layoutIfNeeded() {
            tableView.layoutIfNeeded()
        }
        
        func insertSections(_ sections: IndexSet) {
            tableView.insertSections(sections, with: .none)
        }
        
        func deleteSections(_ sections: IndexSet) {
            tableView.deleteSections(sections, with: .none)
        }
        
        func performBatchUpdates(_ updater: () -> Void, completion: @escaping (Bool) -> Void) {
            do {
                try tableView.performBatchUpdates(updater, completion: completion)
            }
            catch {
                Logger.log("<UICollectionViewUpdateResolver> performBatchUpdates failed: \(error)")
            }
        }
        
        func performBatchUpdates(sectionDiffer: IndexDiffResult, itemDiffer: [IndexPathDiffResult]) {
            for differ in itemDiffer {
                if differ.deletes.count > 0 {
                    tableView.deleteRows(at: differ.deletes, with: .none)
                }
                if differ.inserts.count > 0 {
                    tableView.insertRows(at: differ.inserts, with: .none)
                }
                for move in differ.moves {
                    tableView.moveRow(at: move.from, to: move.to)
                }
            }
            if sectionDiffer.deletes.count > 0 {
                tableView.deleteSections(sectionDiffer.deletes, with: .none)
            }
            if sectionDiffer.inserts.count > 0 {
                tableView.insertSections(sectionDiffer.inserts, with: .none)
            }
            for move in sectionDiffer.moves {
                tableView.moveSection(move.from, toSection: move.to)
            }
            if !sectionDiffer.reloads.isEmpty {
                tableView.reloadSections(sectionDiffer.reloads, with: .none)
            }
        }
    }
}

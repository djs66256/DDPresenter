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

protocol EngineViewPresenterReadable {
    var presenter: Presenter { get }
}

struct Engine {}

extension Engine {
    class DataSource {
        struct Root: EngineViewPresenterReadable {
            var presenter: Presenter
        }
        
        struct Item: EngineViewPresenterReadable {
            var presenter: Presenter
        }
        
        struct Section: EngineViewPresenterReadable {
            var presenter: Presenter
            let items: [Item]
            let supplementaries: [String: [Item]]
            
            func areSupplementariesEquals(_ other: Section) -> Bool {
                guard self.supplementaries.count == other.supplementaries.count else {
                    return false
                }
                return self.supplementaries.elementsEqual(other.supplementaries, by: {
                    $0.value.elementsEqual($1.value) {
                        $0.presenter === $1.presenter
                    }
                })
            }
        }
        
        init(root: CollectionPresentable) {
            self._root = Root(presenter: root)
        }
        
        private var _root: Root
        var sections: [Section] = []
        
    }
}

extension Engine.DataSource {
    func root<T>() -> T? {
        return _root.presenter as? T
    }
    
    var indexes: [(String, IndexPath)]? {
        // TODO:
        nil
    }
    
    func indexTitles() -> [String]? {
        // TODO:
        nil
    }
    func indexPath(at index: Int) -> IndexPath {
        IndexPath()
    }
    
    func sectionCount() -> Int {
        sections.count
    }
    
    func itemCount(at section: Int) -> Int {
        sections[section].items.count
    }
    
    func item<T>(at indexPath: IndexPath) -> T? {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        return item.presenter as? T
    }
    
    func section<T>(at index: Int) -> T? {
        let section = sections[index]
        return section.presenter as? T
    }
    
    func supplementary<T>(for kind: String, at indexPath: IndexPath) -> T? {
        let section = sections[indexPath.section]
        let supplies = section.supplementaries[kind]
        return supplies?[indexPath.item].presenter as? T
    }
//        func supplementaryPresenter<T>(for kind: String, at index: IndexPath) -> (AnyViewPresenter, T?)? {
//            return nil
//        }
    
    func moveItem(at: IndexPath, to: IndexPath) {
        // TODO: 
    }
    
    @MainActor
    public func sectionIndex(for presenter: CollectionSectionPresentable) -> Int? {
        if let section = presenter.superPresenter as? CollectionSectionPresentable {
            var i = 0
            for sourceSection in sections {
                if sourceSection.presenter == section {
                    return i
                }
                i += 1
            }
        }
        return nil
    }
    
    @MainActor
    public func indexPath(forItem presenter: ReusableViewPresenterHoldable) -> IndexPath? {
        if let section = presenter.superPresenter as? CollectionSectionPresentable {
            var i = 0
            for sourceSection in sections {
                if sourceSection.presenter == section {
                    var j = 0
                    for sourceItem in sourceSection.items {
                        if sourceItem.presenter == presenter {
                            return IndexPath(item: j, section: i)
                        }
                        j += 1
                    }
                }
                i += 1
            }
        }
        return nil
    }
    
    @MainActor
    public func indexPath(forSupplementary presenter: ReusableViewPresenterHoldable) -> (String, IndexPath)? {
        if let section = presenter.superPresenter as? CollectionSectionPresentable {
            var i = 0
            for sourceSection in sections {
                if sourceSection.presenter == section {
                    for (kind, sourceItems) in sourceSection.supplementaries {
                        var j = 0
                        for sourceItem in sourceItems {
                            if sourceItem.presenter == presenter {
                                return (kind, IndexPath(item: j, section: i))
                            }
                            j += 1
                        }
                    }
                }
                i += 1
            }
        }
        return nil
    }
}

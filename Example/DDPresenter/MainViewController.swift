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
import DDPresenter
import AppStore
import DouYin
import TouTiao
import RedBook
import WeChat

fileprivate protocol NavigationService {
    @MainActor func pushViewController(_ viewController: UIViewController, animated: Bool)
}

fileprivate class CellPresenter: UITableViewCellSelfHolderPresenter<UITableViewCell> {
    let name: String
    let viewController: () -> UIViewController
    let action: (() -> Void)?
    
    init(name: String, viewController: @escaping () -> UIViewController, action: (() -> Void)?) {
        self.name = name
        self.viewController = viewController
        self.action = action
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func calculateHeight(containerSize: CGSize) -> CGFloat {
        return 44
    }
    
    override func onUpdate(view: UITableViewCell, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        view.textLabel?.text = name
    }
    
    override func onDidSelect() {
        super.onDidSelect()
        
        deselectRow(animated: true)
        
        if let action {
            action()
        }
        else {
            let vc = viewController()
            getService(NavigationService.self)?.pushViewController(vc, animated: true)
        }
    }
}

class MainViewController: UITablePageDefaultViewController {
    
    private struct NavigationServiceImpl: NavigationService {
        weak var navigationController: UINavigationController?
        
        func pushViewController(_ viewController: UIViewController, animated: Bool) {
            navigationController?.pushViewController(viewController, animated: animated)
        }
    }
    
    override func presenterDidLoad() {
        super.presenterDidLoad()
        
        register(service: NavigationService.self) { [weak self] in
            NavigationServiceImpl(navigationController: self?.navigationController)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        self.title = "Main View Controller"
        
        let sections: [UITableViewSectionPresenter] = [
            {
                let section = UITableViewSectionPresenter()
                section.headerTitle = "Function Test"
                section.setItems([
                    CellPresenter(name: "Stateful", viewController: { MyStatefulViewController() }, action: nil),
                    CellPresenter(name: "Service", viewController: { MyServiceViewController() }, action: nil),
                    CellPresenter(name: "Notifications", viewController: { MyNotificationViewController() }, action: nil),
                    CellPresenter(name: "Animations", viewController: { MyAnimationViewController() }, action: nil),
                ])
                return section
            }(),
            {
                let section = UITableViewSectionPresenter()
                section.headerTitle = "UICollectionView Test"
                section.setItems([
                    CellPresenter(name: "UICollectionView header", viewController: { HeaderFooterViewController() }, action: nil),
                    CellPresenter(name: "UICollectionView cell auto size", viewController: { UICollectionViewAutoSizeViewController() }, action: nil),
                    CellPresenter(name: "UICollectionView data source diff", viewController: { UICollectionViewDiffViewController() }, action: nil),
                ])
                return section
            }(),
            {
                let section = UITableViewSectionPresenter()
                section.headerTitle = "UITableView Test"
                section.setItems([
                    CellPresenter(name: "UITableView cell auto size", viewController: { UITableViewAutoSizeViewControllerViewController() }, action: nil),
                    CellPresenter(name: "UITableView data source diff", viewController: { UITableViewDiffViewControllerViewController() }, action: nil),
                ])
                return section
            }(),
            {
                let section = UITableViewSectionPresenter()
                section.headerTitle = "App Demo"
                section.setItems([
                    CellPresenter(name: "AppStore", viewController: { AppStore.MainViewController() }, action: nil),
                    CellPresenter(name: "Red Book", viewController: { RedBookHomePageViewController() }, action: nil),
                ])
                return section
            }()
            ]
        self.presenter.tableViewPresenter.setSections(sections)
    }
}

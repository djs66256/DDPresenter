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
import Service

public class MainViewController: UITabBarController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewControllers = [
            ViewControllerBuilder.buildToday(),
            ViewControllerBuilder.buildGames(),
            ViewControllerBuilder.buildApps(),
            ViewControllerBuilder.buildSearch()
        ]
    }
    
    struct ViewControllerBuilder {
        static func buildToday() -> UIViewController {
            let c = TodayViewControllerViewController()
            c.title = "Today"
            c.tabBarItem = UITabBarItem(title: "Today", image: UIImage.imageFromColor(.gray, size: CGSize(width: 30, height: 30)), tag: 0)
            return c
        }
        static func buildGames() -> UIViewController {
            let c = AppViewControllerViewController()
            c.title = "Games"
            c.tabBarItem = UITabBarItem(title: "Games", image: UIImage.imageFromColor(.gray, size: CGSize(width: 30, height: 30)), tag: 0)
            return c
        }
        static func buildApps() -> UIViewController {
            let c = AppViewControllerViewController()
            c.title = "Apps"
            c.tabBarItem = UITabBarItem(title: "Apps", image: UIImage.imageFromColor(.gray, size: CGSize(width: 30, height: 30)), tag: 0)
            return c
        }
        static func buildSearch() -> UIViewController {
            let c = UIViewController()
            c.view.backgroundColor = .white
            c.title = "Search"
            c.tabBarItem = UITabBarItem(title: "Search", image: UIImage.imageFromColor(.gray, size: CGSize(width: 30, height: 30)), tag: 0)
            return c
        }
    }

}

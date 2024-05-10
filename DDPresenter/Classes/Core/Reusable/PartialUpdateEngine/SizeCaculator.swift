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
import UIKit

public enum Fitting {
    case containerSize(_ containerSize: CGSize)
    case width(_ width: CGFloat)
    case height(_ height: CGFloat)
    
    public init(width: CGFloat, height: CGFloat) {
        if width.isFinite && height.isFinite {
            self = .containerSize(CGSize(width: width, height: height))
        }
        else if width.isFinite {
            self = .width(width)
        }
        else if height.isFinite {
            self = .height(height)
        }
        else {
            assert(false)
            self = .containerSize(.zero)
        }
    }
}

public protocol SizeCaculatable {
    @MainActor func size(for view: UIView, fitting: Fitting) -> CGSize
    
    @MainActor func size(for cell: UICollectionViewCell, fitting: Fitting) -> CGSize
    @MainActor func size(for cell: UITableViewCell, fitting: Fitting) -> CGSize
}

public extension SizeCaculatable {
    @MainActor func size(for cell: UICollectionViewCell, fitting: Fitting) -> CGSize {
        size(for: cell as UIView, fitting: fitting)
    }
    @MainActor func size(for cell: UITableViewCell, fitting: Fitting) -> CGSize {
        size(for: cell as UIView, fitting: fitting)
    }
}

public class SizeCaculator {
    public enum LayoutType: Int {
        case autoLayout, sizeThatFits, intrinsicContentSize
    }
    
    var caculators: [LayoutType: SizeCaculatable] = [:]
    
    init() {
        caculators[.autoLayout] = AutoLayoutCaculator()
        caculators[.sizeThatFits] = SizeToFitCaculator()
        caculators[.intrinsicContentSize] = IntrinsicContentSizeCaculator()
    }
    
    func caculator(for layoutType: LayoutType) -> SizeCaculatable? {
        caculators[layoutType]
    }
    
    @MainActor public func size(for view: UIView, layoutType: LayoutType, fitting: Fitting) -> CGSize {
        var size: CGSize = .zero
        if let caculator = self.caculator(for: layoutType) {
            if let cell = view as? UICollectionViewCell {
                size = caculator.size(for: cell, fitting: fitting)
            }
            else if let cell = view as? UITableViewCell {
                size = caculator.size(for: cell, fitting: fitting)
            }
            else {
                size = caculator.size(for: view, fitting: fitting)
            }
        }
        else {
            assert(false, "Can not support layout type \(layoutType).")
        }
        
        return size
    }
    
    
    private var views: [ObjectIdentifier: UIView] = [:]
    private var presenters: [ObjectIdentifier: ReusablePresentable] = [:]
    private let originSize = UIScreen.main.bounds
    
    @MainActor public func dequeueView(for viewClass: UIView.Type) -> UIView {
        var view = views[ObjectIdentifier(viewClass)]
        if view == nil {
            let instance = viewClass.init(frame: originSize)
//            instance.translatesAutoresizingMaskIntoConstraints = false
            view = instance
            views[ObjectIdentifier(viewClass)] = instance
            
        }
        if let reuse = view as? UICollectionReusableView {
            reuse.prepareForReuse()
        }
        else if let reuse = view as? UITableViewCell {
            reuse.prepareForReuse()
        } else if let reuse = view as? UITableViewHeaderFooterView {
            reuse.prepareForReuse()
        }
        return view!
    }
    
    @MainActor public func dequeuePresenter(for presenterClass: ReusablePresentable.Type) -> ReusablePresentable {
        var presenter = presenters[ObjectIdentifier(presenterClass)]
        if presenter == nil {
            let instance = presenterClass.init()
            presenter = instance
            presenters[ObjectIdentifier(presenterClass)] = instance
        }
        presenter!.prepareForReuse()
        return presenter!
    }
}

class SizeToFitCaculator: SizeCaculatable {
    func size(for view: UIView, fitting: Fitting) -> CGSize {
        var size: CGSize
        switch fitting {
        case .containerSize(let s):
            size = s
        case .width(let w):
            size = CGSize(width: w, height: .infinity)
        case .height(let h):
            size = CGSize(width: .infinity, height: h)
        }
        
        return view.sizeThatFits(size)
    }
}

class IntrinsicContentSizeCaculator: SizeCaculatable {
    func size(for view: UIView, fitting: Fitting) -> CGSize {
        var size: CGSize = view.intrinsicContentSize
        switch fitting {
        case .containerSize(let s):
            size.width = size.width < 0 ? s.width : min(s.width, size.width)
            size.height = size.height < 0 ? s.height : min(s.height, size.height)
        case .width(let w):
            size.width = size.width < 0 ? w : min(w, size.width)
        case .height(let h):
            size.height = size.height < 0 ? h : min(h, size.height)
        }
        
        return size
    }
}

class AutoLayoutCaculator: SizeCaculatable {
    func size(for view: UIView, fitting: Fitting) -> CGSize {
        // Disable `translatesAutoresizingMaskIntoConstraints`, prevent creating conflict constraints
        view.translatesAutoresizingMaskIntoConstraints = false
        var activeConstraints: [NSLayoutConstraint] = []
        switch fitting {
        case .containerSize(let s):
            let width = view.helperConstraints.lessThanWidth()
            width.constant = s.width
            width.isActive = true
            let height = view.helperConstraints.lessThanHeight()
            height.constant = s.height
            height.isActive = true
            activeConstraints.append(width)
            activeConstraints.append(height)
        case .width(let w):
            if let width = view.helperConstraints.equalToWidth(createIfNeeded: true) {
                width.constant = w
                width.isActive = true
                activeConstraints.append(width)
            }
        case .height(let h):
            if let height = view.helperConstraints.equalToHeight(createIfNeeded: true) {
                height.constant = h
                height.isActive = true
                activeConstraints.append(height)
            }
        }
        let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        for activeConstraint in activeConstraints {
            activeConstraint.isActive = false
        }
        return size
    }
    
    func size(for cell: UICollectionViewCell, fitting: Fitting) -> CGSize {
        size(for: cell.contentView, fitting: fitting)
    }
    
    func size(for cell: UITableViewCell, fitting: Fitting) -> CGSize {
        size(for: cell.contentView, fitting: fitting)
    }
}

private extension UIView {
    struct CalculatorHelperConstraints {
        let view: UIView
        
        private static var equalToWidthKey = 0
        private static var equalToHeightKey = 0
        private static var lessThanWidthKey = 0
        private static var lessThanHeightKey = 0
        private static let defaultConstraintConstant = 1000.0
        func equalToWidth(createIfNeeded: Bool) -> NSLayoutConstraint? {
            if createIfNeeded {
                return constraint(for: view, key: &Self.equalToWidthKey) { view in
                    let constraint = NSLayoutConstraint(item: view,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1,
                                                        constant: Self.defaultConstraintConstant)
                    constraint.identifier = "DDPresenter-SizeCalculator-Width"
                    return constraint
                }
            }
            else {
                return constraint(for: view, key: &Self.equalToWidthKey)
            }
        }
        func equalToHeight(createIfNeeded: Bool) -> NSLayoutConstraint? {
            if createIfNeeded {
                return constraint(for: view, key: &Self.equalToHeightKey) { view in
                    let constraint = NSLayoutConstraint(item: view,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: Self.defaultConstraintConstant)
                    constraint.identifier = "DDPresenter-SizeCalculator-Height"
                    return constraint
                }
            }
            else {
                return constraint(for: view, key: &Self.equalToWidthKey)
            }
        }
        func lessThanWidth() -> NSLayoutConstraint {
            constraint(for: view, key: &Self.lessThanWidthKey) { view in
                let constraint = NSLayoutConstraint(item: view,
                                   attribute: .width,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1,
                                   constant: 0)
                constraint.identifier = "DDPresenter-SizeCalculator-Width"
                return constraint
            }!
        }
        func lessThanHeight() -> NSLayoutConstraint {
            constraint(for: view, key: &Self.lessThanHeightKey) { view in
                let constraint = NSLayoutConstraint(item: view,
                                   attribute: .height,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1,
                                   constant: 0)
                constraint.identifier = "DDPresenter-SizeCalculator-Height"
                return constraint
            }!
        }
        
        private func constraint(for view: UIView,
                                key: UnsafeRawPointer,
                                _ creation: ((UIView)->NSLayoutConstraint)? = nil) -> NSLayoutConstraint? {
            if let constraint = objc_getAssociatedObject(view, key) as? NSLayoutConstraint {
                return constraint
            }
            else if let creation = creation {
                let constraint = creation(view)
                constraint.isActive = false
                constraint.priority = .required
                view.addConstraint(constraint)
                objc_setAssociatedObject(view, key, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return constraint
            }
            else {
                return nil
            }
        }
    }
    
    var helperConstraints: CalculatorHelperConstraints {
        CalculatorHelperConstraints(view: self)
    }
}

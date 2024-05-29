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

/// Config flow layout for item
public struct UITableViewCellLayoutInfo {
    public enum LayoutType {
        case autoLayout, sizeThatFits, intrinsicContentSize
    }
    
    public enum SizeFitting {
        case auto               // Using finity container width/height to make constraints
        case containerWidth     // Using container width to make constraints
        case containerHeight    // Using container height to make constraints
        case containerSize      // Using container width and height to make constraints
        case unlimited          // Do not make width and height constraints
    }
    
    /// calculate item size automatically, otherwise should override
    /// `func calculateSize(containerSize: CGSize) -> CGSize` to calculate manually
    public var calculateSizeAutomatically: Bool = true
    
    /// Distinguish which algorithm to be used for auto calculation.
    public var layoutType: LayoutType = .autoLayout
    
    // SizeFitting defines the container size when using `autoLayout`
    public var autoLayoutSizeFitting: SizeFitting = .auto
    
    public init() {}
    
    mutating func apply(_ closure: (inout Self)->Void) {
        closure(&self)
    }
}

public protocol UITableViewItemSizeCaculatable: Presenter {
    @MainActor var layoutInfo: UITableViewCellLayoutInfo { get }
    
    /// Calculate height manually
    /// - Returns: content height
    @MainActor func calculateHeight(containerSize: CGSize) -> CGFloat
}

public protocol UITableViewReusableItemPresentable: ReusablePresentable, UITableViewItemSizeCaculatable {
    
}


public protocol UITableViewHeaderFooterPresentable {
    
    @MainActor var estimatedHeight: CGFloat { get }
    // Display
    @MainActor func onWillDisplay()
    @MainActor func onDidEndDisplaying()
}

public protocol UITableViewCellPresentable {
    
    @MainActor var estimatedHeight: CGFloat { get }
    // Display
    @MainActor func onWillDisplay()
    @MainActor func onDidEndDisplaying()
    
    // Highlight & select
    @MainActor var shouldHighlight: Bool { get }
    @MainActor func onDidHighlight()
    @MainActor func onDidUnhighlight()
    
    @MainActor var shouldSelect: Bool { get }
    @MainActor func onWillSelect()
    @MainActor func onWillDeselect()
    
    @MainActor var shouldDeselect: Bool { get }
    @MainActor func onDidSelect()
    @MainActor func onDidDeselect()
    
    // Edit
    @MainActor var canEdit: Bool { get }
    @MainActor var editStyle: UITableViewCell.EditingStyle { get }
    @MainActor var deleteConfirmationButtonTitle: String? { get }
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    @MainActor var editActions: [UITableViewRowAction]? { get }
    @MainActor var leadingSwipeActionsConfiguration: UISwipeActionsConfiguration? { get }
    @MainActor var trailingSwipeActionsConfiguration: UISwipeActionsConfiguration? { get }
    @MainActor var shouldIndentWhileEditing: Bool { get }
    @MainActor func commitEditing(style: UITableViewCell.EditingStyle)
    @MainActor func onWillBeginEditing()
    @MainActor func onDidEndEditing()
    
    // Menu
    @MainActor var shouldShowMenu: Bool { get }
    @MainActor func canPerformAction(action: Selector, with sender: Any?) -> Bool
    @MainActor func performAction(action: Selector, with sender: Any?)
    
    // TODO: Focus
    
    // Mutliple selection
    @MainActor var shouldBeginMultipleSelectionInteraction: Bool { get }
    @MainActor func didBeginMultipleSelectionInteraction()
}

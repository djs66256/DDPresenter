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
import AHDownloadButton
import SnapKit

class DownloadView: UIView, DownloadViewable, AHDownloadButtonDelegate {
    weak var delegate: DownloadViewDelegate?
    
    private lazy var button = AHDownloadButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        button.delegate = self
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var state = DownloadViewState() {
        didSet {
            switch state.state {
            case .startDownload:
                button.state = .startDownload
            case .pending:
                button.state = .pending
            case .downloading:
                button.state = .downloading
                button.progress = state.progress
            case .downloaded:
                button.state = .downloaded
            }
        }
    }
    
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        delegate?.downloadViewDidTap(self)
    }
}

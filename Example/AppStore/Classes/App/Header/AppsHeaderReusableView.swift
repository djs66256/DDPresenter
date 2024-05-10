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

class AppsHeaderReusableView: UICollectionReusableView {
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 2
        label.text = "Today"
        return label
    }()
    
    lazy var seeAllButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("See All", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(line)
        addSubview(titleLabel)
        addSubview(seeAllButton)
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 0))
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        seeAllButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

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
import SnapKit
import RandomColorSwift

class TodayLargestCardCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .imageFromColor(randomColor(), size: CGSize(width: 1, height: 1))
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    class BottomView: UIView {
        
        lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = .imageFromColor(randomColor(), size: CGSize(width: 1, height: 1))
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        
        lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 14)
            label.numberOfLines = 3
            return label
        }()
        
        lazy var detailTitleLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 12)
            return label
        }()
        
        lazy var downloadButton = DownloadView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(imageView)
            let textContentView = UIView()
            textContentView.addSubview(titleLabel)
            textContentView.addSubview(detailTitleLabel)
            addSubview(textContentView)
            addSubview(downloadButton)
            
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(40)
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(15)
            }
            
            textContentView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(imageView.snp.right).offset(10)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
            }
            
            detailTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(5)
                make.left.right.bottom.equalToSuperview()
            }
            
            downloadButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 30))
                make.left.equalTo(textContentView.snp.right).offset(10)
                make.right.equalToSuperview().offset(-15)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    lazy var bottomView = BottomView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(line)
        contentView.addSubview(bottomView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(1)
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(line.snp.bottom)
            make.height.equalTo(60)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var state = TodayLargestCardViewState() {
        didSet {
            // update subviews
        }
    }

    var appInfo: AppInfo? {
        didSet {
            titleLabel.text = appInfo?.name
            bottomView.titleLabel.text = appInfo?.name
            bottomView.detailTitleLabel.text = appInfo?.detailInfo
            bottomView.imageView.image = appInfo?.icon
        }
    }
}

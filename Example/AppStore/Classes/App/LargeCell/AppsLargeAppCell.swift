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
import RandomColorSwift

class AppsLargeAppCell: UICollectionViewCell {
    
    lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "NOW AVAILABLE"
        label.textColor = .systemBlue
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }()
    
    class CardView: UIView {
        lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = .imageFromColor(randomColor(), size: CGSize(width: 1, height: 1))
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        
        lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 24)
            label.numberOfLines = 3
            return label
        }()
        lazy var subtitleLabel: UILabel = {
            let label = UILabel()
            label.textColor = .lightGray
            label.font = .systemFont(ofSize: 12)
            label.numberOfLines = 3
            return label
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
                label.textColor = .black
                label.font = .systemFont(ofSize: 14)
                label.numberOfLines = 3
                return label
            }()
            
            lazy var detailTitleLabel: UILabel = {
                let label = UILabel()
                label.textColor = .lightGray
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
                    make.left.equalToSuperview()
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
                    make.size.equalTo(CGSize(width: 60, height: 30))
                    make.left.equalTo(textContentView.snp.right).offset(10)
                    make.right.equalToSuperview()
                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        lazy var bottomView = BottomView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .white
            layer.cornerRadius = 10
            layer.shadowOffset = CGSize(width: 1, height: 1)
            layer.shadowOpacity = 1
            layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            addSubview(imageView)
            addSubview(titleLabel)
            addSubview(subtitleLabel)
            addSubview(bottomView)
            
            imageView.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview().offset(-60)
            }
            
            subtitleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(10)
                make.bottom.equalTo(imageView.snp.bottom).offset(-10)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(10)
                make.bottom.equalTo(subtitleLabel.snp.top).offset(-5)
            }
            
            bottomView.snp.makeConstraints { make in
                make.height.equalTo(60)
                make.left.bottom.right.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    lazy var cardView = CardView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(hintLabel)
        contentView.addSubview(cardView)
        
        hintLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        cardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(10)
            make.top.equalTo(hintLabel.snp.bottom)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var app: AppInfo? {
        didSet {
            if app != oldValue {
                cardView.titleLabel.text = app?.name
                cardView.subtitleLabel.text = app?.detailInfo
                cardView.bottomView.imageView.image = app?.icon
                cardView.bottomView.titleLabel.text = app?.name
                cardView.bottomView.detailTitleLabel.text = app?.detailInfo
            }
        }
    }
}

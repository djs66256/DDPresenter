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

class HomeCardCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        return label
    }()
    
    class UserView: UIView {
        lazy var avatarView: UIImageView = {
            let imageView = UIImageView()
            return imageView
        }()
        
        lazy var nameLabel: UILabel = {
            let label = UILabel()
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            avatarView.layer.cornerRadius = 10
            avatarView.layer.masksToBounds = true
            addSubview(avatarView)
            addSubview(nameLabel)
            
            avatarView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
            
            nameLabel.snp.makeConstraints { make in
                make.left.equalTo(avatarView.snp.right).offset(5)
                make.centerY.equalToSuperview()
                make.right.lessThanOrEqualToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var user: User? {
            didSet {
                if user != oldValue {
                    nameLabel.text = user?.name
                    avatarView.image = user?.avatar
                }
            }
        }
    }
    
    lazy var userView: UserView = UserView()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setTitle("0", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    var ratioConstraints: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(userView)
        contentView.addSubview(likeButton)
        
        imageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            ratioConstraints = make.height.equalTo(imageView.snp.width).multipliedBy(1).constraint.layoutConstraints.first
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
        }
        
        userView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(5)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualToSuperview()
            make.height.equalTo(24)
        }
        
        likeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(5)
            make.centerY.equalTo(userView)
            make.left.equalTo(userView.snp.right).offset(5)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var state = HomeCardViewState() {
        didSet {
            if state.item != oldValue.item {
                imageView.image = state.item?.coverImage
                titleLabel.text = state.item?.title
                userView.user = state.item?.user
                likeButton.setTitle("\(state.item?.likeCount ?? 0)", for: .normal)
                likeButton.setImage((state.item?.liked ?? false) ?
                    .imageFromColor(.red, size: CGSize(width: 20, height: 20)) :
                        .imageFromColor(.lightGray, size: CGSize(width: 20, height: 20)),
                                    for: .normal)
                var ratio: Double = 1
                if let size = state.item?.coverImage?.size, !size.width.isZero {
                    ratio = size.height / size.width
                }
                imageView.snp.remakeConstraints { make in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(imageView.snp.width).multipliedBy(ratio)
                }
            }
        }
    }

}

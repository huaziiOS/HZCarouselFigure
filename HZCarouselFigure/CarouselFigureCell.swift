//
//  CarouselFigureCell.swift
//  HZCarouselFigure
//
//  Created by 韩兆华 on 2017/7/21.
//  Copyright © 2017年 韩兆华. All rights reserved.
//

import UIKit

class CarouselFigureCell: UICollectionViewCell {
    
    var imageSource: ImageSource = ImageSource.Local(name: "") {
        didSet {
            switch imageSource {
            case let .Local(name: name):
                imageView?.image = UIImage(named: name)
            case let .Network(urlStr: urlStr):
                imageView?.k_setImageWithUrlString(urlString: urlStr, placeholderImageStr: placeholderImage)
            }
        }
    }
    
    private var imageView: UIImageView?
    
    var placeholderImage: String?
    
    var imageContentMode: UIViewContentMode = .scaleToFill {
        didSet {
            imageView?.contentMode = imageContentMode
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setImageView() {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = imageContentMode
        imageView.clipsToBounds = true
        addSubview(imageView)
        self.imageView = imageView
    }
    
}

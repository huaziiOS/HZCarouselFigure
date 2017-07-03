//
//  UIImageViewExtention.swift
//  HZCarouselFigure
//
//  Created by 韩兆华 on 2017/7/3.
//  Copyright © 2017年 韩兆华. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    /**
     图片处理
     本地图片: id.jpg(无http)
     网络图片: http:// 或者 https://
     
     urlString: 图片路径(网络 / 本地)
     placeholderImage: 占位图
     */
    
    public func k_setImageWithUrlString(urlString: String?, placeholderImageStr: String?) {
        let placeholderImage = UIImage(named: placeholderImageStr ?? "")
        if (urlString?.characters.count ?? 0) <= 0 {
           image = placeholderImage
        } else if urlString?.contains("http:") == true || urlString?.contains("https:") == true {
            self.kf.setImage(with: ImageResource(downloadURL: URL(string: urlString!)!), placeholder: placeholderImage)
        }
    }
}

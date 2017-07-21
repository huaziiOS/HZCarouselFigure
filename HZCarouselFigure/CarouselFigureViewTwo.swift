//
//  CarouselFigureViewTwo.swift
//  HZCarouselFigure
//
//  Created by 韩兆华 on 2017/7/4.
//  Copyright © 2017年 韩兆华. All rights reserved.
//

/**
 
 UIScrollView + UIImageView实现无限轮播
 
 实现思路: UIScrollView上放置 左, 中, 右三个UIImageView, 默认只展示中间位置的UIImageView, 然后动态调整UIImageView上应该放置的image, 例如: 刚开始时, 左中右分别放置的是图片数组中最后一张,第0张,第1张图片, 当用户向右滑动时, 此时展示应该是第一张图片,当滑动结束时, 手动将scrollView的偏移量调整为中间位置, 同时调整对应imageView上展示的图片, 此时左中右分别对应的应该是 第0,1,2张图片;
 
 注意: 要求: swift 3.0, 关于网络图片的加载, 我使用了Kingfisher框架, 并对框架的使用进行简单封装一层使用(详见UIImageViewExtention.swift文件), 所以如果你的项目中没有此框架或者有其他的图片加载框架, 修改为你当前使用的框架即可
 */

import UIKit

protocol CarouselFigureViewTwoDelegate: class {
    func imageSelectedAtIndex(index: Int)
}


class CarouselFigureViewTwo: UIView {
    
    /**
     代理
     */
    weak open var delegate: CarouselFigureViewTwoDelegate?
    
    /**
     实现无限轮播的ScrollView
     */
    fileprivate var scrollView: UIScrollView?
    
    /**
     控制页签
     */
    fileprivate var pageControl: UIPageControl?
    
    /**
     是否显示页签
     */
    var isShowPageControl: Bool = true
    
    /**
     一个页签的宽度
     */
    var oneTabWidth: CGFloat = 15.0
    
    /**
     页签当前页颜色
     */
    var currentPageIndicatorTintColor = UIColor.red
    
    /**
     页签未选中颜色
     */
    var pageIndicatorTintColor = UIColor.lightGray
    
    /**
     页签展示位置
     */
    var pageContentMode: PageContentMode = PageContentMode.Left
    
    /**
     图片展示位置枚举值
     */
    enum PageContentMode {
        case Left
        case Center
        case Right
    }
    
    /**
     图片填充样式, 默认是 .scaleToFill
     */
    var imageContentMode: UIViewContentMode = .scaleToFill
    
    /**
     是否开始无限轮播, 默认值为true
     */
    var isEndLessScroll: Bool = true
    
    /**
     无限轮播定时器
     */
    fileprivate var timer: Timer?
    
    /**
     开启自动轮播后, 滚动时间间隔, 默认值为2.0秒
     */
    var timeInterval: Double = 2.0
    
    /**
     UIImageView数组
     */
    fileprivate var imageViewArray = [UIImageView]()
    
    /**
     当前正在展示的图片下标
     */
    fileprivate var currentIndex: Int = 0 {
        didSet {
            if currentIndex < 0 {
                currentIndex = imageBox.imageArray.count - 1
            } else if currentIndex > imageBox.imageArray.count - 1 {
                currentIndex = 0
            }
        }
    }
    
    /**
     占位图
     */
    var placeHolderImage: String?
    
    /**
     网络图片数组
     */
    var networkImageArray: [String]? {
        didSet {
            if ((networkImageArray?.count ?? 0))! > 0 {
                imageBox = ImageBox(imageType: .Network, imageArray: networkImageArray!)
                reloadImageSource()
            }
        }
    }
    
    /**
     本地图片数组
     */
    var localImageArray: [String]? {
        didSet {
            if (localImageArray?.count ?? 0)! > 0 {
                imageBox = ImageBox(imageType: .Local, imageArray: localImageArray!)
                reloadImageSource()
            }
        }
    }
    
    /**
     保存图片
     */
    fileprivate var imageBox: ImageBox!
    
    // 图片类型: 本地 / 网络
    fileprivate enum ImageType {
        case Local
        case Network
    }
    
    // 图片资源
    fileprivate enum ImageSource {
        case Local(name: String)
        case Network(urlStr: String)
    }
    
    /**
     图片处理
     
     */
    fileprivate struct ImageBox {
        
        var imageType: ImageType
        
        var imageArray: [ImageSource]
        
        init(imageType: ImageType, imageArray: [String]) {
            self.imageType = imageType
            self.imageArray = []
            switch imageType {
            case .Local:
                for item in imageArray {
                    self.imageArray.append(ImageSource.Local(name: item))
                }
            case .Network:
                for item in imageArray {
                    self.imageArray.append(ImageSource.Network(urlStr: item))
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        scrollView?.delegate = nil
    }

}

// MARK: - Private Method
extension CarouselFigureViewTwo {
    
    fileprivate func reloadImageSource() {
        
        setScrollView()
        
        setImageViews()
        
        if isShowPageControl {
            setPageControl()
        }
        
        scrollView?.contentOffset = CGPoint(x: self.bounds.width, y: 0)
        pageControl?.currentPage = 0
        
        if isEndLessScroll {
            setTimer()
        }
    }
    
    private func setScrollView() {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.isPagingEnabled = true
        // 解决边缘弹性回弹导致数据展示不完整bug
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: self.bounds.width * 3.0, height: self.bounds.height)
        scrollView.delegate = self as UIScrollViewDelegate
        
        // 轻拍手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        scrollView.addGestureRecognizer(tap)
        
        addSubview(scrollView)
        self.scrollView = scrollView
    }
    
    private func setImageViews() {
        for i in 0 ..< 3 {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i) * self.bounds.width, y: 0, width: self.bounds.width, height: self.bounds.height))
            imageView.contentMode = imageContentMode
            
            var imageSource = imageBox.imageArray.first!
            if i == 0 {
                imageSource = imageBox.imageArray.last!
            } else if i == 2 {
                imageSource = imageBox.imageArray[1]
            }
            
            switch imageSource {
            case let .Local(name: name):
                imageView.image = UIImage(named: name)
            case let .Network(urlStr: urlStr):
                imageView.k_setImageWithUrlString(urlString: urlStr, placeholderImageStr: placeHolderImage ?? "")
            }
            scrollView?.addSubview(imageView)
            imageViewArray.append(imageView)
        }
    }
    
    private func setPageControl() {
        let pageControlWidth = CGFloat(imageBox.imageArray.count) * oneTabWidth
        var x: CGFloat = 20
        switch pageContentMode {
        case .Left:
            break
        case .Center:
            x = (self.bounds.width - pageControlWidth) * 0.5
        case .Right:
            x = self.bounds.width - pageControlWidth - 20
        }
        
        let pageControl = UIPageControl(frame: CGRect(x: x, y: self.bounds.height - 25, width: pageControlWidth, height: 20))
        pageControl.numberOfPages = imageBox.imageArray.count
        pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        addSubview(pageControl)
        self.pageControl = pageControl
    }
    
    fileprivate func setTimer() {
        // 将当前计时器关闭
        self.timer?.invalidate()
        // 创建新的计时器
        let timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        // 将计时器添加到runloop中
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        self.timer = timer
    }
    
    fileprivate func setImage() {
        for i in 0 ..< 3 {
            let imageView = imageViewArray[i]
            var index = currentIndex - 1 + i
            if index < 0 {
                index = imageBox.imageArray.count - 1
            } else if index >= imageBox.imageArray.count {
                index = 0
            }
            
            let imageSource = imageBox.imageArray[index]
            switch imageSource {
            case let .Local(name: name):
                imageView.image = UIImage(named: name)
            case let .Network(urlStr: urlStr):
                imageView.k_setImageWithUrlString(urlString: urlStr, placeholderImageStr: "1")
            }
        }
    }
}

// MARK: - Timer
extension CarouselFigureViewTwo {
    
    @objc fileprivate func timerAction() {
        let index = scrollView!.contentOffset.x / self.bounds.width
        let nextIndex = Int(index) + 1
        scrollView?.setContentOffset(CGPoint(x: CGFloat(nextIndex) * self.bounds.width, y: 0), animated: true)
    }
}

// MARK: - 轻拍手势
extension CarouselFigureViewTwo {
    
    @objc fileprivate func tapAction(sender: UITapGestureRecognizer) {
        if delegate != nil {
            delegate!.imageSelectedAtIndex(index: currentIndex)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension CarouselFigureViewTwo: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / self.bounds.width
        print(index)
//        var currentIndex = (index - 1.0).truncatingRemainder(dividingBy: 3.0) + 0.5
//        print(currentIndex)
//        if currentIndex == 1.0 {
//            currentIndex = 1.0
//        } else if currentIndex == 0 {
//            currentIndex = -1.0
//            self.currentIndex += Int(currentIndex)
//        } else if currentIndex > 0 && currentIndex < 1.0 {
//            currentIndex = 0
//        }
//        self.currentIndex += Int(currentIndex)
//        print(self.currentIndex)
        
        
        if index >= 2 || index <= 0 {
            
            self.currentIndex = index >= 2 ? (self.currentIndex + 1) : (self.currentIndex - 1)
            
            setImage()
            
            scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
            
        }
        
        pageControl?.currentPage = self.currentIndex

    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if isEndLessScroll {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isEndLessScroll {
            setTimer()
        }
    }
}

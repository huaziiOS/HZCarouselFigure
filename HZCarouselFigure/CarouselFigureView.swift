//
//  CarouselFigureView.swift
//  HZCarouselFigure
//
//  Created by 韩兆华 on 2017/7/3.
//  Copyright © 2017年 韩兆华. All rights reserved.
//

/**
 通过UIScrollView + UIImageView 实现无限轮播
 本方案实现思路: 在原图片数组的基础上, 分别在数组开始处插入一张原图片数组的最后一张图片, 末尾处插入原图片数组的第一张图片, 组成一个新的图片数组, 这个新图片数组.count = 原数组.count + 2
 */

import UIKit

protocol CarouselFigureViewDelegate: class {
    func carouselFigureSelectedAtIndex(index: Int)
}

class CarouselFigureView: UIView {
    
    /** 
     代理
     */
    weak open var delegate: CarouselFigureViewDelegate?
    
    /**
     实现无限轮播的ScrollView
     */
    fileprivate var scrollView: UIScrollView!
    
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
                self.imageArray.append(ImageSource.Local(name: imageArray.last!))
                for item in imageArray {
                    self.imageArray.append(ImageSource.Local(name: item))
                }
                self.imageArray.append(ImageSource.Local(name: imageArray.first!))
            case .Network:
                self.imageArray.append(ImageSource.Network(urlStr: imageArray.last!))
                for item in imageArray {
                    self.imageArray.append(ImageSource.Network(urlStr: item))
                }
                self.imageArray.append(ImageSource.Network(urlStr: imageArray.first!))
            }
        }
    }
    

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        scrollView.delegate = nil
    }
}

// MARK: - Private Method
extension CarouselFigureView {
    
    fileprivate func reloadImageSource() {
        
        setScrollView()
        
        addImageViews()
        
        if isShowPageControl {
            setPageControl()
        }
        
        scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
        pageControl?.currentPage = 0
        
        if isEndLessScroll {
            setTimer()
        }
    }
    
    private func setScrollView() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        let width = self.bounds.width * CGFloat(imageBox.imageArray.count)
        scrollView.contentSize = CGSize(width: width, height: self.bounds.height)
        scrollView.delegate = self as UIScrollViewDelegate
        
        // 轻拍手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        scrollView.addGestureRecognizer(tap)
        
        addSubview(scrollView)
        self.scrollView = scrollView
    }

    private func addImageViews() {
        for i in 0 ..< imageBox.imageArray.count {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i) * scrollView.bounds.width, y: 0, width: self.bounds.width, height: self.bounds.height))
            imageView.contentMode = imageContentMode
            let imageSource = imageBox.imageArray[i]
            switch imageSource {
            case let .Local(name: name):
                imageView.image = UIImage(named: name)
            case let .Network(urlStr: urlStr):
                imageView.k_setImageWithUrlString(urlString: urlStr, placeholderImageStr: placeHolderImage ?? "")
            }
            scrollView.addSubview(imageView)
        }
    }
    
    private func setPageControl() {
        let pageControlWidth = CGFloat(imageBox.imageArray.count - 2) * oneTabWidth
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
        pageControl.numberOfPages = imageBox.imageArray.count - 2
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
}

extension CarouselFigureView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / self.bounds.width
        let currentIndex = (index - 1.0).truncatingRemainder(dividingBy: CGFloat(imageBox.imageArray.count - 2)) + 0.5
        pageControl?.currentPage = Int(currentIndex) == (imageBox.imageArray.count - 2) ? 0 : Int(currentIndex)
        if index >= CGFloat(imageBox.imageArray.count - 1) {
            scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
        } else if index <= 0 {
            scrollView.contentOffset = CGPoint(x: CGFloat(imageBox.imageArray.count - 2) * self.bounds.width, y: 0)
        } else if index <= 0.5 { // 此处只是为了在第一张向前滚动到展示最后一张时, pageControl可以及时变化
            pageControl?.currentPage = imageBox.imageArray.count - 2
        }
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

// MARK: - 定时器回调方法
extension CarouselFigureView {
    
    @objc fileprivate func timerAction() {
        let index = scrollView.contentOffset.x / self.bounds.width
        let nextIndex = Int(index) + 1
        scrollView.setContentOffset(CGPoint(x: CGFloat(nextIndex) * self.bounds.width, y: 0), animated: true)
    }
}

// MARK: - 轻拍手势
extension CarouselFigureView {
    
    @objc fileprivate func tapAction(sender: UITapGestureRecognizer) {
        let index = scrollView.contentOffset.x / self.bounds.width
        if delegate != nil {
            delegate!.carouselFigureSelectedAtIndex(index: Int(index))
        }
    }
    
}

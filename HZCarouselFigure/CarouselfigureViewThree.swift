//
//  CarouselfigureViewThree.swift
//  HZCarouselFigure
//
//  Created by 韩兆华 on 2017/7/21.
//  Copyright © 2017年 韩兆华. All rights reserved.
//

/**
 
 本方式通过UICollectionView + cell上放ImageView实现无限轮播
 
 实现思路: 创建足够多的cell(单次浏览时不会很快就滚动到最后一个cell), 然后在cell的imageView上以组为单位放置图片, 这样就造成无限轮播的假象
 
 注意: 由于这种方法需要创建足够多的展示cell, 所以有一定的内存消耗, 但是之所以使用UICollectionView, 就是因为它的重用机制,减少了这种影响.
 
 */

import UIKit

protocol CarouselFigureViewThreeDelegate: class {
    func imageSelectedAtIndex(index: Int)
}

// 图片类型: 本地 / 网络
enum ImageType {
    case Local
    case Network
}

// 图片资源
enum ImageSource {
    case Local(name: String)
    case Network(urlStr: String)
}

class CarouselfigureViewThree: UIView {

    /**
     代理
     */
    weak open var delegate: CarouselFigureViewTwoDelegate?
    
    /**
     实现无限轮播的UICollectionView
     */
    fileprivate var collectionView: UICollectionView?
    
    /**
     cell重用标识
     */
    fileprivate let cellID = "carousefigureCell"
    
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
     真实展示的item数量
     */
    fileprivate var actualItemCount: Int = 0
    
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
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
    }
    
}

// MARK: - Private Method
extension CarouselfigureViewThree {
    
    fileprivate func reloadImageSource() {
        
        setCollectionView()
        
        collectionView?.reloadData()
        
        if isShowPageControl {
            setPageControl()
        }
        
        actualItemCount = imageBox.imageArray.count
        if isEndLessScroll {
            actualItemCount = actualItemCount * 150
            let indexPath = IndexPath(item: actualItemCount / 2, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
            setTimer()
        }
        
        pageControl?.currentPage = 0
    }
    
    private func setCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = self.bounds.size
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CarouselFigureCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
        self.collectionView = collectionView
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
}

// MARK: - Timer Action
extension CarouselfigureViewThree {
    @objc fileprivate func timerAction() {
        let index = collectionView!.contentOffset.x / self.bounds.width
        let nextIndex = Int(index) + 1
        collectionView?.setContentOffset(CGPoint(x: CGFloat(nextIndex) * self.bounds.width, y: 0), animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension CarouselfigureViewThree: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetIndex = scrollView.contentOffset.x / self.bounds.width

        let currentIndex = Int(offsetIndex.truncatingRemainder(dividingBy: CGFloat(self.imageBox!.imageArray.count)) + 0.5)
        
        if Int(offsetIndex) >= actualItemCount {
            
            scrollView.contentOffset = CGPoint(x: self.bounds.width * CGFloat(actualItemCount) / 2, y: 0)
        }
        
        pageControl?.currentPage = currentIndex == imageBox.imageArray.count ? 0 : currentIndex
                
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension CarouselfigureViewThree: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actualItemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CarouselFigureCell
        cell.placeholderImage = placeHolderImage
        cell.imageContentMode = imageContentMode
        let index = indexPath.row % imageBox.imageArray.count
        cell.imageSource = imageBox.imageArray[index]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if delegate != nil {
            delegate?.imageSelectedAtIndex(index: indexPath.row)
        }
    }
}

//
//  ShowVC.swift
//  HZCarouselFigure
//
//  Created by 韩兆华 on 2017/7/21.
//  Copyright © 2017年 韩兆华. All rights reserved.
//

import UIKit

enum ShowType {
    case MethodOne
    case MethodTwo
    case MethodThree
}

class ShowVC: UIViewController {
    
    var showType: ShowType = .MethodOne

    override func viewDidLoad() {
        super.viewDidLoad()

        builtUI()
    }
    
    private func builtUI() {
        switch showType {
        case .MethodOne:
            methodOne()
        case .MethodTwo:
            methodTwo()
        case .MethodThree:
            methodThree()
        }
    }
    
    private func methodOne() {
        // 64是导航栏 + 状态栏高度
        let carouselFigureView = CarouselFigureView(frame: CGRect(x: 0, y: 64, width: view.bounds.width, height: 200))
        carouselFigureView.pageContentMode = .Right
        carouselFigureView.delegate = self
        carouselFigureView.localImageArray = ["1", "2", "3", "4", "5"]
        carouselFigureView.placeHolderImage = "1"
        
        //        carouselFigureView.networkImageArray = ["http://i2.sanwen.net/doc/1608/704-160PQ43458.png", "http://pic1.win4000.com/wallpaper/609*342/32378.jpg", "http://images.shobserver.com/news/news/2017/1/15/b5530166-7598-4129-8ee4-8652408f279f.jpg", "http://www.bz55.com/uploads/allimg/150727/139-150HG44343.jpg", "http://www.iwatch365.com/data/attachment/forum/201307/31/035108jphypuejnoojj5nj.jpg"]
        view.addSubview(carouselFigureView)
    }
    
    private func methodTwo() {
        let carouselViewTwo = CarouselFigureViewTwo(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 200))
        carouselViewTwo.pageContentMode = .Center
        carouselViewTwo.localImageArray = ["5", "4", "3", "2", "1"]
        view.addSubview(carouselViewTwo)
    }
    
    private func methodThree() {
        let carouselViewThree = CarouselfigureViewThree(frame: CGRect(x: 0, y: 200, width: view.bounds.width, height: 200))
        carouselViewThree.pageContentMode = .Left
        carouselViewThree.localImageArray = ["3", "4", "5", "2", "1"]
        view.addSubview(carouselViewThree)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ShowVC: CarouselFigureViewDelegate, CarouselFigureViewTwoDelegate, CarouselFigureViewThreeDelegate {
    func imageSelectedAtIndex(index: Int) {
        print("您点击了第\(index)张图片")
    }
}

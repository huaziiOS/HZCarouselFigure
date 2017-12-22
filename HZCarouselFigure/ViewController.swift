//
//  ViewController.swift
//  HZCarouselFigure
//
//  Created by 韩兆华 on 2017/7/3.
//  Copyright © 2017年 韩兆华. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let showVC = segue.destination as? ShowVC
        let identifier = segue.identifier
        if identifier == "methodOne" {
            showVC?.showType = .MethodOne
        } else if identifier == "methodTwo" {
            showVC?.showType = .MethodTwo
        } else {
            showVC?.showType = .MethodThree
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


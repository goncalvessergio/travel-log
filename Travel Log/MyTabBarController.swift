//
//  MyTabBarController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 11/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        self.delegate = self
    }
    
    // UITabBarDelegate
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 0 {
        } else {
        }
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if viewController.isKindOfClass(MapViewController) {
            let map = tabBarController.viewControllers![1] as! MapViewController
            map.addMarkersToMap()
        }
    }
}

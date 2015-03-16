//
//  MainTabBarController.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/5.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - 成员变量

    @IBOutlet weak var mainTabBar: MainTabBar!

    // MARK: - 系统方法
    override func viewDidLoad() {
        super.viewDidLoad()

        // 添加子控制器
        setupChildrenVc()
        // weak只能修饰可变的变量
        // 防止在闭包中出现循环引用
        weak var weakSelf = self
        mainTabBar.composeButtonClicked = {
            let composeVc = getInitialViewControllerByStoryboardName("Compose")
            weakSelf!.presentViewController(composeVc, animated: true, completion: nil)
        }
    }

    deinit
    {
        println("MainTabBarController 我走了。。。")
    }

    // MARK : - 私有方法
    ///  添加子控制器
    func setupChildrenVc()
    {
        setupOneVc("Home", "首页", "tabbar_home", "tabbar_home_highlighted")
        setupOneVc("Message", "消息", "tabbar_message_center", "tabbar_message_center_highlighted")
        setupOneVc("Discover", "发现", "tabbar_discover", "tabbar_discover_highlighted")
        setupOneVc("Profile", "我", "tabbar_profile", "tabbar_profile_highlighted")
    }

    ///  添加一个控制器
    ///
    ///  :param: name             控制器名称
    ///  :param: title            标题
    ///  :param: image            Normal状态下的图片
    ///  :param: highlightedImage 高亮状态下得图片
    func setupOneVc(name:String, _ title:String, _ image:String, _ highlightedImage:String)
    {
        let vc = getInitialViewControllerByStoryboardName(name)
//        vc.tabBarItem.title = title
        vc.title = title
        vc.tabBarItem.image = UIImage(named: image)
        vc.tabBarItem.selectedImage = UIImage(named: highlightedImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.addChildViewController(vc)

    }
}

///  根据storyboard的名称获取其初始控制器
///
///  :param: sbName storyboard的名称
///
///  :returns: 返回storyboard的初始控制器
func getInitialViewControllerByStoryboardName(sbName:String) -> UIViewController
{
    return UIStoryboard(name: sbName, bundle: nil).instantiateInitialViewController() as! UIViewController
}

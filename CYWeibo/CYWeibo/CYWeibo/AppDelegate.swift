//
//  AppDelegate.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/2.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func testEmoticon()
    {
        let tmp = EmoticonsSection.loadEmoticons()
        for em in tmp
        {
            println(em.name)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {


        // cmd + tab

        // 表情测试
//        testEmoticon()

        let str = "[哈哈][晕][呵呵]"
        printLine()
        println(str.emotionString())

        // Override point for customization after application launch.
        let a = AccessToken()
        println(a.getFilePath())
        if let token = a.loadAccessToken()
        {
            println(token.debugDescription)
            // 设置外观
            setupAppearance()   // TODO: 设置外观的地方尽可能的早！！！  
            // 显示主界面
            showMainPage()
        }
        else
        {
            // 添加监听 通知
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMainPage", name: WB_Login_Successed_Notification, object: nil)
        }
        return true
    }

    // MARK: - 显示主界面
    func showMainPage()
    {
        let mainVc = getInitialViewControllerByStoryboardName("Main")
        window?.rootViewController = mainVc
        window?.makeKeyAndVisible()
    }

    // MARK: - 设置导航条和TabBar的外观
    func setupAppearance()
    {
        // 程序一启动的时候 设置导航栏上的按钮外观
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
    }

    func test()
    {

        let s = SimpleNetwork.sharedInstance
        println("+++++++++++++++  \(s.cachePath!)")
        let urlStrings = ["http://ww1.sinaimg.cn/thumbnail/005xCx3bjw1epgwuum999j30vk0vkaer.jpg",
            "http://ww3.sinaimg.cn/thumbnail/005xCx3bjw1epgwuvyepdj30vk0vkti3.jpg",
            "http://ww2.sinaimg.cn/thumbnail/005xCx3bjw1epgwv0dsa9j30no0vkjyd.jpg"]
        NetworkManager.sharedManager.downloadImages(urlStrings, { (result, error) -> () in

        })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


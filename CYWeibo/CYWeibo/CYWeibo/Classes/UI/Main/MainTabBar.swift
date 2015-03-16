//
//  MainTabBar.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/5.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class MainTabBar: UITabBar {

    // MARK: - 成员变量
    /// “撰写微博”按钮点击回调
    var composeButtonClicked:(() -> ())?

    // MARK: - 系统方法
    override func drawRect(rect: CGRect) {
        // 绘制背景色
        let image = UIImage(named:"tabbar_background")!
        image.drawInRect(rect)
    }


    override func awakeFromNib() {
        // 添加“+”按钮
        addComposeButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        printLine()
        var index = 0
        let width = UIScreen.mainScreen().bounds.size.width
        let height = self.frame.size.height
        let subViewCount = 5
        let w = width / CGFloat(subViewCount)
        let h = height
//        println(self.frame)
        for view in self.subviews as! [UIView]
        {
            if view is UIControl
            {
//                println(view)
                if !(view is UIButton)
                {
                    view.frame = CGRect(x: CGFloat(index) * w, y: 0, width: w, height: h)
                    index++
                    // 把中间那个位置空着
                    if index == 2
                    {
                        index++
                    }
                }
                else  // 调整“撰写微博”按钮的位置
                {
                    view.frame = CGRect(x: 0, y: 0, width: w, height: h)
                    view.center = CGPoint(x: self.center.x, y: h * 0.5)
                }
            }
        }
    }

    // MARK: - 私有方法

    ///  添加撰写微博按钮
    func addComposeButton()
    {
        let composeBtn = UIButton()
        // 设置按钮的背景和前景图片
        composeBtn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: .Normal)
        composeBtn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: .Highlighted)
        composeBtn.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: .Normal)
        composeBtn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: .Highlighted)
        composeBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        // 监听按钮点击事件
        composeBtn.addTarget(self, action: "composeButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(composeBtn)
    }

    func composeButtonClick()
    {
        // 弹出试图控制器
        // 通知  代理  闭包

        if self.composeButtonClicked != nil
        {
            // 回调  弹出控制器的操作应该由控制器完成！
            composeButtonClicked!()
        }
    }

}

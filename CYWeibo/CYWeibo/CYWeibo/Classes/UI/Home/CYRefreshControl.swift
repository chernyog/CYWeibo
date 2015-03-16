//
//  CYRefreshControl.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/10.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class CYRefreshControl: UIRefreshControl {

    /**
        RefreshControl控件的高度是60点
    */
    lazy var refreshView: CYRefreshView = {
        return CYRefreshView.refreshView(isLoading: false)
    }()

    
    override func awakeFromNib() {
        self.addSubview(refreshView)
        // KVO 观察者模式
        self.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
//        self.addObserver(self, forKeyPath: "superview.contentInset", options: NSKeyValueObservingOptions.New, context: nil)
//        self.superview.contentInset
    }

    deinit
    {
        removeObserver(self, forKeyPath: "frame")
        println("CYRefreshControl  我走了")
    }

    /// 是否旋转箭头
    var isRotateTip = false
    /// 是否正在加载
    var isLoding = false
    /// 临界值
    var criticalValue: CGFloat = -50
    /// 记录上一次y变化的值
    var lastValue: CGFloat = 0
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {


        let currentY = self.frame.origin.y
//        println("\(currentY)   \(change)")
        /// 递增
        let isIncreasing = abs(currentY) > abs(lastValue)
        /// 当前y值的绝对值比临界值大
        let isBeggerThanCritical = abs(currentY) > abs(criticalValue)
//        println("是否在递增：\(isIncreasing)")
        if currentY > 0
        {
            return
        }

        if !isLoding && self.refreshing
        {
            refreshView.showLoading()
            isLoding = true
            return
        }

        if !isBeggerThanCritical && !isRotateTip
        {
            println("向下")
            refreshView.rotationTipIcon(true)
            isRotateTip = true
        }
        else if isBeggerThanCritical && isRotateTip
        {
            println("向上")
            refreshView.rotationTipIcon(false)
            isRotateTip = false
        }

//        if isIncreasing && !isBeggerThanCritical
//        {
//            println("向下")
//        }
//        else if isIncreasing && isBeggerThanCritical
//        {
//            println("向上")
//        }
//        else if !isIncreasing && !isBeggerThanCritical
//        {
//            println("向下")
//        }
//        else
//        {
//            println("向上")
//        }

        lastValue = currentY
    }

    override func endRefreshing() {
        // 调用父类方法
        super.endRefreshing()
        println("结束刷新")
        refreshView.stopLoading()
        isLoding = false
    }

}

class CYRefreshView: UIView {

    ////  获取CYRefreshView对象
    ///
    ///  :param: isLoading 是否是加载更多
    ///
    ///  :returns: 返回 CYRefreshView对象
    class func refreshView(isLoading: Bool = false) -> CYRefreshView
    {
        var view = NSBundle.mainBundle().loadNibNamed("CYRefreshView", owner: nil, options: nil).first as! CYRefreshView
        view.tipView.hidden = isLoading
        view.loadingView.hidden = !isLoading
        return view
    }

    // MARK: - 下拉刷新代码

    /// 提示视图
    @IBOutlet weak var tipView: UIView!
    /// 提示图标
    @IBOutlet weak var tipIcon: UIImageView!
    /// 加载视图
    @IBOutlet weak var loadingView: UIView!
    /// 加载图标
    @IBOutlet weak var loadingIcon: UIImageView!

    /// 显示正在加载
    func showLoading()
    {
        tipView.hidden = true;
        loadingView.hidden = false;
        // 添加动画
        setupAnimation()
    }

    func setupAnimation()
    {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = 2 * M_PI
        animation.repeatCount = MAXFLOAT
        animation.duration = 0.5
        loadingIcon.layer.addAnimation(animation, forKey: nil)
    }

    func stopLoading()
    {
        loadingIcon.layer.removeAllAnimations()
        tipView.hidden = false
        loadingView.hidden = true
    }

    func rotationTipIcon(clockWise: Bool)
    {
        let baseValue = 0.01
        var angel = CGFloat(M_PI - baseValue)
        if clockWise
        {
            angel = CGFloat(M_PI + baseValue)
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.tipIcon.transform = CGAffineTransformRotate(self.tipIcon.transform, angel)
        })
    }

    // MARK: - 上拉加载更多代码
    // 由控制器加载下一页数据
    weak var parentView: UITableView?  // 避免循环引用
    var pullData: (() -> ())?
    var isPullLoading: Bool = false

    func addPullDataViewObserver(parentView: UITableView,pullData:(() -> ()))
    {
        self.parentView = parentView
        self.pullData = pullData
        self.parentView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if self.frame.origin.y == 0
        {
            return
        }

        // 看上拉加载视图是否完全露出
        if (parentView!.frame.size.height + parentView!.contentOffset.y) > CGRectGetMaxY(self.frame)
        {
            if !isPullLoading
            {
                isPullLoading = true
                showLoading()
                if pullData != nil
                {
                    pullData!()
                }
            }
        }
    }

    /// 上拉刷新完成
    func pullupFinished() {
        // 重新设置刷新视图的属性
        isPullLoading = false

        // 停止动画
        stopLoading()
    }

    deinit
    {
       println("CYRefreshView  我走了")
    }
    
}

//
//  HomeViewController.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/5.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {

    var statusData: StatusesData?

    /// 行高的缓存
    lazy var rowHeightCache: NSCache? = {
        return NSCache()
    }()

    /// 上拉加载更多视图
    lazy var pullDataView: CYRefreshView = {
        return CYRefreshView.refreshView(isLoading: true)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置UI
        setupUI()

        // 加载数据
        loadData()

        // MARK: 一定要先设置tableFooterView，再加载数据！否则tableFooterView会一直在界面上！（因为他没接受到数据）

    }

    /// 设置UI
    func setupUI()
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        self.tableView.tableFooterView = pullDataView

        weak var weakSelf = self
        pullDataView.addPullDataViewObserver(self.tableView, pullData: { () -> () in
            //            self.pullDataView.isPullLoading = false
            if let maxId = weakSelf?.statusData?.statuses?.last?.id
            {
                weakSelf?.loadData(maxId - 1)
            }
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    deinit {
        // 主动释放加载刷新视图对tableView的观察
        println("Home试图控制器走了")
        tableView.removeObserver(pullDataView, forKeyPath: "contentOffset")
    }

    @IBAction func loadData()
    {
        loadData(0)
    }
    func loadData(maxId: Int)
    {
        // 主动开始加载数据
        weak var weakSelf = self
        weakSelf?.refreshControl?.beginRefreshing()
        pullDataView.showLoading()  // 转圈
        StatusesData.loadStatus(maxId: maxId) { (data, error) -> () in
            weakSelf?.refreshControl?.endRefreshing()
            if error != nil {
                SVProgressHUD.showInfoWithStatus("你的网络不给力")
                return
            }
            if data != nil {
                if maxId == 0  // 下拉刷新
                {
                    // 刷新表格数据
                    weakSelf?.statusData = data
                    weakSelf?.tableView.reloadData()
                }
                else  // 上拉加载更多
                {
                    println("加载到了新数据！")
                    // 拼接数据，数组的拼接
                    let list = weakSelf!.statusData!.statuses! + data!.statuses!
                    weakSelf!.statusData?.statuses = list

                    weakSelf?.tableView.reloadData()

                    // 重新设置刷新视图的属性
                    weakSelf?.pullDataView.pullupFinished()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statusData?.statuses?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 获取模型
        let status = self.statusData!.statuses![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusCell.cellIdentifier(status), forIndexPath: indexPath) as! StatusCell

        weak var weakSelf = self
        if cell.photoDidSelected == nil
        {
            cell.photoDidSelected = {(status: Status, photoIndex: Int) -> ()in
                // 弹出图片浏览器控制器
                let vc = PhotoBrowserViewController.PhotoBrowserController()
                vc.urls = status.largeUrls
                vc.selectedIndex = photoIndex
                weakSelf?.presentViewController(vc, animated: true, completion: nil)
            }
        }
        // 设置属性
        cell.status = status
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate
{

    // 行高的处理
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let status = self.statusData!.statuses![indexPath.item]
        if let height = rowHeightCache?.objectForKey("\(status.id)") as? NSNumber
        {
            println("从缓存中取得行高 height=\(height)")
            return CGFloat(height)
        }
        else
        {
            // 提示：查询可重用cell不要使用 indexPath
            let cell = tableView.dequeueReusableCellWithIdentifier(StatusCell.cellIdentifier(status)) as! StatusCell
            let height = cell.cellHeight(status)
            rowHeightCache?.setObject(height, forKey: "\(status.id)")
            println("计算行高 height=\(height)")
            return height;
        }
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}

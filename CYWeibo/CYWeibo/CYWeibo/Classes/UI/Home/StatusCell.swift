//
//  StatusCell.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/6.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class StatusCell: UITableViewCell {

    // MARK: - 控件列表
    /// 头像
    @IBOutlet weak var iconImageView: UIImageView!
    /// 姓名
    @IBOutlet weak var nameLabel: UILabel!
    ///  会员图标
    @IBOutlet weak var memberImageView: UIImageView!
    /// 认证图标
    @IBOutlet weak var vipImageView: UIImageView!
    /// 微博发表时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 微博来源
    @IBOutlet weak var sourceLabel: UILabel!
    /// 微博正文
    @IBOutlet weak var contentLabel: UILabel!
    /// 微博配图
    @IBOutlet weak var pictureView: UICollectionView!
    /// 配图视图的布局
    @IBOutlet weak var pictureLayout: UICollectionViewFlowLayout!
    /// 配图视图的宽
    @IBOutlet weak var pictureViewWidth: NSLayoutConstraint!
    /// 配图视图的高
    @IBOutlet weak var pictureViewHeight: NSLayoutConstraint!
    /// 底部的工具条
    @IBOutlet weak var bottomView: UIView!
    /// 转发微博文字
    @IBOutlet weak var forwardContentLabel: UILabel!




    // MARK: - 成员变量
    /// 微博模型 - 设置微博数据
    var status: Status? {
        didSet{

            self.nameLabel.text = status!.user!.name
            self.timeLabel.text = status!.created_at
            self.sourceLabel.text = status!.source?.getHrefText()
//            self.contentLabel.text = status!.text
            self.contentLabel.attributedText = status!.text?.emotionString() ?? NSAttributedString(string: status!.text ?? "")

            if let iconUrl = status?.user?.profile_image_url
            {
                NetworkManager.sharedManager.requestImage(iconUrl) { (result, error) -> () in
                    if let image = result as? UIImage {
                        self.iconImageView.image = image
                    }
                }
            }

            // 计算微博配图的尺寸
            let result = self.calcPictureViewSize(status!)
            self.pictureLayout.itemSize = result.itemSize
            self.pictureViewWidth.constant = result.viewSize.width
            self.pictureViewHeight.constant = result.viewSize.height
            // 强制刷新界面
            self.pictureView.reloadData()

            // 设置转发微博文字
            if status?.retweeted_status != nil {
                forwardContentLabel.text = status!.retweeted_status!.user!.name! + ":" + status!.retweeted_status!.text!
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
        self.forwardContentLabel?.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
    }

    ///  计算微博配图的尺寸
    ///
    ///  :param: status 微博实体
    ///
    ///  :returns: (itemSize,viewSize)
    func calcPictureViewSize(status: Status) -> (itemSize: CGSize, viewSize: CGSize)
    {
        let defaultWH: CGFloat = 90
        // 默认的图片大小
        var itemSize = CGSize(width: defaultWH, height: defaultWH)
        // 默认PictureView大小
        var viewSize = CGSizeZero
        // 计算微博配图的个数
        var count = status.pictureUrls?.count ?? 0
        // 图片间的间距
        let margin: CGFloat = 10

        if count == 0
        {
            return (itemSize, viewSize)
        }
        if count == 1
        {
            // 如果只有一张图，则按照默认的尺寸显示
            let path = NetworkManager.sharedManager.fullImageCachePathByMD5(status.pictureUrls![0].thumbnail_pic!)
            if let image = UIImage(contentsOfFile: path)
            {
                return (image.size, image.size)
            }
            else
            {
                return (itemSize, viewSize)
            }
            
        }

        if count == 4
        {
            viewSize = CGSize(width: defaultWH * 2, height: defaultWH * 2)
            return (itemSize, viewSize)
        }
        else
        {
            // 行下标
            let row = (count - 1) / 3
            viewSize = CGSize(width: defaultWH * 3 + margin * 2, height: defaultWH * (CGFloat(row) + 1) + margin * CGFloat(row))
        }
        return (itemSize, viewSize)
    }

    ///  返回可重用标识符
    class func cellIdentifier(status: Status) -> String {
        if status.retweeted_status != nil {
            // 转发微博
            return "ForwardCell"
        } else {
            // 原创微博
            return "HomeCell"
        }
    }

    func cellHeight(status: Status) -> CGFloat
    {
        // 设置微博数据
        self.status = status
        // 强制刷新布局
        layoutIfNeeded()
        // 返回cell的高度
        return CGRectGetMaxY(self.bottomView.frame)
    }

    /// 选中图片的闭包回调
    var photoDidSelected: ((status: Status, photoIndex: Int) -> ())?
}

extension StatusCell: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 配图的数量
//        println("配图的数量 count=\(status?.pictureUrls?.count)")
        return status?.pictureUrls?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureCell", forIndexPath: indexPath) as! PictureCell

        // 设置配图的图像路径
        cell.urlString = status!.pictureUrls![indexPath.item].thumbnail_pic

        return cell
    }

    // 选中行事件
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.photoDidSelected != nil
        {
            self.photoDidSelected!(status: status!, photoIndex: indexPath.item)
        }
    }
}

///  配图cell
class PictureCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    /// 图像的 url 字符串
    var urlString: String? {
        didSet {
            // 1. 图像缓存路径
            let path = NetworkManager.sharedManager.fullImageCachePathByMD5(urlString!)
//            println("path=\(path)")
            // 2. 实例化图像
            let image = UIImage(contentsOfFile: path)

            imageView.image = image
        }
    }
}


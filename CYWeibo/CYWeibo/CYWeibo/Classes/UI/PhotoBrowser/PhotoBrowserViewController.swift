//
//  PhotoBrowserViewController.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/8.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {

    /// 图片的 URL 数组
    var urls: [String]?
    /// 选中照片的索引
    var selectedIndex: Int = 0

    @IBOutlet weak var photoView: UICollectionView!

    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    /**
    1. loadView -> 创建视图层次结构，纯代码开发替代 storyboard & xib
    2. viewDidLoad -> 视图加载完成，只是把视图元件加载完成，还没有开始布局
    不要设置关于 frame 之类的属性！
    3. viewWillAppear -> 视图将要出现
    4. viewWillLayoutSubviews —> 视图将要布局子视图，苹果建议设置界面布局属性
    5. view 的 layoutSubviews 方法，视图和所有子视图布局
    6. viewDidLayoutSubviews -> 视图&所有子视图布局完成
    7. viewDidAppear -> 视图已经出现
    */
    override func viewWillLayoutSubviews() {
        // 设置布局
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        photoView.pagingEnabled = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let indexPath = NSIndexPath(forItem: selectedIndex, inSection: 0)
        photoView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
    }

    ///  类方法  返回PhotoBrowserController对象
    class func PhotoBrowserController() -> PhotoBrowserViewController {
        return UIStoryboard(name: "PhotoBrowser", bundle: nil).instantiateInitialViewController() as! PhotoBrowserViewController
    }

    // MARK: - 响应用户点击按钮事件
    
    @IBAction func cancelButtonClick(sender: UIButton)
    {
        if SVProgressHUD.isVisible()
        {
            SVProgressHUD.dismiss()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonClick(sender: UIButton)
    {
        if SVProgressHUD.isVisible()
        {
            SVProgressHUD.dismiss()
        }
        // 获取image
        if let indexPath = self.photoView.indexPathsForVisibleItems().first as? NSIndexPath
        {
            // 根据 indexPath 获取 cell
            let cell = self.photoView.cellForItemAtIndexPath(indexPath) as! PhotoCell
            if let image = cell.imageView?.image
            {
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
            else
            {
                SVProgressHUD.showInfoWithStatus("请先选择图片后再保存！")
            }
        }
    }

    // 保存图片的回调
//    - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    func image(image: UIImage, didFinishSavingWithError error:NSError?, contextInfo: AnyObject)
    {
        if error != nil {
            SVProgressHUD.showInfoWithStatus("保存出错")
        } else {
            SVProgressHUD.showInfoWithStatus("保存成功")
        }
    }

}

// MARK: - UICollectionViewDataSource
extension PhotoBrowserViewController: UICollectionViewDataSource
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.backgroundColor = UIColor(red: getRandomColor(), green: getRandomColor(), blue: getRandomColor(), alpha: 1.0)
        cell.urlString = self.urls![indexPath.item]
        return cell
    }

    ///  获取随机颜色
    private func getRandomColor() -> CGFloat
    {
        return CGFloat(arc4random_uniform(256)) / 255.0
    }
}

class PhotoCell: UICollectionViewCell
{
    /// 单张图片缩放的滚动视图
    var scrollView: UIScrollView?
    /// 显示图像的图像视图
    var imageView: UIImageView?

    /// 是否是短图
    var isShortImage = false

    var urlString:String? {
        didSet{
            println("urlString = \(urlString!)")
            SVProgressHUD.show()
            NetworkManager.sharedManager.requestImage(urlString!, { (result, error) -> () in
                if let image = result as? UIImage
                {
                    self.setupImageView(image)
                    SVProgressHUD.dismiss()
                }
            })
        }

    }

    func setupImageView(image: UIImage)
    {
        scrollView?.contentInset = UIEdgeInsetsZero
        // 以scrollView的宽为基准  等比缩放
        let targetW = self.scrollView!.frame.size.width
        let targetH = (targetW * image.size.height) / image.size.width
        let rect = CGRectMake(0, 0, targetW, targetH)
        imageView?.frame = rect
        imageView?.image = image
        if targetH < scrollView!.frame.size.height  // 短图
        {
            println("短图  \(rect.size)   \(image.size)")
            // 垂直居中
            let y = (scrollView!.frame.size.height - targetH) * 0.5
            scrollView?.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
            isShortImage = true
        }
        else
        {
            println("长图  \(rect.size)   \(image.size)")
            scrollView?.contentSize = rect.size
            isShortImage = false
        }
    }

    override func awakeFromNib() {
        printLine()

        // cell 中添加scrollView控件
        scrollView = UIScrollView()
        scrollView!.minimumZoomScale = 0.5
        scrollView!.maximumZoomScale = 2.0
        scrollView?.delegate = self
        self.addSubview(scrollView!)

        // scrollView中添加ImageView
        imageView = UIImageView()
        scrollView!.addSubview(imageView!)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView!.frame = self.bounds
    }


}

// MARK: - UIScrollViewDelegate
extension PhotoCell: UIScrollViewDelegate
{
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView!
    }

    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        // 让图片垂直居中
        if isShortImage
        {
            let y = (frame.size.height - imageView!.frame.size.height) * 0.5
            let x = (frame.size.width - imageView!.frame.size.width) * 0.5
//            println("\(frame.size)   \(imageView!.frame)  \(scale)  x=\(x)  y=\(y)")
            scrollView.contentInset = UIEdgeInsetsMake(y, x, 0, 0)
        }

    }

}


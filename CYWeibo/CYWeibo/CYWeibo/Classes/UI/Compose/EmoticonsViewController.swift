//
//  EmoticonsViewController.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/13.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class EmoticonsViewController: UIViewController {

    /// 代理对象    一定要是weak！！！
    weak var delegate: EmoticonsViewControllerDelegate?

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    /// 表情符号分组数组，每一个分组包含21个表情
    lazy var emoticonSection: [EmoticonsSection]? = {
        return EmoticonsSection.loadEmoticons()
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }

    /// 设置布局
    private func setupLayout()
    {
        // 设置collectionView的外观
        let margin: CGFloat = 10
        let row: CGFloat = 3
        let col: CGFloat = 7
        let totalWidth = self.collectionView.bounds.size.width
        let itemWH = (totalWidth - margin * (col + 1)) / col
        layout.itemSize = CGSizeMake(itemWH, itemWH)
        layout.minimumInteritemSpacing = margin
        layout.minimumLineSpacing = margin
        // 分组间距
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        collectionView.pagingEnabled = true
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }


    @IBAction func recentlyButtonClick(sender: UIBarButtonItem) {
    }

    
    @IBAction func defaultButtonClick(sender: UIBarButtonItem) {
    }

    @IBAction func emojiButtonClick(sender: UIBarButtonItem)
    {
        for em in emoticonSection!
        {
            println(em.name)
        }
    }

    @IBAction func lxhButtonClick(sender: UIBarButtonItem) {
    }

}

// MARK: - EmoticonsViewControllerDelegate 协议
protocol EmoticonsViewControllerDelegate: NSObjectProtocol
{
    /// 表情选中事件
    func emoticonsViewDidSelectEmoticon(vc: EmoticonsViewController, emoticon: Emoticon)
}



extension EmoticonsViewController: UICollectionViewDataSource, UICollectionViewDelegate
{

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.emoticonsViewDidSelectEmoticon(self, emoticon: emoticonSection![indexPath.section].emoticons[indexPath.item])
    }


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return emoticonSection?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoticonSection![section].emoticons.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmoticonCell", forIndexPath: indexPath) as! EmoticonCell
//        cell.backgroundColor = UIColor(red: getRandomColor(), green: getRandomColor(), blue: getRandomColor(), alpha: 1.0)
        cell.emoticon = emoticonSection![indexPath.section].emoticons[indexPath.item]
        return cell
    }

    ///  获取随机颜色
    private func getRandomColor() -> CGFloat
    {
        return CGFloat(arc4random_uniform(256)) / 255.0
    }


}

class EmoticonCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var emojiLabel: UILabel!
    var emoticon: Emoticon?{
        didSet{
            // 设置头像
            if let path = emoticon?.imagePath
            {
                imageView.image = UIImage(contentsOfFile: path)
            }
            else
            {
                imageView.image = nil
            }
            emojiLabel.text = emoticon?.emoji

            if emoticon!.isDeleteButton
            {
                imageView.image = UIImage(named: "compose_emotion_delete_highlighted")
            }
        }
    }
}

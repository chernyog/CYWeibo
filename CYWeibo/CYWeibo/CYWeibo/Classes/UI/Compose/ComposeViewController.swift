//
//  ComposeViewController.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/5.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {


    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var toobarBottomConstraint: NSLayoutConstraint!

    lazy var placeholderLabel: UILabel = {
        var label = UILabel()
        // 设置Label的属性
        label.text = "分享新鲜事..."
        label.font = UIFont.systemFontOfSize(CGFloat(16))
        return label
    }()


    lazy var emoticonsVC: EmoticonsViewController = {
        let vc = getInitialViewControllerByStoryboardName("Emoticons") as! EmoticonsViewController
        vc.delegate = self
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.addSubview(placeholderLabel)
        textView.becomeFirstResponder()

        // 让textView支持滚动
        textView.alwaysBounceVertical = true

        // 监听键盘弹出事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)

        self.addChildViewController(emoticonsVC)
    }

    func keyboardFrameChanged(notification: NSNotification)
    {
//        println(notification)
        var height: CGFloat = 0
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        if notification.name == UIKeyboardWillChangeFrameNotification
        {
            let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            height = rect.size.height
            self.toobarBottomConstraint.constant = height
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        else
        {
            self.toobarBottomConstraint.constant = height
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 添加占位Label
        placeholderLabel.frame = CGRectMake(5, 8, 0, 0)
        placeholderLabel.sizeToFit()
    }

    ///  响应取消按钮点击事件
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        // 关闭键盘
        self.textView.resignFirstResponder()
        // 注销控制器
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /// 响应发送按钮点击事件
    @IBAction func send(sender: UIBarButtonItem)
    {
        let urlString = "https://api.weibo.com/2/statuses/update.json"
        let a = AccessToken()
        if let token = a.loadAccessToken()?.access_token {
            let params = ["access_token": token,
                "status": fullText()]

            let net = NetworkManager.sharedManager
            // 重点提示：params中一定都要确保有值，否则会提示 .POST 不正确！
            net.requestJSON(.POST, urlString, params) { (result, error) -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
                CYStatusBarHUD.showSuccess("微博发送成功！")
            }
        }
    }

    /// 响应用户点击 表情 按钮事件
    @IBAction func selectEmote(sender: UIButton)
    {
        self.textView.resignFirstResponder()
        // 弹出表情键盘
        println("\(self.textView.inputView)")

        if self.textView.inputView == nil
        {
            self.textView.inputView = self.emoticonsVC.view
        }
        else
        {
            self.textView.inputView = nil
        }
        self.textView.becomeFirstResponder()
    }

    func fullText() -> String
    {
        var result = String()

        textView.attributedText.enumerateAttributesInRange(NSMakeRange(0, textView.attributedText.length), options: NSAttributedStringEnumerationOptions.allZeros) { (dict, range, _) -> Void in
            if let attachment = dict["NSAttachment"] as? EmoteTextAttachment
            {
                // 图片
                result += attachment.emoteString!
            }
            else
            {
                result += (self.textView.attributedText.string as NSString).substringWithRange(range)
            }
        }
        return result
    }
}

extension ComposeViewController: UITextViewDelegate
{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        println("\(textView.text)")
        let attrTextLength = (fullText() as NSString).length
        let textLength = (text as NSString).length
        println("attrTextLength = \(attrTextLength)")
//        if textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 140
//        {
//            return false
//        }
//        println("\(attrTextLength)    \(textLength)   \(text)")
        return (attrTextLength + textLength) <= 140
    }

    func textViewDidChange(textView: UITextView) {
        let textRange = NSMakeRange(0, self.textView.attributedText.length)
        self.textView.attributedText.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions.allZeros) { (dict, range, _) -> Void in

        }

        println("\(textView.text!)")
        sendButton.enabled = !textView.text.isEmpty
        placeholderLabel.hidden = !textView.text.isEmpty
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}

extension ComposeViewController: EmoticonsViewControllerDelegate
{
    func emoticonsViewDidSelectEmoticon(vc: EmoticonsViewController, emoticon: Emoticon) {
        // 判断用户点击的是否是删除
        if emoticon.isDeleteButton
        {
            // 删除一个字符
            textView.deleteBackward()
            return
        }

        var text: String?
        if emoticon.chs != nil
        {
            text = emoticon.chs!
        }
        else if emoticon.emoji != nil
        {
            text = emoticon.emoji!
        }

        if text == nil
        {
            return
        }
        if textView(textView, shouldChangeTextInRange: textView.selectedRange, replacementText: text!)
        {
            if emoticon.chs != nil
            {
                // 生成 attributedString
                let height: CGFloat = self.textView.font.lineHeight
                let attrString = EmoteTextAttachment.getAttributedString(emoticon, height: height)

                // 替换字符串
                var mutableAttrStr = NSMutableAttributedString(attributedString: self.textView.attributedText)
                mutableAttrStr.replaceCharactersInRange(textView.selectedRange, withAttributedString: attrString)

                // 设置所有文本的属性
                let range = NSMakeRange(0, mutableAttrStr.length)
                mutableAttrStr.addAttribute(NSFontAttributeName, value: textView.font, range: range)

                // 记录当前光标的位置
                let location = textView.selectedRange.location

                // 赋值文本
                textView.attributedText = mutableAttrStr

                // 移动光标
                textView.selectedRange = NSMakeRange(location + 1, 0)


                textViewDidChange(self.textView)

            }
            else if emoticon.emoji != nil
            {
                textView.replaceRange(textView.selectedTextRange!, withText: text!)
            }
        }
    }
}

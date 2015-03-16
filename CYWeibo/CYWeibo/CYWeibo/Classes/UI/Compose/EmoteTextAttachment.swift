//
//  EmoteTextAttachment.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/14.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class EmoteTextAttachment: NSTextAttachment {

    /// 表情对应的文本
    var emoteString: String?

    class func getAttributedString(emoticon: Emoticon, height: CGFloat) -> NSAttributedString
    {
        // 生成 attributedString
        let attachment = EmoteTextAttachment()
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        attachment.bounds = CGRectMake(0, -4, height, height)
        attachment.emoteString = emoticon.chs
        return NSAttributedString(attachment: attachment)
    }

}

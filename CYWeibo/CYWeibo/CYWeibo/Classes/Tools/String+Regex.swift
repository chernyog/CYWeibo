//
//  String+Regex.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/14.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import Foundation

extension String
{
    ///  获取a标签的文本
    ///
    ///  :returns:
    func getHrefText() -> String?
    {
        // <a href="baidu.com">百度一下，你就知道</a>
        let pattern = "<a.*?>(.*?)</a>"
        /*
        CaseInsensitive: 不区分大小写
        AllowCommentsAndWhitespace:
        IgnoreMetacharacters:
        DotMatchesLineSeparators:使用 . 可以匹配换行符
        AnchorsMatchLines:
        UseUnixLineSeparators:
        UseUnicodeWordBoundaries:
        */

        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive | NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        println(regex)
        var aaa: ObjCBool = false
        // 提示：不要直接使用 String.length，包含UNICODE的编码长度，会出现数组越界
        var length = (self as NSString).length

//        regex?.enumerateMatchesInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, length), usingBlock: { (result, flag, aaa) -> Void in
//            printLine()
//            println("\(result)  \(flag)  \(aaa)")
//
//        })

        // 2. 匹配文字
        // firstMatchInString 在字符串中查找第一个匹配的内容
        // rangeAtIndex 函数是使用正则最重要的函数 -> 从 result 中获取到匹配文字的 range
        // index == 0，取出与 pattern 刚好匹配的内容
        // index == 1，取出第一个()中要匹配的内容
        // index 可以依次递增，对于复杂字符串过滤，可以使用多几个 ()
        if let result = regex?.firstMatchInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, length))
        {
            let aString = self as NSString
            println(result.rangeAtIndex(0))
            println(result.rangeAtIndex(1))
            println("count=\(result.numberOfRanges)")
            return aString.substringWithRange(result.rangeAtIndex(1))
        }
        return nil
    }

    func emotionString() -> NSAttributedString?
    {
        let pattern = "\\[(.*?)\\]"
        let text = self as NSString
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive | NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)!
        let checkingResults = regex.matchesInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, text.length)) as! [NSTextCheckingResult]
        var attrString = NSMutableAttributedString(string: self)

        // 倒序遍历，防止前面的被替换之后，导致字符串的长度发生变化！
        for var index = checkingResults.count - 1; index >= 0; index--
        {
            let checkingResult = checkingResults[index]
            let range = checkingResult.rangeAtIndex(0)
//            println(text.substringWithRange(range))
            // 获取文本
            let str = text.substringWithRange(range)
            // 根据文本，获取指定的表情
            if let emo = emotion(str)
            {
                if emo.png != nil
                {
                    // 替换文字
                    let tmpStr = EmoteTextAttachment.getAttributedString(emo, height: 18)
                    attrString.replaceCharactersInRange(range, withAttributedString: tmpStr)
                }
            }
        }

//        for checkingResult in checkingResults
//        {
//            let range = checkingResult.rangeAtIndex(0)
//            println("\(text)  \(range)")
//            // 获取文本
//            let str = text.substringWithRange(range)
//            // 根据文本，获取指定的表情
//            if let emo = emotion(str)
//            {
//                if emo.png != nil
//                {
//                    // 替换文字
//                    let tmpStr = EmoteTextAttachment.getAttributedString(emo, height: 18)
//                    attrString.replaceCharactersInRange(range, withAttributedString: tmpStr)
//                }
//            }
//        }

        return attrString
    }

    private func emotion(str: String) -> Emoticon?
    {
        let emoticons = EmoticonList.sharedInstance.emoticons

        println(emoticons.count)
        for emo in emoticons
        {
            println(emo.code)
        }

        for emo in emoticons
        {
            if emo.chs == str
            {
                return emo
            }
        }
        return nil
    }
}
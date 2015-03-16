//
//  Emoticons.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/13.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import Foundation

///  表情集合类  存储所有的表情
class EmoticonList {

    private static let instance = EmoticonList()
    /// 单例
    class var sharedInstance: EmoticonList{
        return instance
    }

    var emoticons: [Emoticon]
    init(){
        emoticons = [Emoticon]()
        let sections = EmoticonsSection.loadEmoticons()
        for section in sections
        {
//            println("===========> name=\(section.name)")
            if !(section.name == "Emoji")
            {
                emoticons += section.emoticons
            }
        }
    }

}

class EmoticonsSection {
    /// 平时定义对象属性的时候，都是使用可选类型 ?
    /// 原因：没有构造函数给对象属性设置初始数值
    /// 分组名称
    var name: String
    /// 类型
    var type: String
    /// 路径
    var path: String
    /// 表情符号的数组(每一个 section中应该包含21个表情符号，界面处理是最方便的)
    /// 其中21个表情符号中，最后一个删除(就不能使用plist中的数据)
    var emoticons: [Emoticon]

    /// 使用字典实例化对象
    /// 构造函数，能够给对象直接设置初始数值，凡事设置过的属性，都可以是必选项
    /// 在构造函数中，不需要 super，直接给属性分配空间&初始化
    init(dict: NSDictionary) {
        name = dict["emoticon_group_name"] as! String
        type = dict["emoticon_group_type"] as! String
        path = dict["emoticon_group_path"] as! String
        emoticons = [Emoticon]()
    }

    class func loadEmoticons() -> [EmoticonsSection]
    {
        let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/emoticons.plist")
        var array = NSArray(contentsOfFile: path)!
//        println("\(array)")
        // 按照type字段对数组进行排序
        array = array.sortedArrayUsingComparator({ (dict1, dict2) -> NSComparisonResult in
            let type1 = dict1["emoticon_group_type"] as! String
            let type2 = dict2["emoticon_group_type"] as! String
            return type1.compare(type2)
        })
        var result = [EmoticonsSection]()
        for dict in array as! [NSDictionary]
        {
            result += loadEmoticons(dict)
        }
        return result
    }

    private class func loadEmoticons(dict: NSDictionary) -> [EmoticonsSection]
    {
        let emoticon_group_path = dict["emoticon_group_path"] as! String

        // 加载不同分组下的表情
        let group_path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/\(emoticon_group_path)/info.plist")
        let infoDict = NSDictionary(contentsOfFile: group_path)!
        let array = infoDict["emoticon_group_emoticons"] as! NSArray
//        println("\(array)")
        return loadEmoticons(dict, array: array)
    }

    private class func loadEmoticons(dict: NSDictionary, array: NSArray) -> [EmoticonsSection]
    {

        var result = [EmoticonsSection]()
        // 每个分组20个常规表情 1个“删除”表情
        let baseCount = 20
        // 每个类别下表情个数
        let objCount = ceil(CGFloat(array.count) / CGFloat(baseCount))  // 天花板函数  向上取整
        for i in 0..<Int(objCount)
        {
            var emotionSection = EmoticonsSection(dict: dict)
            // 内部表情
            for j in 0..<20
            {
                let index = j + i * baseCount
                var dict: NSDictionary? = nil
                if index < array.count
                {
                    dict = array[index] as? NSDictionary
                }
                let em = Emoticon(dict: dict, path: emotionSection.path)
                em.isDeleteButton = false
                emotionSection.emoticons.append(em)
            }
            // 删除按钮
            let em = Emoticon(dict: nil, path: nil)
            em.isDeleteButton  = true
            emotionSection.emoticons.append(em)
            result.append(emotionSection)
        }
        return result
    }

}

/// 表情符号类
class Emoticon {
    /// emoji 的16进制字符串
    var code: String?
    /// emoji 字符串
    var emoji: String?
    /// 类型
    var type: String?
    /// 表情符号的文本 - 发送给服务器的文本
    var chs: String?
    /// 表情符号的图片 - 本地做图文混排使用的图片
    var png: String?
    /// 图像的完整路径
    var imagePath: String?
    /// 标记 是否是删除按钮
    var isDeleteButton = false

    init(dict: NSDictionary?, path: String?) {
        code = dict?["code"] as? String
        type = dict?["type"] as? String
        chs = dict?["chs"] as? String
        png = dict?["png"] as? String

        if path != nil && png != nil {
            imagePath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/\(path!)/\(png!)")
        }

        // 计算 emoji
        if code != nil {
            let scanner = NSScanner(string: code!)
            // 提示：如果要传递指针，不能使用 let，var 才能修改数值
            var value: UInt32 = 0
            scanner.scanHexInt(&value)
            emoji = "\(Character(UnicodeScalar(value)))"
        }
    }
}
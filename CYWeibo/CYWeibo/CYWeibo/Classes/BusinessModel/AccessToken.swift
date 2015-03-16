//
//  AccessToken.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/4.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

class AccessToken: NSObject, DebugPrintable, NSCoding{

    ///  用于调用access_token，接口获取授权后的access token。
    var access_token:String?

    ///  access_token的生命周期，单位是秒数。
    var expires_in:NSNumber?{
        didSet {
            expiresDate = NSDate(timeIntervalSinceNow: expires_in as! Double)
            println("过期时间： \(expiresDate!)")
        }
    }

    ///  access_token的生命周期（该参数即将废弃，开发者请使用expires_in）。
    var remind_in:NSNumber?

    ///  当前授权用户的UID。
    var uid:Int = 0

    /// 过期日期
    var expiresDate:NSDate?

    /// 是否过期
    var isExpires:Bool {
        return expiresDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }

    /*
    enum NSComparisonResult : Int {
    case OrderedAscending    // ASC   升序
    case OrderedSame         //
    case OrderedDescending   // DESC  降序
    }
    */

    override var debugDescription: String {
        var dict = self.dictionaryWithValuesForKeys(["access_token","expires_in","expiresDate","uid","remind_in"])
        return "\(dict)"
    }

    override init(){super.init()}

    ///  从沙盒获取AccessToken
    ///
    ///  :returns: 返回AccessToken对象
    func loadAccessToken() -> AccessToken?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(getFilePath()) as? AccessToken
    }

    ///  保存AccessToken
    func saveAccessToken()
    {
        NSKeyedArchiver.archiveRootObject(self, toFile: getFilePath())
    }

    ///  获取沙盒文件路径
    ///
    ///  :returns: 返回文件路径
    func getFilePath() -> String
    {
        var docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last as! String
        var filePath = docPath.stringByAppendingPathComponent("CYWeibo_AccessToken.plist")
        return filePath
    }

    // 通过KVC 字典转模型
    init(dict: NSDictionary) {
        super.init()
        self.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject])
    }

    // MARK: - 归档 & 解档   如果不指定key，它默认以属性名作为key
    ///  归档
    func encodeWithCoder(encoder: NSCoder)
    {
        encoder.encodeObject(access_token, forKey:"access_token")
        encoder.encodeObject(expires_in, forKey: "expires_in")
        encoder.encodeObject(remind_in, forKey: "remind_in")
        encoder.encodeBool(isExpires, forKey: "isExpires")
        encoder.encodeObject(expiresDate, forKey: "expiresDate")
        encoder.encodeInteger(uid, forKey: "uid")
    }

    ///  解档
    ///  这个方法不能写在extension中，因为分类不能有存储能力  而这个方法是返回当前对象
    required init(coder decoder: NSCoder)
    {
        access_token = decoder.decodeObjectForKey("access_token") as? String
        expires_in = decoder.decodeObjectForKey("expires_in") as? NSNumber
        remind_in = decoder.decodeObjectForKey("remind_in") as? NSNumber
        // 这里的isExpires 没有存储功能，相当于一个(get)函数
//        isExpires = decoder.decodeBoolForKey("isExpires")
        expiresDate = decoder.decodeObjectForKey("expiresDate") as? NSDate
        uid = decoder.decodeIntegerForKey("uid")
        // TODO:
    }

}

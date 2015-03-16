//
//  DictModel4Swift.swift
//  DictModel4Swift
//
//  Created by 陈勇 on 15/3/4.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import Foundation

///  字典转模型协议 - 键值映射
@objc public protocol DictModel4SwiftProtocol
{
    ///  自定义映射
    ///
    ///  :returns: 返回可选映射关系字典  [属性名称:自定义类型]
    static func customClassMapping() -> [String:String]?
}

///  字典转模型业务类
public class DictModel4Swift: NSObject {


    ///  字典转模型
    ///
    ///  :param: dict 待转换的字典
    ///  :param: cls  模型类型
    ///
    ///  :returns: 返回  转换后的对象
    public func objectWithDictionary(dict:NSDictionary, cls:AnyClass) -> AnyObject?
    {
        // 获取模型成员
        let dictInfo = self.fullModelInfo(cls)
        // 创建对象
        var obj: AnyObject = cls.alloc()

//        printLine()
//        println(dictInfo)
        for (k,v) in dictInfo
        {
            if let value: AnyObject = dict[k]
            {
                if v.isEmpty && !(value === NSNull())
                {
                    // KVC 赋值
                    obj.setValue(value, forKey: k)
                }
                else
                {
                    // 自定义类型
                    // 数组(字典)
                    // 字典
                    let type = "\(value.classForCoder)"
                    if type == DM_Dictionary
                    {
//                        println("=================> \(k)   \(v)   \(value)   \(type)")
                        // swift中的类名包含名称空间，这里会报错！
                        // 解决方案：
                        /*
                        return ["info":"Info","other":"Info","others":"Info"] 替换成：
                        return ["info":"\(Info.self)","other":"\(Info.self)","others":"\(Info.self)"]
                        */
                        if let subObj: AnyObject = self.objectWithDictionary(value as! NSDictionary, cls: NSClassFromString(v))
                        {
                            obj.setValue(subObj, forKey: k)
                        }
                    }
                    else if type == DM_Array
                    {
                        if let subObj: AnyObject = self.objectWithArray(value as! NSArray, cls: NSClassFromString(v))
                        {
                            obj.setValue(subObj, forKey: k)
                        }
                    }
                    else
                    {
                        println("空对象")
                    }
                }
//                printLine()
            }
        }
        return obj
    }

    public func objectWithArray(array:NSArray, cls:AnyClass) -> [AnyObject]?
    {
        // 创建对象
        var subObjs = [AnyObject]()
        for element in array
        {
            // 获取数组中元素的类型
            let type = "\(element.classForCoder)"
//            println("***********  \(element)   \(type)")
            if type == DM_Dictionary
            {
                let obj: AnyObject = self.objectWithDictionary(element as! NSDictionary, cls: cls)!
                subObjs.append(obj)
//                println("*************   \(obj)")
            }
            else if type == DM_Array
            {
                let obj = self.objectWithArray(element as! NSArray, cls: cls)!
                subObjs.append(obj)
            }
        }
        return subObjs
    }

    /// 缓存字典
    var modelCache = [String:[String:String]]()

    ///  获取当前类的所有成员变量（包括非NSObject的父类）
    ///
    ///  :param: cls 当前类
    ///
    ///  :returns: 返回所有成员变量
    func fullModelInfo(cls: AnyClass) -> [String:String]
    {
        var currentCls: AnyClass = cls;
        var dictInfo = [String:String]()
        while let parent: AnyClass = currentCls.superclass()
        {
            // 获取并拼接模型信息
            dictInfo.marge(self.modelInfo(currentCls))
            // 一定要赋值！否则就是死循环 ！！！
            currentCls = parent
        }
        return dictInfo
    }

    ///  获取某个类的成员变量信息
    ///
    ///  :param: cls 当前类
    ///
    ///  :returns: 返回所有成员变量
    func modelInfo(cls: AnyClass) -> [String:String]
    {
        if let cache = modelCache["\(cls)"]
        {
//            println("\(cls)已缓存")
            return cache
        }

        /// 自定义映射关系
        var mapping: [String:String]?
        /// 模型字典信息
        var dictInfo = [String:String]()
        // 判断是否实现了协议方法
        if cls.respondsToSelector("customClassMapping")
        {
            if let tmpMapping = cls.customClassMapping()
            {
                mapping = tmpMapping
            }
        }
        var count: UInt32 = 0
        let ivars = class_copyIvarList(cls, &count)
        for i in 0 ..< count
        {
            let ivar = ivars[Int(i)]
            // 变量名
            let cname = ivar_getName(ivar)
            let name = String.fromCString(cname)!

            let type = mapping?[name] ?? ""
            dictInfo[name] = type
            // 变量类型
//            let ctype = ivar_getTypeEncoding(ivar)
//            let type = String.fromCString(ctype)
//            println("\(name!) ==> \(type)")
        }
        free(ivars)
        // 缓存字典
        modelCache["\(cls)"] = dictInfo
//        modelCache.marge(["\(cls)":dictInfo])
        return dictInfo
    }


    ///  单例，程序的入口
    public static let sharedInstance = DictModel4Swift()
    // 重写init方法，避免在其他类中直接实例化对象
    private override init(){}


    // MARK: - 常量区
    /// 字典
    private let DM_Dictionary = "NSDictionary"
    /// 数组
    private let DM_Array = "NSArray"
    /// 空对象
    private let DM_NSNull = "NSNull"
}

// MARK: - Dictionary 的分类
extension Dictionary
{

    ///  合并字典
    ///
    ///  :param: dict 待合并的字典
    ///  mutating修饰函数  函数中的字典(self)是可变的！
    ///  泛型
    mutating func marge<K,V>(dict:[K: V])
    {
        for (key, value) in dict
        {
            self.updateValue(value as! Value, forKey: key as! Key)
        }
    }
}

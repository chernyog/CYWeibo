//
//  NetworkManager.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/5.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import Foundation

class NetworkManager {
    // 单例的概念：
    // 1. 内存中有一个唯一的实例
    // 2. 提供唯一的全局访问入口
    // let 是定义常量，而且在 swift 中，let 是线程安全的
    private static let instance = NetworkManager()
    /// 定义一个类变量，提供全局的访问入口，类变量不能存储数值，但是可以返回数值
    class var sharedManager: NetworkManager {
        return instance
    }

    // 定义了一个类的完成闭包类型
    typealias Completion = (result: AnyObject?, error: NSError?) -> ()

    func requestJSON(method: HTTPMethod, _ urlString: String, _ params: [String: String]?, completion: Completion) {
        net.requestWithJSON(urlString, params: params, methodType: method, completion: completion)
    }

    // MARK: - 下载图片

    ///  异步下载网路图像
    ///
    ///  :param: urlString  urlString
    ///  :param: completion 完成回调
    func requestImage(urlString: String, _ completion: Completion)
    {
        net.requestImage(urlString, completion)
    }
    
    ///  下载单张图片
    ///
    ///  :param: urlString urlString
    ///  :param: comletion 完成的回调
    func downloadImage(urlString: String, _ comletion: Completion)
    {
        net.downloadImage(urlString, comletion)
    }

    ///  多任务并发下载
    ///
    ///  :param: urlStrings 下载请求url字符串数组
    ///  :param: completion 下载完成回调
    func downloadImages(urlStrings: [String], _ completion: Completion)
    {
        net.downloadImages(urlStrings, completion)
    }

    ///  完整的 URL 缓存路径
    func fullImageCachePathByMD5(urlString: String) -> String
    {
        return net.fullImageCachePathByMD5(urlString)
    }

    ///  全局的一个网络框架实例，本身也只会被实例化一次
    private let net = SimpleNetwork.sharedInstance
}
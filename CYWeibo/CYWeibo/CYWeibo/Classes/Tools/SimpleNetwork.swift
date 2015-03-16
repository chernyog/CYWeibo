//
//  SimpleNetwork.swift
//  SimpleNetwork
//
//  Created by 陈勇 on 15/3/3.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import Foundation

///  网络请求类型
///
///  - GET:  GET请求
///  - POST: POST请求
///  类中成员的访问修饰词的权限不能比class的访问权限大！！！
public enum HTTPMethod: String
{
    case GET = "GET"
    case POST = "POST"
}

// MARK: - 全局变量
private let imageCachePath = "com.zhssit.imageCache"

// MARK: - session对象
private let session = NSURLSession.sharedSession()

class SimpleNetwork
{

    private init(){}

    /// 单例对象
    static let sharedInstance = SimpleNetwork()

    // 定义闭包类型，类型别名－> 首字母一定要大写
    typealias Completion = (result:AnyObject?, error:NSError?) -> ()

    ///  发送网络请求
    ///
    ///  :param: urlString  urlString
    ///  :param: params     请求参数
    ///  :param: methodType 请求类型
    ///  :param: completion 请求完成的回调
    func requestWithJSON(urlString: String, params:[String:String]?, methodType:HTTPMethod,completion:Completion)
    {
        if urlString.isEmpty
        {
            return
        }
        if let request = self.request(urlString, params, methodType)
        {
            println("URL:\(request.URL!)")
            let session = NSURLSession.sharedSession()
            session.dataTaskWithRequest(request, completionHandler: { (data, _, error) -> Void in
                if error != nil
                {
                    completion(result: nil,error: error)
                    return
                }
                // 反序列化
                var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                // 判断是否反序列化成功
//                println("\(json)")
                if json == nil {
                    let error = NSError(domain: "www.zhssit.com", code: -1, userInfo: ["error": "反序列化失败"])
                    completion(result: nil, error: error)
                }
                else {
                    // 主线程回调
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        println("---------------- \(json)")
                        completion(result: json, error: nil)
                    })
                }
            }).resume()
        }
    }

    ///  生成Request
    ///
    ///  :param: urlString  urlString
    ///  :param: params     请求参数
    ///  :param: methodType 请求类型
    ///
    ///  :returns: 返回Request
    private func request(urlString:String, _ params:[String:String]?, _ methodType:HTTPMethod) -> NSMutableURLRequest?
    {
        if urlString.isEmpty
        {
            return nil
        }
        var urlStr = urlString
        var request :NSMutableURLRequest?
        if methodType == HTTPMethod.GET
        {
            var queryString = self.queryString(params)
            if !queryString!.isEmpty
            {
                urlStr += "?" + queryString!  // 注意字符串的拼接！！！
                request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
            }
        }
        else if methodType == HTTPMethod.POST
        {
            if let queryString = self.queryString(params)
            {
                request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
                request?.HTTPMethod = methodType.rawValue
                request?.HTTPBody = queryString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        }

//        println("---------------- \(request?.URL?.absoluteString)")
        return request
    }

    ///  解析查询参数
    ///
    ///  :param: params 参数字典
    ///
    ///  :returns: 返回参数字符串
    private func queryString(params: [String:String]?) ->String?
    {
        if params == nil
        {
            return nil
        }
        var array = [String]()
        for (key, value) in params!
        {
            // 添加百分号转义
            let str = key + "=" + value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            array.append(str)
        }
        return join("&", array)
    }

    // MARK: - 下载图片

    ///  异步下载网路图像
    ///
    ///  :param: urlString  urlString
    ///  :param: completion 完成回调
    func requestImage(urlString: String, _ completion: Completion) {

        // 1. 调用 download 下载图像，如果图片已经被缓存过，就不会再次下载
        downloadImage(urlString, { (result, error) -> () in
            if error != nil {
                completion(result: nil, error: error)
            } else {
                // 2 图像是保存在沙盒路径中的，文件名是 url ＋ md5
                var fullPath = self.fullImageCachePathByMD5(urlString)
                // 将图像从沙盒加载到内存
                var image = UIImage(contentsOfFile: fullPath)
                // 提示：尾随闭包，如果没有参数，没有返回值，都可以省略！
                dispatch_async(dispatch_get_main_queue()) {
                    completion(result: image, error: nil)
                }
            }
        })
    }

    ///  完整的 URL 缓存路径
    func fullImageCachePathByMD5(urlString: String) -> String {
        var path = urlString.md5
        return cachePath!.stringByAppendingPathComponent(path)
    }


    ///  缓存路径
    lazy var cachePath: String? = {

        // cache 缓存路径
        var path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).last as! String
        path = path.stringByAppendingPathComponent(imageCachePath)

        // 判断沙盒中是否存在与 imageCachePath 同名的文件（非文件夹）
        var isDirectory: ObjCBool = true
        let result = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
        if result && !isDirectory
        {
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
        }
        // 创建文件夹
        NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        return path
    }()

    ///  下载单张图片
    ///
    ///  :param: urlString urlString
    ///  :param: comletion 完成的回调
    internal func downloadImage(urlString: String, _ comletion: Completion)
    {
        var fullPath = fullImageCachePathByMD5(urlString)
        // 如果沙盒中存在该文件，直接返回
        if NSFileManager.defaultManager().fileExistsAtPath(fullPath)
        {
//            println("\(fullPath) 已缓存！")
            comletion(result: nil, error: nil)
            return
        }
//        println("__________ \(fullPath)   urlString = \(urlString)")
        // 文件未被缓存  直接下载
        if let url = NSURL(string: urlString)
        {
            session.downloadTaskWithURL(url){ (location, _, error) -> Void in
//                println("__________ \(location.path!)")
                if error != nil
                {
                    comletion(result: nil, error: error)
                    return
                }
                // 将tmp文件夹中的文件copy到cache文件夹去
                var cpError: NSError?
                let cpResult = NSFileManager.defaultManager().copyItemAtPath(location.path!, toPath: fullPath, error:&cpError)
                if cpResult && cpError == nil
                {
                    // copy文件成功
                    comletion(result: nil, error: nil)
                }
                else
                {
                    comletion(result: nil, error: cpError)
                }
            }.resume()  // 一定要记住 resume！！！
        }
    }

    ///  多任务并发下载
    ///
    ///  :param: urlStrings 下载请求url字符串数组
    ///  :param: completion 下载完成回调
    internal func downloadImages(urlStrings: [String], _ completion: Completion)
    {
        // 调度组
        let group = dispatch_group_create()
        for urlString in urlStrings
        {
            // 进入调度组
            dispatch_group_enter(group)
            // 执行下载任务
            self.downloadImage(urlString){ (result, error) -> () in
                // 注意：这里不需要进行错误处理，因为一次下载任务失败之后，其他下载任务任然需要执行！
                // 下载完成之后离开调度组
                dispatch_group_leave(group)
            }
        }
        // 主线程回调
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            printLine()
            println("\(urlStrings.count) 个任务下载完成！")
            completion(result: nil, error: nil)
        }
    }

}


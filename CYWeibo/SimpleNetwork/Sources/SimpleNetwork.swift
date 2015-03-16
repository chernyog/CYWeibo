//
//  SimpleNetwork.swift
//  SimpleNetwork
//
//  Created by 陈勇 on 15/3/3.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import Foundation

public class SimpleNetwork
{

    ///  网络请求类型
    ///
    ///  - GET:  GET请求
    ///  - POST: POST请求
    ///  类中成员的访问修饰词的权限不能比class的访问权限大！！！
    public enum MethodType: String
    {
        case GET = "GET"
        case POST = "POST"
    }

    // 定义闭包类型，类型别名－> 首字母一定要大写
    public typealias Completion = (result:AnyObject?, error:NSError?) -> ()

    ///  发送网络请求
    ///
    ///  :param: urlString  urlString
    ///  :param: params     请求参数
    ///  :param: methodType 请求类型
    ///  :param: completion 请求完成的回调
    public func requestWithJSON(urlString: String, params:[String:String]?, methodType:MethodType,completion:Completion)
    {
        if urlString.isEmpty
        {
            return
        }
        if let request = self.request(urlString, params, methodType)
        {
            let session = NSURLSession.sharedSession()
            session.dataTaskWithRequest(request, completionHandler: { (data, _, error) -> Void in
                if error != nil
                {
                    completion(result: nil,error: error)
                }
                // 反序列化
                var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                // 判断是否反序列化成功
                if json == nil {
                    let error = NSError(domain: "www.zhssit.com", code: -1, userInfo: ["error": "反序列化失败"])
                    completion(result: nil, error: error)
                } else {
                    // 主线程回调
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
    private func request(urlString:String, _ params:[String:String]?, _ methodType:MethodType) -> NSMutableURLRequest?
    {
        if urlString.isEmpty
        {
            return nil
        }
        var urlStr = urlString
        var request :NSMutableURLRequest?
        if methodType == MethodType.GET
        {
            var queryString = self.queryString(params)
            if !queryString!.isEmpty
            {
                urlStr = "?" + queryString!
                request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
            }
        }
        else if methodType == MethodType.POST
        {
            if let queryString = self.queryString(params)
            {
                request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
                request?.HTTPMethod = methodType.rawValue
                request?.HTTPBody = queryString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        }
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

    public static let sharedNetwork: SimpleNetwork = SimpleNetwork()
    
    private init(){}
}


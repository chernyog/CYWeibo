//
//  OAuthViewController.swift
//  04-TDD
//
//  Created by 陈勇 on 15/3/3.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit

// 定义全局常量
/// 登录成功的通知
let WB_Login_Successed_Notification = "WB_Login_Successed_Notification"

class OAuthViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self

        // 加载授权界面
        loadAuthPage()
    }

    /// 加载授权界面
    func loadAuthPage()
    {
        // url
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(appKey)&redirect_uri=\(redirectUri)"
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        webView.loadRequest(request)
    }

}

// MARK:- 常量区
let appKey = "2013929282"
let appSecret = "a8ef9f6c61af740a6cd5742874f348ff"
let redirectUri = "http://zhssit.com/"
let grantType = "authorization_code"
let WB_API_URL_String = "https://api.weibo.com"
let WB_Redirect_URL_String = "http://zhssit.com/"

// MARK: - <UIWebViewDelegate>
extension OAuthViewController: UIWebViewDelegate
{
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        let result = self.checkLoadPageAndRuturnCodeWithUrl(request.URL!)
        if let code = result.code
        {
            // 请求参数
            let params = ["client_id": appKey,
                "client_secret": appSecret,
                "grant_type": grantType,
                "redirect_uri": WB_Redirect_URL_String,
                "code": code]
            let urlString = "https://api.weibo.com/oauth2/access_token"
            NetworkManager.sharedManager.requestJSON(.POST, urlString, params, completion: { (result, error) -> () in
                println("==================================================================")
                //                println(result)     // liufan2000
                //                let accessToken = DictModel4Swift.sharedInstance.objectWithDictionary(result as! NSDictionary, cls: AccessToken.self) as! AccessToken
                let accessToken = AccessToken(dict: result as! NSDictionary)
                accessToken.saveAccessToken()
                println("***********" + accessToken.access_token!)
                println("==================================================================")

                // 切换UI
                NSNotificationCenter.defaultCenter().postNotificationName(WB_Login_Successed_Notification, object: nil)
            })
        }
        return result.isLoadPage
    }

    ///  根据URL判断是否需要加载页面和返回code
    ///
    ///  :param: url url
    ///
    func checkLoadPageAndRuturnCodeWithUrl(url: NSURL)->(isLoadPage: Bool,code: String?,isReloadAuth: Bool)
    {
        let urlString = url.absoluteString!
        if !urlString.hasPrefix(WB_API_URL_String)
        {
            if urlString.hasPrefix(WB_Redirect_URL_String)
            {
                // http://zhssit.com/?code=584b72d000009d5eca69ed7fd3de103b
                if let query = url.query
                {
                    let flag: NSString = "code="
                    if query.hasPrefix(flag as String)  // 授权
                    {
                        // 截取字符串
                        let code = (query as NSString).substringFromIndex(flag.length)
                        return (false, code, false)
                    }
                    else  // 取消授权
                    {
                        return (false, nil, true)
                    }
                }
            }
            return (false, nil,false)
        }
        return (true, nil, false)
    }

}


/*

系统URL

登录  加载页面
https://api.weibo.com/oauth2/authorize?client_id=2013929282&redirect_uri=http://zhssit.com/

登录成功    加载页面
https://api.weibo.com/oauth2/authorize

注册  不加载页面
http://weibo.cn/dpool/ttt/h5/reg.php?wm=4406&appsrc=3fgubw&backURL=https%3A%2F%2Fapi.weibo.com%2F2%2Foauth2%2Fauthorize%3Fclient_id%3D2013929282%26response_type%3Dcode%26display%3Dmobile%26redirect_uri%3Dhttp%253A%252F%252Fzhssit.com%252F%26from%3D%26with_cookie%3D

切换账号    不加载页面
http://login.sina.com.cn/sso/logout.php?entry=openapi&r=http%3A%2F%2Flogin.sina.com.cn%2Fsso%2Flogout.php%3Fentry%3Dopenapi%26r%3Dhttps%253A%252F%252Fapi.weibo.com%252Foauth2%252Fauthorize%253Fclient_id%253D2013929282%2526redirect_uri%253Dhttp%253A%252F%252Fzhssit.com%252F

取消授权    不加载页面，加载授权界面
http://zhssit.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330

授权  不加载页面 返回code
http://zhssit.com/?code=584b72d000009d5eca69ed7fd3de103b

*/
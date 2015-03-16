//
//  AccessTokenTests.swift
//  CYWeibo
//
//  Created by 陈勇 on 15/3/5.
//  Copyright (c) 2015年 zhssit. All rights reserved.
//

import UIKit
import XCTest

class AccessTokenTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIsExpired()
    {
        var params = ["access_token": "ACCESS_TOKEN",
        "expires_in": 1234,
        "remind_in":"798114",
        "uid":"12341234"]

        params = ["access_token": "ACCESS_TOKEN",
            "expires_in": 0,
            "remind_in":"798114",
            "uid":"12341234"]

        params = ["access_token": "ACCESS_TOKEN",
            "expires_in": -1,
            "remind_in":"798114",
            "uid":"12341234"]

//        let accessToken = DictModel4Swift.sharedInstance.objectWithDictionary(params, cls: AccessToken.self) as? AccessToken
//        println("===========> \(accessToken?.debugDescription)")
    }

}

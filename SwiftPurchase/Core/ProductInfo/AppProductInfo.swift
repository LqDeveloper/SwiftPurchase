//
//  AppleProductInfo.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public typealias ProductInfo = (products:[SKProduct],invalidProductIDs:[String])

///产品列表
public typealias ProductInfoReuslt = Result<ProductInfo,SKError>

///请求产品回调
public typealias ProductRequestCallback = (ProductInfoReuslt) -> Void

/// 请求产品需要实现的协议，通过实现这个协议，自定义请求方法
public protocol AppProductInfo{
    func requestProductsInfo(_ productIds: Set<String>, completion: @escaping ProductRequestCallback)
    func cancle(_ productIds: Set<String>)
    func cancleAll()
}


public extension AppProductInfo{
    func cancleAll(){}
}

//
//  ProductsInfoController.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

class ProductsInfoController :AppProductInfo{
    //用来使每个请求和回调一一对应
    private struct AppProductQuery {
        let request: ProductInfoRequest
        var completionHandlers: [AppProductRequestCallback]
    }
    ///使用Set<String>为key保存请求
    private var requestDic: [Set<String>: AppProductQuery] = [:]
    
    /// 根据productID从苹果请求产品 回将请求保存在requestDic字典中，
    /// 在请求结束后会将它从字典中移除
    /// - Parameters:
    ///   - productIds: 产品ID
    ///   - completion: 回调
    func requestProductsInfo(_ productIds: Set<String>, completion: @escaping AppProductRequestCallback) {
        guard requestDic[productIds] == nil else {
            requestDic[productIds]!.completionHandlers.append(completion)
            return
        }
        
        let request = AppleProductRequest.init(productIds: productIds) {[weak self] (result) in
            if let query = self?.requestDic[productIds] {
                for handler in query.completionHandlers {
                    handler(result)
                }
                self?.requestDic[productIds] = nil
            }else{
                completion(result)
            }
        }
        
        self.requestDic[productIds] = AppProductQuery(request: request, completionHandlers: [completion])
        request.start()
    }
    
    /// 取消某个请求
    /// - Parameter productIds: 请求的产品ID
    func cancle(_ productIds: Set<String>){
        guard let query = requestDic[productIds] else {
            return
        }
        query.request.cancle()
        requestDic[productIds] = nil
    }
    
    /// 取消所有的请求
    func cancleAll(){
        for (_,value) in requestDic {
            value.request.cancle()
        }
        requestDic.removeAll()
    }
}


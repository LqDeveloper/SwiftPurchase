//
//  AppleProductRequest.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

protocol ProductInfoRequest {
    func start()
    func cancle()
}
/// 根据productId获取产品列表
class AppleProductRequest: NSObject,ProductInfoRequest,SKProductsRequestDelegate {
    
    private var request:SKProductsRequest?
    private let callback: AppProductRequestCallback
    
    init(productIds: Set<String>, callback: @escaping AppProductRequestCallback) {
        self.request = SKProductsRequest.init(productIdentifiers: productIds)
        self.callback = callback
        super.init()
        request?.delegate = self
    }
    
    deinit {
        request?.delegate = nil
        request = nil
    }
    
    func start() {
        request?.start()
    }
    
    func cancle() {
        request?.cancel()
    }
    
    private func performCallbackOnMain(_ results: ProductInfoReuslt) {
        DispatchQueue.main.async {
            self.callback(results)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        performCallbackOnMain(.success((products: response.products, invalidProductIDs: response.invalidProductIdentifiers)))
    }
    
    func requestDidFinish(_ request: SKRequest) {}
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        performCallbackOnMain(.failure(SKError.init(_nsError: (error as NSError))))
    }
}

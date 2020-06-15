//
//  AppleReceiptRequest.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

typealias ReceiptRequestResult = Result<Void,SKError>
typealias ReceiptRequestCallback = (ReceiptRequestResult) -> Void

class AppleReceiptRequest: NSObject, SKRequestDelegate {
    var request: SKReceiptRefreshRequest?
    let callback: ReceiptRequestCallback
    
    init(receiptProperties: [String: Any]? = nil, callback: @escaping ReceiptRequestCallback) {
        self.callback = callback
        self.request = SKReceiptRefreshRequest(receiptProperties: receiptProperties)
        super.init()
        self.request?.delegate = self
    }
    
    deinit {
        request?.cancel()
        request?.delegate = nil
        request = nil
    }
    
    class func request(_ receiptProperties: [String: Any]? = nil, callback: @escaping ReceiptRequestCallback) -> AppleReceiptRequest {
        let request = AppleReceiptRequest(receiptProperties: receiptProperties, callback: callback)
        request.start()
        return request
    }
    
    
    func start() {
        request?.start()
    }
    
    func cancle() {
        request?.cancel()
    }
    
    private func performCallbackOnMain(_ result: ReceiptRequestResult) {
        DispatchQueue.main.async {
            self.callback(result)
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        performCallbackOnMain(.success(()))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        performCallbackOnMain(.failure(SKError.init(_nsError: (error as NSError))))
    }
}

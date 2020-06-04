//
//  ReceiptController.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

class ReceiptController:AppReceiptVerificator {
    private var request: AppleReceiptRequest?
    private var receiptValidator:AppleReceiptValidator?
    public var receiptURL: URL?
    public init(receiptURL: URL? = Bundle.main.appStoreReceiptURL) {
        self.receiptURL = receiptURL
    }
    
    /// 请求获取receiptData
    /// forceRefresh如果为false，会先检查本地是否存有receipt，如果有会直接返回，如果没有回去请求
    /// 如果为true会直接请求刷新
    /// - Parameters:
    ///   - forceRefresh: 是否强制请求
    ///   - completion: 回调
    func fetchReceipt(forceRefresh: Bool = false,completion: @escaping (ReceiptDataResult) -> Void) {
        if let data = receiptData, forceRefresh == false {
            completion(.success(data))
        } else {
            request = AppleReceiptRequest.request(callback: {[weak self] (result) in
                self?.request = nil
                switch result{
                case .success():
                    if let data = self?.receiptData {
                        completion(.success(data))
                    } else {
                        completion(.failure(.noReceiptData))
                    }
                case .failure(let error):
                    completion(.failure(.requestError(error)))
                }
            })
        }
    }
    
    /// 向苹果验证Receipt
    /// - Parameters:
    ///   - verifyType: 验证类型是production还是sandbox
    ///   - sharedSecret: password
    ///   - receiptData: Receipt
    ///   - completion: 回调
    /// - Returns: URLSessionDataTask?
    @discardableResult
    func verifyReceipt(_ verifyType:VerifyReceiptType = .production,_ sharedSecret: String? = nil,_ excludeOldTransactions:Bool = false,_ receiptData: Data, completion: @escaping (VerifyReceiptResult) -> Void) -> URLSessionDataTask?{
        receiptValidator = AppleReceiptValidator.init(verifyType, sharedSecret,excludeOldTransactions)
        return receiptValidator?.validate(receiptData: receiptData, completion: {[weak self] (result) in
            self?.receiptValidator = nil
            completion(result)
        })
    }
    
    func cancle() {
        request?.cancle()
    }
    
    
}

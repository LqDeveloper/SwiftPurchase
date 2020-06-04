//
//  AppleReceiptValidator.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

struct AppleReceiptValidator: ReceiptValidator {
    private let verifyType: VerifyReceiptType
    private let sharedSecret: String?
    //excludeOldTransactions:Bool = false,将此值设置为true，以使响应仅包括任何订阅的最新续订交易。仅对包含自动续订的应用收据使用此字段。
    private let excludeOldTransactions:Bool
    /// Apple收据验证
    /// - Parameters:
    ///   - verifyType: 验证地址
    ///   - sharedSecret: 仅用于包含自动续订的收据。 您应用的共享密码（十六进制字符串）。
    init(_ verifyType: VerifyReceiptType = .production, _ sharedSecret: String? = nil,_ excludeOldTransactions:Bool = false) {
        self.verifyType = verifyType
        self.sharedSecret = sharedSecret
        self.excludeOldTransactions = excludeOldTransactions
    }
    //requestBody :https://developer.apple.com/documentation/appstorereceipts/requestbody
    //responseBody : https://developer.apple.com/documentation/appstorereceipts/responsebody
    @discardableResult
    func validate(receiptData: Data, completion: @escaping (VerifyReceiptResult) -> Void) -> URLSessionDataTask? {
        guard let storeURL = URL(string: verifyType.rawValue) else {
            completion(.failure(.verifyUrlError))
            return nil
        }
        let request = NSMutableURLRequest.init(url: storeURL)
        request.httpMethod = "POST"
        
        let receipt = receiptData.base64EncodedString(options: [])
        var parameter: [String:Any] = ["receipt-data": receipt]
        if let password = sharedSecret {
            parameter["password"] = password
        }
        
        if excludeOldTransactions {
            parameter["exclude-old-transactions"] = true
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: [])
        } catch let error {
            completion(.failure(.requestBodyEncodeError(error)))
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
            if let networkError = error {
                completion(.failure(.requestError(networkError)))
                return
            }
            
            guard let safeData = data else {
                completion(.failure(.noReceiveData))
                return
            }
            
            guard let receiptInfo = try? JSONSerialization.jsonObject(with: safeData, options: .mutableLeaves) as? ReceiptInfo ?? [:] else {
                let jsonStr = String(data: safeData, encoding: String.Encoding.utf8)
                completion(.failure(.jsonDecodeError(jsonStr)))
                return
            }
            
            if let status = receiptInfo["status"] as? Int {
                let receiptStatus = ReceiptStatus(rawValue: status) ?? ReceiptStatus.unknown
                if receiptStatus.isValid {
                    completion(.success(receiptInfo))
                } else {
                    completion(.failure(.receiptInvalid(receiptInfo,receiptStatus)))
                }
            } else {
                completion(.failure(.receiptInvalid(receiptInfo,ReceiptStatus.none)))
            }
        }
        task.resume()
        return task
    }
    
}


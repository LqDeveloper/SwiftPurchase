//
//  AppleReceiptValidator.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public enum VerifyReceiptType: String {
    case production = "https://buy.itunes.apple.com/verifyReceipt"
    case sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
}

///请求Receipt返回ReceiptData或者ReceiptError
public typealias ReceiptDataResult = Result<Data?,ReceiptError>

// Receipt 字段信息 : https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1
public protocol AppReceiptVerificator {
    var receiptURL: URL? {get}
    var receiptData: Data?  {get}
    func fetchReceipt(forceRefresh: Bool,completion: @escaping (ReceiptDataResult) -> Void)
    func verifyReceipt(_ verifyType:VerifyReceiptType,_ sharedSecret: String?,_ excludeOldTransactions:Bool,_ receiptData: Data, completion: @escaping (VerifyReceiptResult) -> Void) -> URLSessionDataTask?
    func cancle()
}

public extension AppReceiptVerificator{
    var receiptData: Data? {
        guard let receiptDataURL = receiptURL,
            let data = try? Data(contentsOf: receiptDataURL) else {
                return nil
        }
        return data
    }
}

///Receipt 字典
public typealias ReceiptInfo = [String: AnyObject]
///验证Receipt结果
public typealias VerifyReceiptResult = Result<ReceiptInfo,ReceiptError>

public protocol ReceiptValidator {
    func validate(receiptData: Data, completion: @escaping (VerifyReceiptResult) -> Void) -> URLSessionDataTask?
}


///Receipt 验证和请求发生的错误
public enum ReceiptError: Error {
    /// Receipt验证地址错误
    case verifyUrlError
    /// 没有Receipt
    case noReceiptData
    /// 没有收到数据
    case noReceiveData
    /// 请求参数转为Data失败
    case requestBodyEncodeError(_ error: Error)
    /// 请求失败
    case requestError(_ error:Error)
    /// 将Data转为json失败
    case jsonDecodeError(_ string: String?)
    /// 接收无效，返回错误状态
    case receiptInvalid(_ receipt: ReceiptInfo,_ status: ReceiptStatus)
    
    public var description:String{
        switch self {
        case .verifyUrlError:
            return "Receipt验证地址错误"
        case .noReceiptData:
            return "没有Receipt"
        case .noReceiveData:
            return "没有收到数据"
        case .requestBodyEncodeError(let error):
            return "请求参数转为Data失败 \(error.localizedDescription)"
        case .requestError(let error):
            return "请求失败 \(error.localizedDescription)"
        case .jsonDecodeError(let str):
            return "将Data转为json失败  \(str ?? "")"
        case .receiptInvalid(let info, let status):
            return "接收无效，返回错误状态 info:\(info)  status:\(status.description)"
        }
    }
}
///验证Receipt服务器返回的状态码 https://developer.apple.com/documentation/appstorereceipts/status
public enum ReceiptStatus: Int {
    // 未知错误
    case unknown = -2
    // 没有状态返回
    case none = -1
    // 有效状态
    case valid = 0
    // 未使用HTTP POST请求方法向App Store发送请求
    case noUserPostMethod = 21000
    // 收据数据属性中的数据格式错误，或者服务遇到临时问题。 再试一次
    case malformedOrMissingData = 21002
    // 收据无法认证
    case receiptCouldNotBeAuthenticated = 21003
    // 您提供的共享密码与您帐户的文件共享密码不匹配。也就是sharedSecret不正确
    case secretNotMatching = 21004
    // 收据服务器暂时无法提供收据。 再试一次
    case receiptServerUnavailable = 21005
    // 该收据有效，但订阅已过期。 当此状态代码返回到您的服务器时，收据数据也会被解码并作为响应的一部分返回。 仅针对自动续订的iOS 6样式的交易收据返回
    case subscriptionExpired = 21006
    // 该收据来自测试环境，但已发送到生产环境以进行验证
    case sandboxEnvironment = 21007
    // 该收据来自生产环境，但是已发送到测试环境以进行验证
    case productionEnvironment = 21008
    // 内部数据访问错误。 稍后再试
    case internalDataAccessError = 21009
    // 找不到或删除了该用户帐户
    case userAccountNoFound = 21010
    var isValid: Bool { return self == .valid}
    
    
    public var description:String{
        switch self {
        case .unknown:
            return "未知错误"
        case .none:
            return "没有状态返回"
        case .valid:
            return "有效状态"
        case .noUserPostMethod:
            return "未使用HTTP POST请求方法向App Store发送请求"
        case .malformedOrMissingData:
            return "收据数据属性中的数据格式错误，或者服务遇到临时问题。 再试一次"
        case .receiptCouldNotBeAuthenticated:
            return "收据无法认证"
        case .secretNotMatching:
            return "您提供的共享密码与您帐户的文件共享密码不匹配。也就是sharedSecret不正确"
        case .receiptServerUnavailable:
            return "收据服务器暂时无法提供收据。 再试一次"
        case .subscriptionExpired:
            return "该收据有效，但订阅已过期。 当此状态代码返回到您的服务器时，收据数据也会被解码并作为响应的一部分返回。 仅针对自动续订的iOS 6样式的交易收据返回"
        case .sandboxEnvironment:
            return "该收据来自测试环境，但已发送到生产环境以进行验证"
        case .productionEnvironment:
            return "该收据来自生产环境，但是已发送到测试环境以进行验证"
        case .internalDataAccessError:
            return "内部数据访问错误,稍后再试"
        case .userAccountNoFound:
            return "找不到或删除了该用户帐户"
        }
    }
    
}



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


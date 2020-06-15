//
//  PurchaseManager.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/1.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public class SwiftPurchase{
    private var productInfo:AppProductInfo
    private var receiptVerificator:AppReceiptVerificator
    private var purchaseController:AppPurchase
    
    public static let shared = SwiftPurchase()
    public static var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    init(_ product:AppProductInfo = ProductsInfoController(),_ verificator:AppReceiptVerificator = ReceiptController(),_ purchase:AppPurchase = PurchaseController()) {
        self.productInfo = product
        self.receiptVerificator = verificator
        self.purchaseController = purchase
    }
}

//获取产品列表
public extension SwiftPurchase{
    static func requestProductsInfo(_ productIds: [String], completion: @escaping ProductRequestCallback){
        shared.productInfo.requestProductsInfo(Set(productIds), completion: completion)
    }
    
    static func cancleRequest(_ productIds:[String]){
        shared.productInfo.cancle(Set(productIds))
    }
    
    static func cancleAllRequest(){
        shared.productInfo.cancleAll()
    }
}

//receipt的获取和验证
public extension SwiftPurchase{
    static var receiptData:Data?{
        return shared.receiptVerificator.receiptData
    }
    
    static func fetchReceipt(forceRefresh: Bool,completion: @escaping (ReceiptDataResult) -> Void){
        shared.receiptVerificator.fetchReceipt(forceRefresh: forceRefresh, completion: completion)
    }
    
    @discardableResult
    static func verifyReceipt(verifyType:VerifyReceiptType = .production,sharedSecret: String? = nil,excludeOldTransactions:Bool = false,receiptData: Data, completion: @escaping (VerifyReceiptResult) -> Void)  -> URLSessionDataTask?{
        return shared.receiptVerificator.verifyReceipt(verifyType, sharedSecret,excludeOldTransactions,receiptData, completion: completion)
    }
    
    static func cancleFetchReceipt(){
        shared.receiptVerificator.cancle()
    }
}

//购买产品
public extension SwiftPurchase{
    static func purchaseProduct(_ productId: String, quantity: Int = 1, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false, completion: @escaping (PaymentResult) -> Void) {
        requestProductsInfo([productId]) {(result) in
            if let product = result.products.first {
                SwiftPurchase.purchaseProduct(product, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox, completion: completion)
            }else if let error = result.error{
                completion(.failure(error))
            }else if let invalidProductId = result.invalidProductIDs.first {
                let userInfo = [ NSLocalizedDescriptionKey: "Invalid product id: \(invalidProductId)" ]
                let error = NSError(domain: SKErrorDomain, code: SKError.paymentInvalid.rawValue, userInfo: userInfo)
                completion(.failure(SKError(_nsError: error)))
            }else {
                let error = NSError(domain: SKErrorDomain, code: SKError.unknown.rawValue, userInfo: nil)
                completion(.failure(SKError(_nsError: error)))
            }
        }
    }
    
    static func purchaseProduct(_ product: SKProduct, quantity: Int = 1, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false, completion: @escaping PaymentCallback) {
        shared.purchaseController.startPayment(Payment.init(product: product, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox, callback: completion))
    }
    
    static func finishTransaction(_ transaction: PurchaseTransaction) {
        shared.purchaseController.finishTransaction(transaction.transaction)
    }
}

//恢复产品
public extension SwiftPurchase{
    static func restorePurchases(atomically: Bool = true, applicationUsername: String = "", completion: @escaping RestoreCallback) {
        shared.purchaseController.restorePurchases(RestorePurchases.init(atomically: atomically, applicationUsername: applicationUsername, callback: completion))
    }
}

//应用启动的时候处理没有finish的订单
public extension SwiftPurchase{
    static func completeTransactions(atomically: Bool = true, completion: @escaping CompleteCallback) {
        shared.purchaseController.completeTransactions(CompletePruchase(atomically: atomically, callback: completion))
    }
}

//下载产品
public extension SwiftPurchase{
    static var shouldAddStorePaymentHandler: ShouldAddStorePaymentHandler? {
        didSet {
            shared.purchaseController.shouldAddStorePaymentHandler = shouldAddStorePaymentHandler
        }
    }
    
    static var updatedDownloadsHandler: UpdatedDownloadsHandler? {
        didSet {
            shared.purchaseController.updatedDownloadsHandler = updatedDownloadsHandler
        }
    }
    
    static func start(_ downloads: [SKDownload]) {
        shared.purchaseController.start(downloads)
    }
    
    static func pause(_ downloads: [SKDownload]) {
        shared.purchaseController.pause(downloads)
    }
    
    static func resume(_ downloads: [SKDownload]) {
        shared.purchaseController.resume(downloads)
    }
    
    static func cancel(_ downloads: [SKDownload]) {
        shared.purchaseController.cancel(downloads)
    }
}

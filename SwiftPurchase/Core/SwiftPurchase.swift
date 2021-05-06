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
    static func purchase(_ productId: String, quantity: Int = 1, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false,paymentDiscount: PaymentDiscount? = nil, completion: @escaping (PaymentResult) -> Void) {
        requestProductsInfo([productId]) {(result) in
            if let product = result.products.first {
                SwiftPurchase.purchase(product, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox,paymentDiscount: paymentDiscount, completion: completion)
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
    
    static func purchase(_ product: SKProduct, quantity: Int = 1, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false,paymentDiscount: PaymentDiscount? = nil, completion: @escaping PaymentCallback) {
        shared.purchaseController.startPayment(Payment.init(product: product,paymentDiscount: paymentDiscount, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox, callback: completion))
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
/*
 对于启用了“家庭共享”的产品，可能会发生以下情况触发此方法：
    购买者离开了他们共享订阅或非消耗品的家庭组。
    购买者禁用非消耗者的家庭共享，或停止共享订阅。
    购买者隐藏了一个应用，这使得他们的非消耗性购买无法共享。
    家庭成员离开了小组，不再可以共享购买。
通过离开家庭组，或以上述任何一种方式禁用共享，家庭成员将不再有权进行家庭共享的购买。 productIdentifiers参数包含已撤销的产品ID
 */
public extension SwiftPurchase{
    /// 权利撤销通知
    /// - Parameter completion: 返回吊销的产品标识符列表
    @available(iOS 14, tvOS 14, OSX 11, watchOS 7, macCatalyst 14, *)
    static func onEntitlementRevocation(completion: @escaping ([String]) -> Void) {
        shared.purchaseController.onEntitlementRevocation(completion)
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

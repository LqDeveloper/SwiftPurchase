//
//  AppPurchase.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public protocol PurchaseTransaction{
    var transaction:SKPaymentTransaction {set get}
}

public struct PaymentSuccess:PurchaseTransaction {
    public let product:SKProduct
    public var transaction:SKPaymentTransaction
    public let needFinish:Bool
}

public struct Purchase :PurchaseTransaction{
    public var transaction:SKPaymentTransaction
    public let needFinish:Bool
}

public typealias PaymentResult = Result<PaymentSuccess,SKError>

public typealias PaymentCallback = (PaymentResult) -> Void

public typealias RestoreResult = Result<Purchase,SKError>

public typealias RestoreCallback = ([RestoreResult]) -> Void

public typealias CompleteCallback = ([Purchase]) -> Void

public typealias ShouldAddStorePaymentHandler = (_ payment: SKPayment, _ product: SKProduct) -> Bool

public typealias UpdatedDownloadsHandler = (_ downloads: [SKDownload]) -> Void

public protocol TransactionHandle{
    func handleTransactions(_ transactions: [SKPaymentTransaction],_ paymentQueue:SKPaymentQueue) -> [SKPaymentTransaction]
}

public protocol AppPurchase{
    var shouldAddStorePaymentHandler: ShouldAddStorePaymentHandler?{set get}
    var updatedDownloadsHandler: UpdatedDownloadsHandler? {set get}
    func startPayment(_ payment: Payment)
    func restorePurchases(_ restorePurchases: RestorePurchases)
    func completeTransactions(_ completeTransactions: CompletePruchase)
    func finishTransaction(_ transaction: SKPaymentTransaction)
    func start(_ downloads: [SKDownload])
    func pause(_ downloads: [SKDownload])
    func resume(_ downloads: [SKDownload])
    func cancel(_ downloads: [SKDownload]) 
}

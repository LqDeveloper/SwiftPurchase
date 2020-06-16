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

public extension PurchaseTransaction{
    var original: SKPaymentTransaction? {
        return transaction.original
    }
    
    var error: Error? {
        return transaction.error
    }
    
    var productIdentifier: String {
        return transaction.payment.productIdentifier
    }
    
    var applicationUsername: String? {
        return transaction.payment.applicationUsername
    }
    
    var transactionDate: Date? {
        return transaction.transactionDate
    }
    
    var transactionIdentifier: String? {
        return transaction.transactionIdentifier
    }
    
    var transactionState: SKPaymentTransactionState {
        return transaction.transactionState
    }
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

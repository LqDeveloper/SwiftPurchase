//
//  PurchaseController.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

class PurchaseController: NSObject,AppPurchase, SKPaymentTransactionObserver {
    ///管理购买
    private let paymentsController: PaymentsController
    ///管理restore
    private let restoreController: RestoreController
    ///管理已经完成但是没有移除的
    private let completeController: CompleteController
    ///SKPaymentQueue.default()
    unowned let paymentQueue: SKPaymentQueue
    
    var shouldAddStorePaymentHandler: ShouldAddStorePaymentHandler?
    var updatedDownloadsHandler: UpdatedDownloadsHandler?
    
    init(paymentQueue: SKPaymentQueue = SKPaymentQueue.default(),
         paymentsController: PaymentsController = PaymentsController(),
         restoreController: RestoreController = RestoreController(),
         completeController: CompleteController = CompleteController()) {
        self.paymentQueue = paymentQueue
        self.paymentsController = paymentsController
        self.restoreController = restoreController
        self.completeController = completeController
        super.init()
        paymentQueue.add(self)
    }
    
    deinit {
        paymentQueue.remove(self)
    }
    
    /// 购买产品
    /// - Parameter payment: 购买配置
    func startPayment(_ payment: Payment) {
        assertCompleteTransactionsWasCalled()
        let skPayment = SKMutablePayment(product: payment.product)
        skPayment.applicationUsername = payment.applicationUsername
        skPayment.quantity = payment.quantity
        
        #if os(iOS) || os(tvOS)
        if #available(iOS 8.3, tvOS 9.0, *) {
            skPayment.simulatesAskToBuyInSandbox = payment.simulatesAskToBuyInSandbox
        }
        #endif
        paymentQueue.add(skPayment)
        paymentsController.append(payment)
    }
    
    func restorePurchases(_ restorePurchases: RestorePurchases) {
        assertCompleteTransactionsWasCalled()
        if restoreController.restore != nil {
            return
        }
        paymentQueue.restoreCompletedTransactions(withApplicationUsername: restorePurchases.applicationUsername)
        restoreController.restore = restorePurchases
    }
    
    func completeTransactions(_ completeTransactions: CompletePruchase) {
        guard completeController.completeTransactions == nil else {
            print("completeTransactions() 已经设置过了")
            return
        }
        
        completeController.completeTransactions = completeTransactions
    }
    
    func assertCompleteTransactionsWasCalled() {
        let message = "completeTransactions() 在应用启动的时候回去调用"
        assert(completeController.completeTransactions != nil, message)
    }
    
    
    
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
    }
    
    func start(_ downloads: [SKDownload]) {
        paymentQueue.start(downloads)
    }
    
    func pause(_ downloads: [SKDownload]) {
        paymentQueue.pause(downloads)
    }
    
    func resume(_ downloads: [SKDownload]) {
        paymentQueue.resume(downloads)
    }
    
    func cancel(_ downloads: [SKDownload]) {
        paymentQueue.cancel(downloads)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var unhandled = transactions.filter { $0.transactionState != .purchasing }
        if unhandled.count > 0 {
            //如果不是通过这次启动APP购买的（paymentsController的payments没用这个Payment）不会处理
            unhandled = paymentsController.handleTransactions(transactions, queue)
            //如果不是通过这次启动APP点击restore（restoreController的restore为nil）的不会处理
            unhandled = restoreController.handleTransactions(unhandled, queue)
            //下面completeController处理的都是没有处理过（没用finish掉的）的，
            unhandled = completeController.handleTransactions(unhandled, queue)
            if unhandled.count > 0 {
                for trans in unhandled {
                    print("没有处理的订单 产品ID:\(trans.payment.productIdentifier) 订单状态:\(trans.transactionState)")
                }
                
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreController.restoreCompletedTransactionsFailed(withError: error)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        restoreController.restoreCompletedTransactionsFinished()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        updatedDownloadsHandler?(downloads)
    }
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return shouldAddStorePaymentHandler?(payment, product) ?? false
    }
    #endif
}

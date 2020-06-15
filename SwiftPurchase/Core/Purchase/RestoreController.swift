//
//  RestoreController.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public extension Array where Element == RestoreResult{
    var successResults:[RestoreResult]{
        return filter { (result) -> Bool in
            return result.isSuccess
        }
    }
    
    var errorResult:RestoreResult?{
        return filter { (result) -> Bool in
            return !result.isSuccess
        }.first
    }
    
    func sortResult(_ compareType:ComparisonResult = .orderedDescending) -> [RestoreResult]{
        successResults.sorted { (r1,r2 ) -> Bool in
            guard let date1 = r1.purchase?.transaction.transactionDate ,let date2 = r2.purchase?.transaction.transactionDate else{
                return false
            }
            return date1.compare(date2) == compareType
        }
    }
}

public struct RestorePurchases {
    let atomically: Bool
    let applicationUsername: String?
    let callback: RestoreCallback
    
    init(atomically: Bool, applicationUsername: String? = nil, callback: @escaping RestoreCallback) {
        self.atomically = atomically
        self.applicationUsername = applicationUsername
        self.callback = callback
    }
}

class RestoreController: TransactionHandle {
    public var  restore: RestorePurchases?
    private var restoredResults: [RestoreResult] = []
    
    func handleTransaction(_ transaction: SKPaymentTransaction, atomically: Bool, on paymentQueue: SKPaymentQueue) -> Purchase? {
        let transactionState = transaction.transactionState
        if transactionState == .restored {
            let resrore = Purchase.init(transaction: transaction, needFinish: !atomically)
            if atomically {
                paymentQueue.finishTransaction(transaction)
            }
            return resrore
        }
        return nil
    }
    
    func handleTransactions(_ transactions: [SKPaymentTransaction], _ paymentQueue: SKPaymentQueue) -> [SKPaymentTransaction] {
        guard let restorePurchases = restore else {
            return transactions
        }
        
        var unhandle: [SKPaymentTransaction] = []
        for transaction in transactions {
            if let restoredPurchase = handleTransaction(transaction, atomically: restorePurchases.atomically, on: paymentQueue) {
                restoredResults.append(.success(restoredPurchase))
            } else {
                unhandle.append(transaction)
            }
        }
        return unhandle
    }
    
    func restoreCompletedTransactionsFailed(withError error: Error) {
        guard let restorePurchases = restore else {
            print("restore已经处理过了")
            return
        }
        restoredResults.append(.failure(SKError(_nsError: error as NSError)))
        restorePurchases.callback(restoredResults)
        
        restoredResults = []
        restore = nil
    }
    
    func restoreCompletedTransactionsFinished() {
        guard let restorePurchases = restore else {
            print("restore已经处理过了")
            return
        }
        restorePurchases.callback(restoredResults)
        
        restoredResults = []
        restore = nil
    }
}

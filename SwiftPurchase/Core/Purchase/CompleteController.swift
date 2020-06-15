//
//  CompleteController.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public extension Array where Element == Purchase{
    var purchased:[Purchase]{
        return filter { (purchase) -> Bool in
            return purchase.transaction.transactionState == .purchased
        }
    }
    
    var failed:[Purchase]{
        return filter { (purchase) -> Bool in
            return purchase.transaction.transactionState == .failed
        }
    }
    
    var restored:[Purchase]{
        return filter { (purchase) -> Bool in
            return purchase.transaction.transactionState == .restored
        }
    }
    
    var deferred:[Purchase]{
        return filter { (purchase) -> Bool in
            return purchase.transaction.transactionState == .deferred
        }
    }
}

public struct CompletePruchase {
    let atomically: Bool
    let callback: CompleteCallback
    
    init(atomically: Bool, callback: @escaping CompleteCallback) {
        self.atomically = atomically
        self.callback = callback
    }
}

class CompleteController: TransactionHandle {
    var completeTransactions: CompletePruchase?
    
    func handleTransactions(_ transactions: [SKPaymentTransaction], _ paymentQueue: SKPaymentQueue) -> [SKPaymentTransaction] {
        guard let completeTransactions = completeTransactions else {
            return transactions
        }
        
        var unhandle: [SKPaymentTransaction] = []
        var purchases: [Purchase] = []
        
        for transaction in transactions {
            
            let transactionState = transaction.transactionState
            
            if transactionState != .purchasing {
                
                let shouldFinish = completeTransactions.atomically || transactionState == .failed
                let purchase = Purchase.init(transaction: transaction, needFinish: !shouldFinish)
                purchases.append(purchase)
                
                if shouldFinish {
                    print("Finish订单 产品ID \(transaction.payment.productIdentifier) 订单状态: \(transactionState)")
                    paymentQueue.finishTransaction(transaction)
                }
            } else {
                unhandle.append(transaction)
            }
        }
        if purchases.count > 0 {
            completeTransactions.callback(purchases)
        }
        return unhandle
    }
}

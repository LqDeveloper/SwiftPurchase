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
        
        var unhandledTransactions: [SKPaymentTransaction] = []
        var purchases: [Purchase] = []
        
        for transaction in transactions {
            
            let transactionState = transaction.transactionState
            
            if transactionState != .purchasing {
                
                let willFinishTransaction = completeTransactions.atomically || transactionState == .failed
                let purchase = Purchase.init(transaction: transaction, needFinish: !willFinishTransaction)
                purchases.append(purchase)
                
                if willFinishTransaction {
                    print("Finishing transaction for payment \"\(transaction.payment.productIdentifier)\" with state: \(transactionState)")
                    paymentQueue.finishTransaction(transaction)
                }
            } else {
                unhandledTransactions.append(transaction)
            }
        }
        if purchases.count > 0 {
            completeTransactions.callback(purchases)
        }
        return unhandledTransactions
    }
}

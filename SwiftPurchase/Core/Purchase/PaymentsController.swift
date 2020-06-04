//
//  PaymentsController.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public struct Payment: Hashable {
    let product: SKProduct
    let quantity: Int
    let atomically: Bool
    let applicationUsername: String
    let simulatesAskToBuyInSandbox: Bool
    let callback: PurchaseCallback
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(product)
        hasher.combine(quantity)
        hasher.combine(atomically)
        hasher.combine(applicationUsername)
        hasher.combine(simulatesAskToBuyInSandbox)
    }
    
    public static func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.product.productIdentifier == rhs.product.productIdentifier
    }
}

class PaymentsController:TransactionHandle {
    private var payments: [Payment] = []
    
    private func findPaymentIndex(withProductIdentifier identifier: String) -> Int? {
        for payment in payments where payment.product.productIdentifier == identifier {
            return payments.firstIndex(of: payment)
        }
        return nil
    }
    
    func hasPayment(_ payment: Payment) -> Bool {
        return findPaymentIndex(withProductIdentifier: payment.product.productIdentifier) != nil
    }
    
    func append(_ payment: Payment) {
        payments.append(payment)
    }
    
    func remove(_ payment: Payment){
        guard let index = findPaymentIndex(withProductIdentifier: payment.product.productIdentifier) else {
            return
        }
        payments.remove(at: index)
    }
    
    func processTransaction(_ transaction: SKPaymentTransaction, on paymentQueue: SKPaymentQueue) -> Bool {
        let productIdentifier = transaction.payment.productIdentifier
        
        guard let paymentIndex = findPaymentIndex(withProductIdentifier: productIdentifier) else {
            return false
        }
        let payment = payments[paymentIndex]
        
        let transactionState = transaction.transactionState
        
        if transactionState == .purchased {
            payment.callback(.success(PurchaseSuccess.init(product:payment.product,transaction: transaction, needFinish: !payment.atomically)))
            
            if payment.atomically {
                paymentQueue.finishTransaction(transaction)
            }
            payments.remove(at: paymentIndex)
            return true
        }
        
        if transactionState == .failed {
            if let error = transaction.error as NSError? {
                payment.callback(.failure(SKError(_nsError: error)))
            }else{
                payment.callback(.failure(SKError.createError(.unknown,"Unknown error")))
            }
            paymentQueue.finishTransaction(transaction)
            payments.remove(at: paymentIndex)
            return true
        }
        
        if transactionState == .restored {
            print("Unexpected restored transaction for payment \(productIdentifier)")
        }
        return false
    }
    
    func handleTransactions(_ transactions: [SKPaymentTransaction], _ paymentQueue: SKPaymentQueue) -> [SKPaymentTransaction] {
        return transactions.filter { !processTransaction($0, on: paymentQueue) }
    }
}

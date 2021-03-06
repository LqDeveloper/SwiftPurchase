//
//  RxSwiftPurchase.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/3.
//  Copyright © 2020 Quan.Li. All rights reserved.
//
import Foundation
import RxSwift
import StoreKit
extension SwiftPurchase:ReactiveCompatible{}
//获取产品
public extension Reactive where Base == SwiftPurchase{
    static func requestInfo(_ productIds: [String]) -> Single<ProductInfo>{
        return Single.create { (single) -> Disposable in
            Base.requestProductsInfo(productIds) { (result) in
                switch result{
                case .success(let info):
                    single(.success(info))
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create {
                Base.cancleRequest(productIds)
            }
        }
    }
}

//刷新和获取Receipt
public extension Reactive where Base == SwiftPurchase {
    static func fetchReceipt(forceRefresh: Bool = false) -> Single<Data?>{
        return Single.create { (single) -> Disposable in
            Base.fetchReceipt(forceRefresh: forceRefresh) { (result) in
                switch result{
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create {
                Base.cancleFetchReceipt()
            }
        }
    }
    
    static func verifyReceipt(verifyType:VerifyReceiptType = .production,sharedSecret: String? = nil,excludeOldTransactions:Bool = false,receiptData: Data) -> Single<ReceiptInfo>{
        return Single.create { (single) -> Disposable in
            let task = Base.verifyReceipt(verifyType: verifyType, sharedSecret: sharedSecret, excludeOldTransactions: excludeOldTransactions, receiptData: receiptData) { (result) in
                switch result{
                case .success(let info):
                    single(.success(info))
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
        
    }
}


//购买
public extension Reactive where Base == SwiftPurchase {
    static func purchase( product: SKProduct, quantity: Int = 1, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false,paymentDiscount: PaymentDiscount? = nil) -> Single<PaymentInfo>{
        return Single.create { (single) -> Disposable in
            Base.purchase(product, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox,paymentDiscount:paymentDiscount) { (result) in
                switch result{
                case .success(let model):
                    single(.success(model))
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create {}
        }
    }
}


//恢复
public extension Reactive where Base == SwiftPurchase {
    static func restore(atomically: Bool = true, applicationUsername: String = "") -> Single<[RestoreResult]>{
        return Single.create { (single) -> Disposable in
            Base.restorePurchases(atomically: atomically, applicationUsername: applicationUsername) { (result) in
                single(.success(result))
            }
            return Disposables.create {}
        }
    }
}


//完成
public extension Reactive where Base == SwiftPurchase {
    static func complete(atomically: Bool = true) -> Single<[Purchase]>{
        return Single.create { (single) -> Disposable in
            Base.completeTransactions(atomically: atomically) { (result) in
                single(.success(result))
            }
            return Disposables.create {}
        }
    }
}


public extension Reactive where Base == SwiftPurchase {
    @available(iOS 14, tvOS 14, OSX 11, watchOS 7, macCatalyst 14, *)
    static func entitlementRevocation() -> Single<[String]>{
        return Single.create { (single) -> Disposable in
            Base.onEntitlementRevocation { productIds in
                single(.success(productIds))
            }
            return Disposables.create {}
        }
    }
}

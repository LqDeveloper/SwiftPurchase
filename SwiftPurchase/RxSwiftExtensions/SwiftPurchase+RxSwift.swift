//
//  PurchaseManager+RxSwift.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/3.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import RxSwift
import RxCocoa
import StoreKit
extension SwiftPurchase:ReactiveCompatible{}
//获取产品
public extension Reactive where Base == SwiftPurchase{
    static func requestInfoWithSingle(_ productIds: [String]) -> Single<ProductInfo>{
        return Single.create { (single) -> Disposable in
            Base.requestProductsInfo(productIds) { (result) in
                switch result{
                case .success((let products, let invalidProductIDs)):
                    single(.success((products:products, invalidProductIDs:invalidProductIDs)))
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create {
                Base.cancleRequest(productIds)
            }
        }
    }
    
    static func requestInfoWithDriver(_ productIds: [String]) -> Driver<ProductInfoReuslt>{
        return Single.create { (single) -> Disposable in
            Base.requestProductsInfo(productIds) { (result) in
                single(.success(result))
            }
            return Disposables.create {
                Base.cancleRequest(productIds)
            }
        }.asDriver(onErrorJustReturn: .failure(SKError.createError(.unknown, "unknown error")))
    }
}

//刷新和获取Receipt
public extension Reactive where Base == SwiftPurchase {
    static func fetchReceiptWithSingle(forceRefresh: Bool = false) -> Single<Data?>{
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
    
    static func fetchReceiptWithDriver(forceRefresh: Bool = false) -> Driver<ReceiptDataResult>{
        return Single.create { (single) -> Disposable in
            Base.fetchReceipt(forceRefresh: forceRefresh) { (result) in
                single(.success(result))
            }
            return Disposables.create {
                Base.cancleFetchReceipt()
            }
        }.asDriver(onErrorJustReturn: .failure(.noReceiveData))
    }
    
    
    static func verifyReceiptWithSingle(verifyType:VerifyReceiptType = .production,sharedSecret: String? = nil,excludeOldTransactions:Bool = false,receiptData: Data) -> Single<ReceiptInfo>{
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
    
    static func verifyReceiptWithDriver(verifyType:VerifyReceiptType = .production,sharedSecret: String? = nil,excludeOldTransactions:Bool = false,receiptData: Data) -> Driver<VerifyReceiptResult>{
        return Single.create { (single) -> Disposable in
            let task = Base.verifyReceipt(verifyType: verifyType, sharedSecret: sharedSecret, excludeOldTransactions: excludeOldTransactions, receiptData: receiptData) { (result) in
                single(.success(result))
            }
            return Disposables.create {
                task?.cancel()
            }
        }.asDriver(onErrorJustReturn: .failure(.noReceiveData))
        
    }
}


//购买
public extension Reactive where Base == SwiftPurchase {
    static func purchaseWithSingle( product: SKProduct, quantity: Int = 1, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false) -> Single<PaymentSuccess>{
        return Single.create { (single) -> Disposable in
            Base.purchaseProduct(product, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox) { (result) in
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
    
    
    static func purchaseWithDriver(_ product: SKProduct, quantity: Int = 1, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false) -> Driver<PaymentResult>{
        return Single.create { (single) -> Disposable in
            Base.purchaseProduct(product, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox) { (result) in
                single(.success(result))
            }
            return Disposables.create {}
        }.asDriver(onErrorJustReturn: .failure(SKError.createError(.unknown, "unknown error")))
    }
}


//恢复
public extension Reactive where Base == SwiftPurchase {
    static func restoreWithSingle(atomically: Bool = true, applicationUsername: String = "") -> Single<[RestoreResult]>{
        return Single.create { (single) -> Disposable in
            Base.restorePurchases(atomically: atomically, applicationUsername: applicationUsername) { (result) in
                single(.success(result))
            }
            return Disposables.create {}
        }
    }
    
    static func restoreWithDriver(atomically: Bool = true, applicationUsername: String = "") -> Driver<[RestoreResult]>{
        return restoreWithSingle(atomically: atomically, applicationUsername: applicationUsername).asDriver(onErrorJustReturn: [])
    }
}


//完成
public extension Reactive where Base == SwiftPurchase {
    static func completeWithSingle(atomically: Bool = true) -> Single<[Purchase]>{
        return Single.create { (single) -> Disposable in
            Base.completeTransactions(atomically: atomically) { (result) in
                single(.success(result))
            }
            return Disposables.create {}
        }
    }
    
    static func completeWithDriver(atomically: Bool = true) -> Driver<[Purchase]>{
        return completeWithSingle(atomically: atomically).asDriver(onErrorJustReturn: [])
    }
}

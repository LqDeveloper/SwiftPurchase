//
//  ResultExtensions.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/2.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public extension Result where Success == ProductInfo{
    var products:[SKProduct]{
        switch self {
        case .success((let products,_)):
            return products
        case .failure(_):
            return []
        }
    }
    
    var invalidProductIDs:[String]{
        switch self {
        case .success((_, let invalidProductIDs)):
            return invalidProductIDs
        case .failure(_):
            return []
        }
    }
}

public extension Result where Success == Data?{
    var data:Data?{
        switch self {
        case .success(let data):
            return data
        case .failure(_):
            return nil
        }
    }
}


public extension Result where Success == PaymentSuccess{
    var paySuccess:PaymentSuccess?{
        switch self {
        case .success(let result):
            return result
        case .failure(_):
            return nil
        }
    }
}


public extension Result where Success == Purchase{
    var purchase:Purchase?{
        switch self {
        case .success(let result):
            return result
        case .failure(_):
            return nil
        }
    }
}



public extension Result where Failure == SKError{
    var error:SKError?{
        switch self {
        case .success(_):
            return nil
        case .failure(let error):
            return error
        }
    }
}

public extension Result where Failure == Error{
    var error:Error?{
        switch self {
        case .success(_):
            return nil
        case .failure(let error):
            return error
        }
    }
}

public extension Result {
    var isSuccess:Bool{
        switch self {
        case .success(_):
            return true
        case .failure(_):
            return false
        }
    }
}

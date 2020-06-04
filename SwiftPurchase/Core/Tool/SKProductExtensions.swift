//
//  SKProductExtensions.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/3.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public extension SKProduct {
    var localizedPrice: String? {
        return priceFormatter(locale: priceLocale).string(from: price)
    }
    
    private func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
    
    var  currency:String{
        return priceLocale.currencyCode ?? ""
    }
}

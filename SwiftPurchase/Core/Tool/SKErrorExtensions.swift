//
//  SKErrorExtension.swift
//  SwiftPurchaseManager
//
//  Created by Quan Li on 2020/6/1.
//  Copyright © 2020 Quan.Li. All rights reserved.
//

import StoreKit

public extension SKError{
    static func createError(_ code:SKError.Code = .unknown,_ desc:String = "") -> SKError{
        let error = NSError(domain: SKErrorDomain, code: code.rawValue, userInfo: [ NSLocalizedDescriptionKey: desc ])
        return SKError(_nsError: error)
    }
    
    
    var errorDesc:String{
        switch code {
        case .unknown:
            return "未知错误"
        case .clientInvalid:
            return "不允许客户端执行操作"
        case .paymentCancelled:
            return "用户取消了付款请求"
        case .paymentInvalid:
            return "订单中某个参数不能被App Store识别"
        case .paymentNotAllowed:
            return "不允许用户授权付款"
        case .storeProductNotAvailable:
            return "所请求的产品在商店中不可用"
        case .cloudServicePermissionDenied:
            return "用户不允许访问云服务信息"
        case .cloudServiceNetworkConnectionFailed:
            return "设备无法连接到网络"
        case .cloudServiceRevoked:
            return "用户已撤消使用此云服务的权限"
        case .privacyAcknowledgementRequired:
            return "用户尚未确认Apple的Apple Music隐私政策"
        case .unauthorizedRequestData:
            return "应用程序正在尝试使用其不具备必需权利的属性"
        case .invalidOfferIdentifier:
            return "商品标识符无效"
        case .invalidSignature:
            return "付款折扣中的签名无效"
        case .missingOfferParams:
            return "付款折扣中缺少参数"
        case .invalidOfferPrice:
            return "您在App Store Connect中指定的价格不再有效"
        case .overlayCancelled:
            return "取消覆盖的错误代码"
        case .overlayInvalidConfiguration:
            return "叠加层配置的错误代码无效"
        case .overlayTimeout:
            return "覆盖超时"
        case .ineligibleForOffer:
            return "用户不符合订阅条件"
        case .unsupportedPlatform:
            return "当前平台不支持叠加层"
        case .overlayPresentedInBackgroundScene:
            return "客户端尝试在UIWindowScene中显示SKOverlay，而不是在前景中显示"
        @unknown default:return "未知错误"
        }
    }
}

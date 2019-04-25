//
//  LTV.swift
//  LTV
//
//  Created by Igor Khmurets on 9/24/17.
//  Copyright © 2017 dp. All rights reserved.
//

//import Foundation
//import AdSupport
//import StoreKit
//import AppsFlyerLib
//import YandexMobileMetrica
//import SwiftyStoreKit
//
//class UserAcquisition: NSObject {
//
//    static let shared = UserAcquisition()
//
//    private var conversionInfo = UserAcquisition.Info()
//
//    func logPurchase(of product: SKProduct) {
//        var receipt: String?
//        let group = DispatchGroup()
//        group.enter()
//        YMMYandexMetrica.requestAppMetricaDeviceID(withCompletionQueue: .main) { [unowned self] id, error in
//            self.conversionInfo.appmetricaId = id ?? ""
//            group.leave()
//        }
//        group.enter()
//        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
//            switch result {
//            case .success(let receiptData):
//                receipt = receiptData.base64EncodedString()
//            case .error(let error):
//                print(error)
//                break
//            }
//            group.leave()
//        }
//        group.notify(queue: .global()) {
//            if let receipt = receipt {
//                self.logPurchase(info: self.conversionInfo, product: product, receipt: receipt)
//            }
//        }
//    }
//
//    func setExtraValue(_ value: Any, forKey key: String) {
//        conversionInfo.extra[key] = value
//    }
//
//    private func logPurchase(info: Info, product: SKProduct, receipt: String) {
//        var acquisitionSource: String {
//            switch info.acquisitionSource {
//            case .facebook:
//                return "Facebook"
//            case .searchAds:
//                return "Search Ads"
//            case .organic:
//                return "Organic"
//            case let .custom(source):
//                return source
//            }
//        }
//        var afi: String? {
//            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
//                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
//            } else {
//                return nil
//            }
//        }
//        let iap: [String: Any] = [
//            "product_id": product.productIdentifier,
//            "price": product.price.doubleValue,
//            "currency": product.priceLocale.currencyCode ?? "",
//        ]
//        var extra: [String: Any] = [
//            "acquisition_source": acquisitionSource,
//            "acquisition_date": Int(info.acquisitionDate.timeIntervalSince1970),
//            "ad_campaign": info.adCampaign,
//            "ad_group": info.adGroup,
//            "ad_creative": info.adCreative,
//            "vendor_id": UIDevice.current.identifierForVendor?.uuidString ?? "",
//            "appsflyer_id": info.appsFlyerId,
//            "appmetrica_device_id": info.appmetricaId,
//        ]
//        for (field, value) in info.extra {
//            extra[field] = value
//        }
//        let params: [String: Any?] = [
//            "bundle_id": Bundle.main.bundleIdentifier ?? "",
//            "afi": afi,
//            "receipt": receipt,
//            "iap": iap,
//            "country": product.priceLocale.regionCode ?? "",
//            "extra": extra,
//        ]
//        var request = URLRequest(url: URL(string: "https://app-subscriptions.pocketmoon.me/api/receipt")!)
//        request.httpMethod = "POST"
//        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        URLSession.shared.dataTask(with: request) { data, resp, error in
//            guard let data = data, let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
//                return
//            }
//            print(json)
//        }.resume()
//    }
//}
//
//extension UserAcquisition: AppsFlyerTrackerDelegate {
//    func onConversionDataReceived(_ installData: [AnyHashable : Any]!) {
//        if let data = installData as? [String: Any] {
//            conversionInfo.setAppsFlyerData(data)
//        }
//    }
//}
//
//extension UserAcquisition {
//    var isConversionUser: Bool {
//        if case .organic = UserAcquisition.shared.conversionInfo.acquisitionSource {
//            return false
//        } else {
//            return true
//        }
//    }
//}
//
//extension UserAcquisition {
//    struct Info {
//        enum AcquisitionSource {
//            case organic, facebook, searchAds, custom(String)
//        }
//        var userId: String?
//        var acquisitionSource: AcquisitionSource = .organic
//        var acquisitionDate = Date()
//        var adCampaign = ""
//        var adGroup = ""
//        var adCreative = ""
//        var appsFlyerId = ""
//        var appmetricaId = ""
//        var extra = [String: Any]()
//
//        mutating func setAppsFlyerData(_ appsFlyerData: [String: Any]) {
//            let status = appsFlyerData["af_status"] as? String ?? ""
//            let source = appsFlyerData["media_source"] as? String ?? ""
//            let campaign = appsFlyerData["campaign"] as? String ?? ""
//            let campaignId = appsFlyerData["campaign_id"] as? String ?? ""
//            let adSet = appsFlyerData["adset"] as? String ?? ""
//            let adSetId = appsFlyerData["adset_id"] as? String ?? ""
//            let ad = appsFlyerData["ad"] as? String ?? ""
//            let adId = appsFlyerData["ad_id"] as? String ?? ""
//            print(appsFlyerData)
//            var acquisitionSource: UserAcquisition.Info.AcquisitionSource {
//                switch status {
//                case "Non-organic":
//                    switch source {
//                    case "Facebook Ads":
//                        return .facebook
//                    default:
//                        return .custom(source)
//                    }
//                case "Organic":
//                    return .organic
//                default:
//                    return .custom("Undefined")
//                }
//            }
//            var acquisitionDate: Date {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-DD mm:HH:ss.SSS"
//                return formatter.date(from: appsFlyerData["install_time"] as? String ?? "") ?? Date()
//            }
//            func merged(_ str1: String, _ str2: String) -> String {
//                if str2 == "" {
//                    return str1
//                } else {
//                    return "\(str1) (\(str2))"
//                }
//            }
//            self.acquisitionSource = acquisitionSource
//            self.acquisitionDate = acquisitionDate
//            self.adCampaign = merged(campaign, campaignId)
//            self.adGroup = merged(adSet, adSetId)
//            self.adCreative = merged(ad, adId)
//            self.appsFlyerId = AppsFlyerTracker.shared().getAppsFlyerUID() ?? ""
//        }
//    }
//}

class HELLOWORLD {
    
    static var someValue = 1
    
}

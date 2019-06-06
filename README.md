# UserAcquisition

[![CI Status](https://img.shields.io/travis/Mikhail Verenich/UserAcquisition.svg?style=flat)](https://travis-ci.org/Mikhail Verenich/UserAcquisition)
[![Version](https://img.shields.io/cocoapods/v/UserAcquisition.svg?style=flat)](https://cocoapods.org/pods/UserAcquisition)
[![License](https://img.shields.io/cocoapods/l/UserAcquisition.svg?style=flat)](https://cocoapods.org/pods/UserAcquisition)
[![Platform](https://img.shields.io/cocoapods/p/UserAcquisition.svg?style=flat)](https://cocoapods.org/pods/UserAcquisition)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

UserAcquisition is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UserAcquisition', :git => "https://github.com/97mik/UserAcquisition.git"
```

## Usage
In didFinishLaunchingWithOptions method:
```swift
UserAcquisition.shared.configure(withAPIKey: "APIKey")
```
After successful purchase:
```swift
UserAcquisition.shared.logPurchase(of: product)
```
Add AppsFlyer:
```swift
import AppsFlyerLib

extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataReceived(_ installData: [AnyHashable : Any]!) {
        if let data = installData as? [String: Any] {
            UserAcquisition.shared.conversionInfo.setAppsFlyerData(data)
            UserAcquisition.shared.conversionInfo.appsFlyerId = AppsFlyerTracker.shared().getAppsFlyerUID() ?? ""
        }
    }
}
```
Add Adjust:
```swift
import Adjust

extension AppDelegate: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        if let data = attribution?.dictionary() {
            UserAcquisition.shared.conversionInfo.setAdjustData(data)
        }
    }
}
```
Add YandexMetrica:
```swift
import YandexMobileMetrica

YMMYandexMetrica.requestAppMetricaDeviceID(withCompletionQueue: .main) { [unowned self] id, error in
    UserAcquisition.shared.conversionInfo.appmetricaId = id ?? ""
}
```

## Author

Mikhail Verenich, 97mik@mail.ru

## License

UserAcquisition is available under the MIT license. See the LICENSE file for more info.

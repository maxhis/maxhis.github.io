---
layout: post
title: "将iOS付费App转换成免费加内购模式的最佳实践"
date: 2017-10-09 15:00:00 +0800
category: iOS
tags: iOS App IAP
---

前段时间上线我的第一个收费App——[瓦工助手](https://itunes.apple.com/app/id1267833691)，虽然有下载，但一天一两个的下载量实在是有点太少。于是打算把付费下载改成付费加应用内购买的模式，看看下载量和收益是否有提升。下面记录一下将收费改成免费加内购的最佳实现方式。

因为是之前是付费下载的，让已购买的用户再来应用内购买是不合适的，所以需要解决的一个核心问题是如何识别用户是否已经购买过App。

Apple提供了API(appStoreReceiptURL)可以获取App购买的Receipt，包括App购买和In App Purchase，具体文档可以参考官方的 [Receipt Validation Programming Guide
](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Introduction.html)。简单来说，appStoreReceiptURL会返回App的购买的版本(original_application_version)及应用内购买的详细信息（in_app），这里关键的是original_application_version，它记录的是用户下载App时的应用版本，对应App的CFBundleVersion（注意不是CFBundleShortVersionString），而且只在App Store版本的App上才会返回正确的值，其它情况返回的都是1.0，连TestFlight也是，这个很不方便调试。

通过比对original_application_version与启用IAP的第一个版本号就可以方便的控制是否需要应用内购买了。

如果自己手动去请求appStoreReceiptURL获取receipt信息会比较麻烦，这里我使用的是一个第三方库：[SwiftyStoreKit]()，大大简化了流程，推荐使用！

使用SwiftyStoreKit只需要下面简单的代码就能够获取Receipt信息了：

```swift
let appleValidator = AppleReceiptValidator(service: .production)
SwiftyStoreKit.verifyReceipt(using: appleValidator, password: Constants.iapSharedSecret, forceRefresh: false) { result in
    switch result {
    case .success(let receipt):
        log.info("Verify receipt Success: \(receipt)")
        
        let receiptJSON = JSON(receipt)
        
        // 是否之前付费下载
        if let orignalVersion = receiptJSON["receipt"]["original_application_version"].string,
            Int(orignalVersion) ?? 0 < Constants.iapStartVersion {
            IAPHelper.markPurchasedApp(purchased: true)
            log.info("Already purchased the App")
        } else {
            IAPHelper.markPurchasedApp(purchased: false)
        }
        
        // 是否应用内购买
        if let inAppReceipts = receiptJSON["receipt"]["in_app"].array,
            inAppReceipts.count > 0 {
            IAPHelper.markPurchasedInApp(purchased: true)
            log.info("Already in-app purchased")
        } else {
            IAPHelper.markPurchasedInApp(purchased: false)
        }
    case .error(let error):
        log.error("Verify receipt Failed: \(error)")
    }
}
```

简单介绍解释一下：

- `Constants.iapStartVersion`是内购开始的第一个版本，如果版本号小于这个值说明是下载的之前版本，直接跳过内购；
- 关于`in_app`的处理，因为我的App只有一个内购Item，所以这里只判断了数组的长度，你可能需要对product_id 进行更细致的处理；
- `IAPHelper`对整个逻辑做了简单封装，详细见这个[Gist](https://gist.github.com/15015545a5fa95397f0beedf0c6873a4)，应该可以拿来直接用。

> 说点题外话，瓦工助手从付费App改成免费加内购已经有一个星期左右的时间了，下载量确实呈指数级增长，但收入却下降了，这跟我的IAP设置有关，目前我的设置是管理一台VPS免费，管理多台VPS才需要内购，而大部分用户都是只有一台VPS的。所以，往往产品的设计比技术本身更重要。:)

很多人可能见不到production环境下的Receipt数据到底长啥样，在这里贴一个出来：
```javascript
["status": 0, "receipt": {
    "adam_id" = 1267833691;
    "app_item_id" = 1267833691;
    "application_version" = 31;
    "bundle_id" = "com.0x1024.Bandwagon";
    "download_id" = 62034015496213;
    "in_app" =     (
                {
            "is_trial_period" = false;
            "original_purchase_date" = "2017-10-08 02:55:13 Etc/GMT";
            "original_purchase_date_ms" = 1507431313000;
            "original_purchase_date_pst" = "2017-10-07 19:55:13 America/Los_Angeles";
            "original_transaction_id" = 220000373453498;
            "product_id" = "bangon_iap";
            "purchase_date" = "2017-10-08 02:55:13 Etc/GMT";
            "purchase_date_ms" = 1507431313000;
            "purchase_date_pst" = "2017-10-07 19:55:13 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 220000373453498;
        }
    );
    "original_application_version" = 31;
    "original_purchase_date" = "2017-10-08 02:47:56 Etc/GMT";
    "original_purchase_date_ms" = 1507430876000;
    "original_purchase_date_pst" = "2017-10-07 19:47:56 America/Los_Angeles";
    "receipt_creation_date" = "2017-10-08 02:55:13 Etc/GMT";
    "receipt_creation_date_ms" = 1507431313000;
    "receipt_creation_date_pst" = "2017-10-07 19:55:13 America/Los_Angeles";
    "receipt_type" = Production;
    "request_date" = "2017-10-09 02:35:01 Etc/GMT";
    "request_date_ms" = 1507516501916;
    "request_date_pst" = "2017-10-08 19:35:01 America/Los_Angeles";
    "version_external_identifier" = 823885941;
}, "environment": Production]
```



---
layout: post
title: "通过NSUbiquitousKeyValueStore实现数据的跨设备缓存"
date: 2018-11-12 20:30:00 +0800
category: iOS
tags: iOS iCloud
---

因为[搬瓦工App](https://itunes.apple.com/app/id1267833691)需要缓存的数据量很小，所以使用UserDefaults来缓存数据。昨天在[TG群](https://t.me/iBangon)里有用户提出能否实现iCloud跨设备的数据同步，这在有多个设备时非常有必要。于是花了点时间研究了一下iCloud相关的API，结果发现实现难度比我想象的要简单很多。

iCloud提供了以下三种不同类型的API：

- **Key-value storage**: 这是我最终采用的方式，以键值对的方式缓存数据，可存储的类型与UserDefaults一致，API也几乎一样。
- **Document storage**: 用来存储用户可见的文件，这种方式被很多App使用，如XMind、MWeb等，在iCloud Drive下可以直接看到文件。
- **Core Data storage**: 以CoreData的方式存储数据，其实就是数据库，当需要存储大量数据又不需要考虑跨平台（如Android）时会是不错的选择。
  
下面看Key-value storage，API很简单，几乎都在[NSUbiquitousKeyValueStore](https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore)里，看文档就知道如何使用了。这里重点说一下使用时需要注意的地方：

#### 0. 需要加入苹果开发者计划，也就是付费的开发者账号
这是必要条件。

#### 1. 在Xcode里打开iCloud选项，如下图：

![WX20181112-234805](/assets/img/WX20181112-234805.png)


注意勾选Key-value storage，一旦勾选会自动在项目中生成iCloud entitlements文件。

#### 2. 监听数据变化的Notification

因为需要与其它设备进行数据同步，当数据在其它地方改变后，需要能收到通知。示例代码如下：

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let keyStore = NSUbiquitousKeyValueStore.default
    if let stringValue = keyStore.string(forKey: "MyString") {
        textField.text = stringValue
    }

    NotificationCenter.default.addObserver(self,
         selector: #selector(
              ViewController.ubiquitousKeyValueStoreDidChange),
        name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
        object: keyStore)
}
```

至此，NSUbiquitousKeyValueStore的集成就算完成了，存储时，只需要将原来的`UserDefaults.standard`改成`NSUbiquitousKeyValueStore.default`就可以了，因为API设计是一样的。

另外，苹果的[文档](https://developer.apple.com/LIBRARY/IOS/documentation/Foundation/Reference/NSUbiquitousKeyValueStore_class/index.html)里有提到，离线时应该使用UserDefaults，而不是NSUbiquitousKeyValueStore.default，但根据我的使用来看，离线似乎也没有什么问题。

> Avoid using this class for data that is essential to your app’s behavior when offline; instead, store such data directly into the local user defaults database.

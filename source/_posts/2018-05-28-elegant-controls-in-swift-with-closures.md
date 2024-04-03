---
layout: post
title: "以Closure的方式优雅地为UIControl addTarget"
date: 2018-05-28 11:00:00 +0800
category: iOS
tags: iOS 开发小记 Swift
---

习惯了ES6的闭包，回到Swift下发现为UIButton手动添加一个点击事件，实在是太ugly，你得先定义一个方法(selector)，然后用OC时代的方式去call，最不方便的是传参数，尤其是你想使用本地变量的时候。

研究了一下，实现了以Closure的方式addTarget，方便了不少。

首先添加一个UIControl的extension，这样包括UIButton在内的所有子类都能使用：

```swift
import UIKit

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControlEvents, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func removeActions() {
        objc_removeAssociatedObjects(self)
    }
}
```

如何使用：

```swift
button.addAction(for: .touchUpInside) {
    print("Hello, Closure!")
}
```

避免循环引用：

```swift
self.button.addAction(for: .touchUpInside) { [weak self] in
    self?.doStuff()
}
```

**注意**

需要注意的一点是，如果是在UITableCell等控件中使用，因为控件的复用机制，稍不注意会addAction多次，建议在`prepareForReuse`方法中`removeActions`：

```swift
override func prepareForReuse() {
   button.removeActions()
}
```



---
layout: post
title: "iOS 13下threading violation: expected the main thread的分析及解决方法"
date: 2019-12-28 22:00:00 +0800
category: 技术
tags: [iOS]
---

公司项目在升级到iOS 13后频繁出现NSInternalInconsistencyException：
threading violation: expected the main thread的崩溃现象，在bugly上能看到不断上报的崩溃记录，但自己本地怎么都复现不了，看着很揪心。

### 问题分析

bugly上的错误堆栈信息如下，调用栈都是系统的API，只能分析分析看能不能找到一些蛛丝马迹了。

![](https://cdn.jsdelivr.net/gh/maxhis/assets@master/uPic/2019/12/28/laqIAk.png)

其中的`[UIDevice endGeneratingDeviceOrientationNotifications]`引起了我的注意，应该是因为某种原因在非主线程调用了这个方法，造成了threading violation。为了验证我的想法，我用hook的方式在调用`[UIDevice endGeneratingDeviceOrientationNotifications]`时检查当前是否为主线程，结果在某些情况下真的会出现。验证代码如下：

```objc
@implementation UIDevice (VK)

static inline void vk_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) {
            vk_swizzleSelector(UIDevice.class, @selector(endGeneratingDeviceOrientationNotifications), @selector(vk_EndGeneratingDeviceOrientationNotifications));
        }
    });
}

- (void)vk_EndGeneratingDeviceOrientationNotifications {
    NSLog(@"endGeneratingDeviceOrientationNotifications isMainThread:%d", [NSThread isMainThread]);
    [self endGeneratingDeviceOrientationNotifications];
}

@end
```

### 解决方法

既然知道了crash的原因，解决方法也就有了，在上述代码的基础上，把`[self endGeneratingDeviceOrientationNotifications]`放到主线程执行就好了，最终实现代码如下：

```objc
@implementation UIDevice (VK)

static inline void vk_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) {
            vk_swizzleSelector(UIDevice.class, @selector(endGeneratingDeviceOrientationNotifications), @selector(vk_EndGeneratingDeviceOrientationNotifications));
        }
    });
}

- (void)vk_EndGeneratingDeviceOrientationNotifications {
    if ([NSThread isMainThread]) {
        [self endGeneratingDeviceOrientationNotifications];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endGeneratingDeviceOrientationNotifications];
        });
    }
}
@end
```

### 真的只是iOS的锅？

Google一下，网上碰到类似问题的人很多，基本都是甩锅给iOS 13。可偏偏为什么是`[UIDevice endGeneratingDeviceOrientationNotifications]`会出现这个问题呢？我们知道，与之对应的方法是`[UIDevice beginGeneratingDeviceOrientationNotifications]`，需要成对使用。检查了一下代码，发现真的有一个地方多调用了一次endGeneratingDeviceOrientationNotifications，可能这才是问题的根本原因。
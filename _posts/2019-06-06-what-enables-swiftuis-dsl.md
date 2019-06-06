---
layout: post
title: "SwiftUI DSL背后的原理"
date: 2019-06-06 14:20:00 +0800
category: 技术
tags: [SwiftUI]
---

今年的WWDC应该是近几年最让开发者兴奋的一届，新发布的SwiftUI更是让社区一片欢腾，俨然开启了Apple app开发的新纪元。玩了一下SwiftUI，它抛弃了AutoLayout，放弃了Storyboard，带来了手写UI的丝滑体验。爽的同时，我们来看一下SwiftUI DSL到底是如何实现的。

在SwiftUI里我们方法看到了一种新的语法：

```swift
var body: some View {
    VStack(alignment: .leading) {
        Text("Hello, World") // No comma, no separator ?!
        Text("Hello World!")
    }
}
```

注意上面的两个Text直接是没有逗号或其它什么分隔符的，直接堆砌上去，这到底是怎么做到的？

以下内容来自StackOverflow，一些专用名词实在不好翻译成中文，就直接上英文了：

If you look at the documentation for [VStack](https://developer.apple.com/documentation/swiftui/vstack/)'s [init(alignment:spacing:content:)](https://developer.apple.com/documentation/swiftui/vstack/3278367-init), you can see that the content: parameter has the attribute `@ViewBuilder`:

```swift
init(alignment: HorizontalAlignment = .center, spacing: Length? = nil,
     @ViewBuilder content: () -> Content)
```

This attribute refers to the [ViewBuilder](https://developer.apple.com/documentation/swiftui/viewbuilder) type, which if you look at the generated interface, looks like:

```swift
@_functionBuilder public struct ViewBuilder {

    /// Builds an empty view from a block containing no statements, `{ }`.
    public static func buildBlock() -> EmptyView

    /// Passes a single view written as a child view (e..g, `{ Text("Hello") }`)
    /// through unmodified.
    public static func buildBlock(_ content: Content) -> Content 
      where Content : View
}
```

The `@_functionBuilder` attribute is a part of an unofficial feature called "[function builders](https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md)", which has been [pitched on Swift evolution here](https://forums.swift.org/t/pitch-function-builders/25167), and implemented specially for the version of Swift that ships with Xcode 11, allowing it to be used in SwiftUI.

Marking a type `@_functionBuilder` allows it to be used as a custom attribute on various declarations such as functions, computed properties and, in this case, parameters of function type. Such annotated declarations use the function builder to transform blocks of code:

- For annotated functions, the block of code that gets transformed is the implementation.
- For annotated computed properties, the block of code that gets transformed is the getter.
- For annotated parameters of function type, the block of code that gets transformed is any closure expression that is passed to it (if any).

The way in which a function builder transforms code is defined by its implementation of [builder methods](https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md#function-building-methods) such as `buildBlock`, which takes a set of expressions and consolidates them into a single value.

参考：[What enables SwiftUI's DSL?](https://stackoverflow.com/a/56435128/1150251)

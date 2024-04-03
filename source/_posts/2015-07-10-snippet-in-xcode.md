---
layout: post
title: "Snippet in Xcode"
description: "Snippet in Xcode"
category: iOS
tags: [XCode,Snippet]
---


在iOS开发中，不可避免地需要写很多重复的代码，让人印象最深刻的莫过于`UITableView`的dataSource和delegate方法了，每次都要手动输入一大堆方法（不由得想到了Android中的`findViewById` ：）。为了避免这种重复劳动，XCode提供了非常好用的Code Snippet功能。

<!--more-->

简单来说，XCode Snippet就是预先设置一些代码块，在使用时只需输入几个字母（shortcut）就可以在光标所在的地方粘贴这部分代码块。XCode自带就有一些常用的snippet，如GCD的`dispatch_after`。当自带的snippet不能满足需要时我们还可以自定义。

如何查看已有的snippet？非常简单，打开Utilities面板，在底部会看到如下一排按钮：

![Utilities](http://nshipster.s3.amazonaws.com/xcode-snippet-utilities-divider.png)

选中其中的`{}`就可以看到所有可用的snippet了。

![available snippets](http://nshipster.s3.amazonaws.com/xcode-snippet-utilties-panel.png)

自定义snippet的方法非常简单，只需要选中需要添加为snippet的代码块，拖到snippet列表就可以了。

如果觉得手动输太麻烦，大神[Mattt Thompson](https://github.com/mattt)(就是AFNetworking的作者)做了一个命令行工具`xcodesnippet`，可以很方便的安装已有的snippet。

首先需要安装`xcodesnippet`:

```ruby
$ gem install xcodesnippet
```
	
然后就可以通过命令行安装了：
```ruby
$ xcodesnippet install path/to/source.m
```
	
同时，Matt还提供了很多实用的snippet，可以选择性的安装使用：[Xcode-Snippets/Objective-C](https://github.com/Xcode-Snippets/Objective-C)

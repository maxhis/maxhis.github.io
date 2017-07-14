---
layout: post
title: "UIButton click event not working in custom view"
description: "UIButton click event not working in custom view"
category: iOS
tags: [UIKit]
---


今天在做一个很简单的功能：UITableView的空白页加一个UIButton，点击进行特定操作。很自然地想到把空白提示信息和这个按钮做成一个单独的自定义View（`MyCustomView:UIView`），三下五除二搞定，run一下UI效果还不错，可当我点击UIButton时，没有任何反应，按钮的点击事件没有触发！

<!--more-->

之前也碰到过控件点击效果不起作用的情况，那是因为View的父View为`UIImageView`，默认`userInteractionEnabled = NO`，可`MyCustomView`是继承自`UIView`的，不存在这个问题。

下面是我声明`MyCustomView`的代码：

```objc
MyCustomView *customView = [MyCustomView alloc] init];
...
[tableView addSubview:customView];
```
	
问题就出在我init的时候没有指定frame，所以customView的frame=[(0,0) 0,0]，在iOS中，如果子View没有在父View的frame范围内，任何touch事件都是不响应的，这就是问题UIButton点击没反应的原因。

对我这样的新手来说，这样的问题实在很隐蔽，与Android不同，iOS中子View即使不在父View的范围内，默认也能被显示出来，只是不响应事件。其实只要把`customView.clipsToBounds = YES`，不在父View的frame范围内的子View就不会被显示出来了。

一点经验教训：在使用自定义View时，一定要记得指定frame，如把上面的代码改成下面的这样：

```objc
MyCustomView *customView = [MyCustomView alloc] initWithFrame:CGRectMake(0, 0, DTScreenWidth, DTScreenHeight)];
...
[tableView addSubview:customView];
```
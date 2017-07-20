---
layout: post
title: "iOS开发的那些坑（一）"
subtitle: "解决UIButton在UICollectionViewCell里不能点击的问题"
date: 2017-07-20 23:00:00 +0800
category: iOS
tags: iOS 开发小记
---

> 准备做成一个系列，不定时更新，记录iOS开发中碰到的那些坑。

习惯了用XCode Interface Builder来开发iOS UI，方便快捷，但经常会碰到一些莫名其妙的坑，比如今天就碰到了在`UICollectionViewCell`中的`UIButton`不能响应点击事件(TouchUpInside)。

先说一下场景：`UICollectionViewCell`的UI是定义在一个xib文件里的，`UIButton`也是通过IB放在Cell里，然后对Cell里的控件建立了几个`IBOutlet`和`IBAction`，这里的`IBAction`就是上文里说的button点击事件。

所有的`IBOutlet`都工作正常，而`IBAction`死活不起作用。首先想到的是最外层的View block里子View的点击事件`userInteractionEnabled = NO`，检查了好几遍都没有。

后面在[Stack Overflow](https://stackoverflow.com/a/24626651/1150251)上看到可以用`hitTest`的方法检测当前的触点，如果是那个Button就在`pointInside`方法里返回true。这样确实是可行的，但是太麻烦，不是最优解。一个这么常见的操作出问题，十有八九是什么地方疏忽了，不到万不得已还是不要用`hitTest`和`pointInside`。

就这样磨了几个小时，后面发现原来问题出在我**创建`UICollectionViewCell`的xib文件时拖进去的root View是一个`UIView`，而不是`UICollectionViewCell`，虽然我后面在Identity Inspector里把class改成了`UICollectionViewCell`，但XCode仍然固执地认为它是一个`UIView`**，所以导致了UIButton不能点击的异常。

找到了原因，解决起来就快了，重新拖一个`UICollectionViewCell`作为xib的root View，然后把原来的页面元素copy进去，再处理一下因为copy导致的Auto Layout Constraints issue就一切正常了！



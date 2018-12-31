---
layout: post
title: "最简单的方式为UITableView添加empty view"
date: 2018-06-30 20:30:00 +0800
category: iOS
tags: iOS 开发小记 UITableView
---

在 UITableView 或 UICollectionView 列表数据为空时，我们一般会显示一些提示信息，姑且称它为 Empty View，这已经是很通用的做法了，但其实并没有通用的实现方式，至少 Apple 没有提供。在以前的项目中，我都是使用[DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)，功能很强大也比较容易集成，但毕竟是需要引入了一个第三方的库。

一种更简单的、不引入任何第三方库的实现方式是为UITableView 或 UICollectionView添加一个自定义的`backgroundView`作为 empty view，当 datasource 为空时就会显示出来，达到 Empty View 的效果。

上面的这种方式可能有一定 iOS 开发经验的人也知道，在这里再分享一种大部分人可能不知道的方式：和上面的原理是一样的，还是添加`backgroundView`，只是手写 UI 稍微有些麻烦，我们完全在 Interface Builder 里实现：

1. 在 Storyboard 中选中 UITableView 所在的scene；
2. 拖拽一个`UIView`到『Scene Dock』：![](/assets/img/2018-06-30-125819.jpg)
3. 此时可以往刚刚拖拽的view上添加内容，这里为了简单，只添加了一个 label。同时为这个view添加 IBOutlet，比如命名为`noItemsView`：![](/assets/img/2018-06-30-130253.jpg)
4. 将刚刚view 设置为 UITableView 的`backgroundView`：![](/assets/img/2018-06-30-130604.jpg)
5. Done！![](/assets/img/2018-06-30-130623.jpg)


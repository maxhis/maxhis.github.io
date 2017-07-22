---
layout: post
title: "UITableView - didSelectRowAtIndexPath not getting called"
description: "UITableView - didSelectRowAtIndexPath not working"
category: iOS
tags: [iOS,UIKit]
---


正在为[深圳通](https://itunes.apple.com/cn/app/id980164721?mt=8)增加多账户保存功能，使用了一个开源库——[LMDropdownView](https://github.com/lminhtm/LMDropdownView)，在点击标题栏时显示用户保存的所有账号，当用户点击选中其中一项之后，将内容自动填充到输入框中。大致效果如下，看似很简单的功能，结果做出来之后点击弹出的`UITableView`却死活没反应:

<!--more-->

![SZTool screenshot]({{ site.baseurl }}/assets/img/didSelectRowAtIndexPath-not-working2.png)

为了解决这个问题，昨晚搞到了两点多，好在后来还是找到了问题所在，原因很隐蔽，记录下来，希望能帮到碰到同样问题的同学。

情况是这样的，我这个页面都是让用户输入账户信息的，所以页面上基本上都是`UITextField`，本着人性化的作风，我做了一个处理：当用户点击空白区域时自动关闭键盘。实现代码如下：

```objc
[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}
```

问题就出在`[self.view addGestureRecognizer:]`，因为给`self.view`添加了gesture recognisers，它会屏蔽由`self.view`添加在其上的子View的touch事件，我的弹出UITableView正是在`self.view`上弹出来的。

找到了问题，解决起来就很简单了，只要在弹出下来菜单时remove掉gesture recognisers，在菜单关闭的时候再加回去，就可以保证不影响原有功能的前提下也能实现新增功能了。

```objc
[self.view removeGestureRecognizer:gesture];
```
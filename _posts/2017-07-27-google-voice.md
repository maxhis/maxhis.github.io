---
layout: post
title: "Google Voice申请美国手机号全攻略"
cover: http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-100204.jpg
date: 2017-07-27 18:00:00 +0800
category:
tags: Google
---

大局域网内什么服务都搞实名制，个人信息毫无隐私可言，而手机号是其中很重要的一环，如果可以用一个非实名的手机号就可以躲避许多风险，而如果手机号还是国外的，那可玩性就更高了。本文手把手教你如何通过[Google Voice](https://voice.google.com)（以下简称GV）申请一个免费且可长期使用的美国手机号。

## 0. 必要条件

如果这些条件不能满足，就只能洗洗睡了：

1. Google账号：也就是Gmail
2. 美国VPN：因为GV只在北美能用，所以一定得是美国的IP。

> **请注意，以下所有步骤都必须美国IP下进行!**

## 1. 注册TextNow获取临时的美国手机号（用来身份验证）

[TextNow](https://www.textnow.com/messaging)其实是和Google Voice类似的服务，也提供在线的接打电话、收发短信功能，但它的号码回收机制并不适合长期持有某一个固定的手机号，而且拨打北美地区也是收费的（GV免费）。所以，我们只用TextNow来作为注册GV的身份认证时使用。

TextNow的注册没什么可说的，注册完成后会动态分配你一个手机号，记住号码，会在注册GV时用到。

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-104607.jpg)

## 2. 注册Google Voice

现在登录你的Google账号，然后访问[Google Voice](https://www.google.com/voice/?setup=1#setup/)，进入后会提示选择一个号码，如下图：

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-131119.jpg)

毫不犹豫点进去，然后让你选择手机号归属地和手机号，如果你认为这么简单就能搞定那就大错特错了，当你选择了号码，哐当弹出来让你验证身份，需要你先拥有一个美国电话号码（死循环了），这时候之前申请的TextNow账号就起作用了。

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-130902.jpg)

输入你申请的TextNow号码，然后点`SEND CODE`，这时候在TextNow的控制台就能看到Google发过来的验证码短信，将这个验证码输入到GV的申请页面就可以完成认证。

完成身份认证后就可以正式开始申请GV手机号了，有时候会碰到即使认证了还会让你输入手机号认证的情况，不用管，直接进入下一步就好了。

## 3. 申请GV手机号

这一步非常关键，很多人都会卡在这里。以下是申请GV手机号的正确姿势：

#### 3.0 切换到旧版GV页面

GV默认会进入到新版的Materia Design界面，而旧版申请更方便，所以切换一下：

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-133252.jpg)

#### 3.1 开始申请

首先选择`Get a Voice Number`，然后点`I want a new number`:

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-135034.jpg)

然后就开始选择号码，可以按城市和数字关键字搜索，还是可以找到很多“靓号”的，我就选了一个后四位是我生日的号码：）

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-140514.jpg)

选择一个心仪的号码，然后点`Continue`，不出意外的话你会看到下面的错误信息：`There was an error with your request. Please try again.`

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-140931.jpg)

这并不是你的错，是Google的问题（具体原因不详），解决办法是不断重试，见过几分钟内就搞定的，也有的要点一二十个小时。

手动点一二十个小时当然不可能，必须要借助一些工具，如果你完全不懂技术，可以借助一些自动的鼠标点击工具来帮你点，Mac下推荐[Autoclick](https://github.com/MarcMax/Autoclick)。如果你懂点技术，还是推荐使用下面的通过脚本刷号码的方式。

#### 3.2 通过脚本刷GV号码

刷GV号码是纯体力活，这种事当然要交给计算机来做，其实也非常简单的，需要你使用Chrome浏览器，进入`开发者工具`（在页面上点右键，选择最下面的“检查”即可进入），选中`Network`的Tab，然后再点一次选号码的操作，它会自己记录下你这次请求的所有信息：

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-144301.jpg)

Chrome可以很方便的将HTTP请求转换成`cURL`命令，复制出来就可以直接使用，那我们的脚本也是通过shell循环调用这个cURL命令，简单粗暴！

先复制cURL命令：

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-iStar%202017-07-27%2022.56.33.png)

然后写个简单的shell脚本：

```shell
#!/bin/bash
while true; do
	[curl ...]
	sleep 1 #防止请求太过频繁，sleep 1秒钟
done
```

把上面的`[curl ...]`整个替换成刚刚复制的cURL命令，然后保存成文件，如`gv.sh`。

现在只要运行`gv.sh`就可以自动刷号码了，在这里一定要有耐心，不要觉得这样不工作，只要姿势对，总会刷出来的，我就刷了将近10个小时。成功后会给你的邮箱发邮件，这时候就可以停掉脚本了。

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-151137.jpg)

因为刷的时间可能很长，所以推荐放到VPS上去执行，建议使用`nohup`命令，这样即使你退出了ssh也可以在后台执行：

```shell
nohup ./gv.sh
```

> 就在我写这篇文章的时候，为了截图，随便点了几下，竟然就成功了，看来真是看人品的！![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-150859.jpg)

## 4. 在手机上接打GV电话

手机号自然要能在手机上接打电话才好，只需要几步简单设置就好了，这里需要先安装Google Hangouts（环聊）应用：

首先登录网页版，删除绑定号码和关闭Call Screening(以下图片来自：http://googlevoice.net/index.php/archives/1/)：

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-152358.jpg)

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-152500.jpg)

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-152558.jpg)

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-152616.jpg)

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-152628.jpg)

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-152648.jpg)

## 5. 使用IFTTT来长期保存GV号码

最后要说的是Google Voice也有回收政策，据说充值不会被回收，但一定不会被回收的条件就是半年内使用Google Voice的美国号码发短信或者打电话。

这点相信还是比较容易做到的，毕竟Google Voice的美国号码拨打美国、加拿大号码是免费的，发短信也是免费的。

但最懒最优雅的方式应该是使用IFTTT的[Keep Google Voice Active
](https://ifttt.com/applets/131839p-keep-google-voice-active) Applet：

![](http://ot58m681p.bkt.clouddn.com/blog/2017-07-27-153721.jpg)

开通很简单，输入你的GV号码，然后会给你打一个语音电话，里面会报一个四位的验证码，听到后输入就OK了，这里不再赘述。



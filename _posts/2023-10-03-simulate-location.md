---
layout: post
title: "使用Xcode修改iOS设备位置"
date: 2023-10-03 10:00:00 +0800
category: 技术
tags: [iOS]
---

因为某些原因，偶尔需要修改手机定位，之前都是用爱思助手来实现，升级到iOS 17后发现不能使用了，于是花了点时间研究了一下，顺利仅通过Xcode达到了同样的目的。

其实原理很简单，Xcode在debug时提供了模拟定位（Simulate Location）的功能，只需要跑个程序在你的设备上就可以修改定位了。以下是具体步骤（以Xcode 15为例）：

## 0.前置条件

1. 一台装有Xcode的Mac电脑，如果要修改定位的设备系统较新，Xcode也需要安装对应支持的版本，一般用最新版就好。
2. 苹果开发者账号，因为需要在iOS设备上运行程序，开发者账号是必须的。现在好像非付费账号也能在真机调试了，请自行研究。

## 1.新建iOS工程

> 其实新建也不是必须的，任意iOS可以跑在手机上的项目都可以。

打开Xcode，新建项目：`File - New - Project`：

![新建项目](/assets/img/simulate-location-1.png)

然后选择App，填入相应的信息即可，大部分默认就好，需要提一点是`Team`就是你的开发者账号。不用关心自动生成的模版代码，只要能运行到手机即可。

![](/assets/img/simulate-location-2.png)

不出意外的话，现在你已经可以把新建的项目跑在手机上了，新版Xcode可以通过Wi-Fi连接手机，还是挺方便的。

![](/assets/img/simulate-location-3.png)

## 2.修改位置信息

新版Xcode只支持导入[GPX](https://en.wikipedia.org/wiki/GPS_Exchange_Format)文件，其实就是GPS轨迹文件，包含了经纬度等信息的一系列点，因为我修改的是具体位置，只需要一个点就行了，以下是一个GPX文件内容示例：

```xml
<?xml version="1.0"?>
<gpx version="1.1" creator="gpxgenerator.com">
    <wpt lat="22.66" lon="114.99">
    <ele>13.77</ele>
    <time>2023-10-03T14:35:11Z</time>
</wpt>
</gpx>
```

可以直接修改上面的经纬度信息得到你的GPX文件，或去[gpxgenerator.com](https://www.gpxgenerator.com/)这个网站生成。

有了GPX文件就可以导入到项目中了，导入需要项目是运行状态：

![](/assets/img/simulate-location-4.png)

导入后，就可以正式修改位置了，进入上一步同样的菜单，只是这次选中导入的文件：

![](/assets/img/simulate-location-5.png)

至此，你的设备位置就修改成功了，与爱思助手恢复正常定位需要重启手机不同，这种方式只需要停止运行这个项目即可，相当方便！后续如要再修改位置只需重复上一步，一劳永逸。
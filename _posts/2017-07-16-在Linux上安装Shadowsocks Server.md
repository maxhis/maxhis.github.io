---
layout: post
title: "快速在Linux上安装Shadowsocks Server"
cover: http://ot58m681p.bkt.clouddn.com/netssocks.png
date: 2017-07-16 11:00:00 +0800
category: Shadowsocks
tags: Shadowsocks Linux
---

[Shadowsocks](https://shadowsocks.org)大家都懂的，科学上网神器，搭建方便，速度快。用了好几年了，最近又在[搬瓦工](https://bwh1.net/aff.php?aff=16921)上新买了一台主机，系统是Debian 9，安装Shadowsocks很简单，在这里记录一下以备有下一台主机时翻阅。

我安装的是`C with libev`版本，在Debian 9或Ubuntu 16.10以上版本的官方软件库里已经集成了，网上大部分教程都是自己去编译源码，其实大可不必。

## 安装

安装很简单，直接`apt-get`：
```c
sudo apt update
sudo apt install shadowsocks-libev
```

其它版本安装方法请看[官方文档](https://shadowsocks.org/en/download/servers.html)。

## 配置

安装完成后还需要简单的配置才可以使用，直接修改`/etc/shadowsocks-libev/config.json`即可，以下是一个示例：

```javascript
{
    "server":"my_server_ip",
    "server_port":8388,
    "local_port":1080,
    "password":"barfoo!",
    "timeout":600,
    "method":"chacha20"
}
```

## 重新启动

```c
service shadowsocks-libev restart
```


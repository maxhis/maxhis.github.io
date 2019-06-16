---
layout: post
title: "实现基于Apache的简单网址跳转服务"
date: 2019-06-16 13:00:00 +0800
category: 技术
tags: [Apache]
---

事情起源于前段时间做的[开发者导航网站 oio.dev](https://oio.dev) 的几个链接加了aff，又不想把带aff的链接直接暴露出来，于是就想着能不能做一个简单的跳转服务。研究了很久，什么短链接的原理都看了一遍，最后发现基于Apache的htaccess是最简单的。

其实就是添加一些htaccess的跳转规则：打开网站根目录的`.htacesss`文件，比如你想把`/go/jms`跳转到`https://justmysocks1.net/members/aff.php?aff=2084`，只需要添加一条301跳转即可：

```shell
Redirect 301 /go/jms https://justmysocks1.net/members/aff.php?aff=2084
```

然后访问 yourdomain.com/go/jms 就会跳转到真正的aff链接。后续如果要添加更多的跳转，只需要维护这个列表就可以了，还是很简单方便的。

特意为我的跳转服务用了一个二级域名：go.oio.dev，[go.oio.dev/jms](https://go.oio.dev/jms)这种链接看着还有点专业呢：）

*如果你没有安装Apache，推荐[Digital Ocean](https://go.oio.dev/do)的[这篇教程](https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-debian-9)，顺带可以把https也搞定。*
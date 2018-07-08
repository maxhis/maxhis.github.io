---
layout: post
title: "以Web Server的方式分享本地文件"
date: 2018-07-08 09:30:00 +0800
category: Linux
tags: Linux Python WebServer
---

偶尔会需要将本地文件临时分享给其他人，建个 FTP 显得有点小题大作，而 Web Server 会是更方便且轻量级的方案。

几乎所有 Linux 发行版本和 macOS 都自带了 Python 运行环境，通过简单的一条命令就可以开一个 Web Server，随开随关，非常方便：

- Python 2 的写法： `python -m SimpleHTTPServer 8000`
- Python 3 的写法： `python -m http.server 8000`

然后告诉对方你的 IP，对方就可以通过 http://xxx.xxx.xxx.xxx:8000 访问或下载你的本地文件了。

![](https://om4ukr2l3.qnssl.com/blog/2018-07-08-013227.png)


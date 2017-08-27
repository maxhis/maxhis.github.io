---
layout: post
title: "延长SSH会话超时时间"
cover: https://om4ukr2l3.qnssl.com/blog/2017-07-31-053512.jpg
date: 2017-07-31 14:00:00 +0800
category: Linux
tags: SSH Linux
---

SSH连接VPS时很容易就超时了，常常是切换一个窗口操作一会儿就需要重新连接，非常恼人。开始以为是我的VPS配置太低或是网络原因造成的，其实只是我没有配置好。

## 0. SSH Server端配置

SSH Server在这里就是VPS上的sshd了（Unix like的系统都有），可以通过修改sshd的配置文件来改变SSH session的超时时间：

```shell
vim /etc/ssh/sshd_config
```

然后找到下面两项：

```shell
ClientAliveInterval 30
ClientAliveCountMax 3
```

这两项默认可能是注释掉的，需要打开，然后填入合适的数字。简单介绍一下这两个参数的含义：

- ClientAliveInterval：这个其实就是SSH Server与Client的心跳超时时间，也就是说，当客户端没有指令过来，Server间隔`ClientAliveInterval`的时间（单位秒）会发一个空包到Client来维持心跳，保证Session有效。
- ClientAliveCountMax：当心跳包发送失败时重试的次数，比如现在我们设置成了3，如果Server向Client连续发三次心跳包都失败了，就会断开这个session连接。

修改完配置之后，需要重启sshd来使配置生效：

```shell
/etc/init.d/ssh restart
```

或

```shell
service ssh restart
```

## 1. SSH Client端配置

除了修改Server端配置外，延长SSH Session的时间其实还可以通过修改Client端的配置来实现，这可能是更好的选择。

修改 `~/.ssh/config`

```shell
Host myhostshortcut
     HostName myhost.com
     User root
     ServerAliveInterval 30
     ServerAliveCountMax 3
```

两个关键参数是`ServerAliveInterval`和`ServerAliveCountMax`，对比一下上面Server端的两个参数，意思是对应的，只是一个是Server一个是Client，这里不再赘述。


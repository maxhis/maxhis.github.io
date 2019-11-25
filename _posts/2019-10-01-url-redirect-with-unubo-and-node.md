---
layout: post
title: "基于Unubo与Node的网址跳转服务"
date: 2019-10-01 13:00:00 +0800
category: 技术
tags: [Node.js, Unubo]
---

之前写过[一篇文章](https://15tar.com/%E6%8A%80%E6%9C%AF/2019/06/16/url-redirect-with-apache.html)，介绍使用Apache htaccess来实现简单的网址跳转服务，这种方案最大的问题是需要自己有一个稳定的服务器，因为一旦服务器挂掉，整个服务也就不能用了。

我用的服务器是在搬瓦工上，它同时承担着“科学上网”的重任，而最近特殊时期服务器的科学上网服务竟然挂掉了。虽然跳转服务暂时还能用，但找到一种更稳定可靠的方案不得不提上日程。而前不久在product hunt上看到的Unubo，可以完美地解决这个问题。

> 顺便安利一下我做的一个Product Hunt频道：[https://t.me/product_top](https://t.me/product_top)，会自动发布当天最受欢迎的作品，是发现好产品、寻找灵感的好工具。机器人用Python实现，感兴趣的可以去GitHub围观：[https://github.com/maxhis/ph_daily](https://github.com/maxhis/ph_daily)。

## 0. 什么是Unubo？

[Unubo](https://unubo.com/)是一个新出来的帮助快速部署web app的服务，支持Node, Python, Go, Ruby等主流语言和MySQL(MariaDB)、PostgreSQL、Redis数据库，每个app都有1GB RAM, 1 CPU, 500MB硬盘的独立配置，对小型app够用。~~目前还没有实例个数的限制~~，更让人惊喜的是还有亚洲节点，国内访问速度有保障。更多详细介绍可以登录官网查看，你会发现它真是一个宝库。

## 1. 用Node.js实现网址跳转服务

在选定了基础服务后，就是实现应用程序部分了。思路很简单：就是在Unubo上搭建一个服务，做301跳转。考虑到实现的便捷性，我选用Node.js来实现。大致步骤如下：

### 一个方便修改维护的配置表

用于记录URL path与目标地址，这里用JavaScript Object就可以了。

```js
// urls.js
exports.urls = {
  blog: 'https://15tar.com',
  ...
}
```

### HTTP请求处理与跳转逻辑控制

方便起见，使用Express做路由处理，查询req.path是否在配置表里，如果在则跳转到对应的目标地址。

```js
// index.js
const app = require('express')();
const PORT = process.env.PORT || 4000;
const { urls } = require('./urls');

app.get('*', (req, res) => {
  const path = req.path.split('/')[1];
  if (urls.hasOwnProperty(path)) {
    res.redirect(301, urls[path]);
  } else {
    res.redirect(301, 'https://oio.dev')
  }
});

app.listen(PORT, () => console.log(`> Ready on http://localhost:${PORT}`));
```

完整代码可以查看GitHub：[https://github.com/maxhis/oio-redirecting](https://github.com/maxhis/oio-redirecting)。

## 2. Unubo配置与部署

Unubo的配置与部署很简单，首先新建一个app，选择你使用的语言，比如Node.js；区域建议选择Asia，可以在国内获得不错的访问速度。

然后选择要部署的代码库，需要先将代码上传到GitHub，再授权要部署的代码仓库即可，部署的时会自动拉取代码编译运行。

**需要注意的一点是，还需要配置Commands，也就是启动你程序的命令，如：`npm start`，不配置会导致程序运行不起来。**

![Unubo commands](/assets/img/unubo-command.png)

最后点击底部的“Deploy”按钮开始部署，部署成功后就可以访问你的app了，如https://your-app-name.unubo.app

### 自定义域名

除了默认的unubo.app域名，Unubo还支持自定义域名，同时支持HTTPS。简单来说，就是在域名的DNS管理里添加一个CNAME到Unubo的地址，如 asia.unubo.app, 然后在Unubo的Domains里配置对应的域名即可。

![Unubo domain](/assets/img/unubo-domain.png)

至此，一个替代Apache、且不需要自备服务器的网址跳转服务就完成了，相比自己搭建服务不管是访问速度还是稳定性上都有提升。在各种共有基础服务成熟完善的今天，似乎自己购买服务器搭建各种服务已经显得越来越没必要了。
---
layout: post
title: "基于CloudFlare Workers的网址跳转服务"
date: 2020-01-14 15:00:00 +0800
category: 技术
tags: [CloudFlare, Node.js]
---

CloudFlare Workers正式对外发布了，稍微研究了一下，发现挺适合做一个网址跳转服务的，Workers其实就是一个Serverless服务，目前支持Node.js和Rust语言。本文介绍如何使用Node.js基于Workers实现一个网址调转服务，并支持自定义域名。

### 1.创建Workers

具体步骤就不赘述了，可以在CloudFlare直接编辑代码，也可以使用提供的[Wrangler](https://developers.cloudflare.com/workers/quickstart/)工具，如果程序本身比较简单，直接在网站后台编辑就可以了，自带的编辑器还挺智能的；如果程序比较复杂，会用到第三方的npm库，就首选Wrangler，用webpack打包后上传部署。

网址跳转的代码比较简单，我直接选择第一种方式，截个图：
![Workers](https://cdn.jsdelivr.net/gh/maxhis/assets@master/uPic/2020/01/14/jhPkmp.png)

代码很简单，可以直接拿去用，改一下`redirectMap`变量里的内容即可。
```javascript
async function handleRequest(request) {
  let requestURL = new URL(request.url)
  let path = requestURL.pathname.split('/')[1]
  let location = redirectMap[path]
  if (location) {
    return Response.redirect(location, 301)
  }
  return fetch(request)
}
addEventListener('fetch', async event => {
  event.respondWith(handleRequest(event.request))
})

const redirectMap = {
  blog: 'https://15tar.com',
  foo: 'https://foo.com', // others here
}
```

部署后就可以直接通过Workers默认的URL访问了。

### 2.自定义域名

自定义域名的前提是域名通过CloudFlare管理的，选择对应域名后，选择Workers tab，然后添加route：

![](https://cdn.jsdelivr.net/gh/maxhis/assets@master/uPic/2020/01/14/zKpf74.png)

然后配置route就可以了，支持通配符：

![](https://cdn.jsdelivr.net/gh/maxhis/assets@master/uPic/2020/01/14/pkUktD.png)

需要注意的是，如果是二级域名，需要先给这个二级域名添加一个CNAME记录，否则跳转会有问题。CNAME记录的内容理论上可以随便写，Worker会在CNAME之前拦截请求，只有未被拦截的才会走CNAME里的地址。

![](https://cdn.jsdelivr.net/gh/maxhis/assets@master/uPic/2020/01/14/ynoBgo.png)
---
layout: post
title: "MongoDB基本安全设置"
cover: http://ot58m681p.bkt.clouddn.com/blog/2017-08-09-051803.jpg
date: 2017-08-09 14:00:00 +0800
category: Linux
tags: MongoDB
---

前段时间在VPS上跑了个程序抓取PornHub的资源然后保存到MongoDB里，跑了几天，抓下来近十万条数据，然后用Node.js写了个简单的REST API，可以获取这些资源。

直到有一天当我在call REST API的时候发现没有数据返回了，登录到后台一看，数据全被清掉了，还留下一条让支付比特币去赎回数据的记录。。。

![](http://ot58m681p.bkt.clouddn.com/blog/2017-08-09-151209.jpg)

因为是第一次使用MongoDB，所以基本的安全措施都没做，等于是裸奔在互联网上的一个数据库，谁都可以访问，这不被黑客访问到就怪了。趁着今天有空，稍微研究了一下MongoDB的安全设置。

## 0. 只允许本机访问MongoDB

如果MongoDB只在本机访问，强烈建议打开这个配置，这样可以杜绝其它IP对数据库的访问。修改MongoDB配置文件，如果是Debian/Ubuntu，配置文件在`/etc/mongod.conf`，然后查找`net`关键字：

```ruby
# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1
```

默认`bindIp`一行是注释的，把注释打开就只能本机访问了。

## 1. 为数据库设置需要用户名和密码访问

在很多情况下，我们是需要其它主机访问本机数据库的，这时候上面的做法就行不通了，而设置需要通过用户名和密码才能访问数据库是另外一道屏障。

### a. 创建用户：

```javascript
use cool_db

db.createUser({
    user: 'userName',
    pwd: 'secretPassword',
    roles: [{ role: 'readWrite', db:'cool_db'}]
})
```

### b. 打开访问认证及允许所有IP访问

同样是修改mongod.conf，首先要允许所有IP访问：

```ruby
# network interfaces
net:
  port: 27017
#  bindIp: 127.0.0.1
```

然后查找`security`关键字，打开需要认证访问：

```ruby
security:
  authorization: 'enabled'
```

最后不要忘记重启mongod：

```c
service mongod restart
```

如果出错，可以通过`tail -f /var/log/mongodb/mongod.log`查看具体的错误信息。

### c. 访问测试

在其它电脑上通过shell访问目的主机（假设IP为123.45.67.89）的MongoDB服务：

```shell
mongo -u userName -p secretPassword 123.45.67.89/cool_db
```

### d. 通过Node.js访问远程MongoDB

最后试一下在Node（我使用mongoose）里加上用户名和密码访问MongoDB:

```javascript
var mongoose = require('mongoose');
mongoose.connect('mongodb://userName:secretPassword@123.45.67.89/cool_db', {
  useMongoClient: true,
  /* other options */
  })
  .then(() =>  console.log('Connecting MongoDB successful'))
  .catch((err) => console.error(err));
```


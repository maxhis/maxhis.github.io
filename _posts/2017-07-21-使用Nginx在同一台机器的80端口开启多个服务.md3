---
layout: post
title: "使用Nginx在同一台机器的80端口开启多个服务"
cover: http://ot58m681p.bkt.clouddn.com/blog/2017-07-21-140334.jpg
date: 2017-07-21 21:00:00 +0800
category: Linux
tags: Linux Nginx
---

这是一个困扰我很长一段时间的问题，常常需要在同一台服务器上跑几个不同的小服务（一般是App Server），而80端一旦被占用，后面再启新的服务就只能用别的端口，所以在客户端访问时需要显式地在URL里添加端口号，很不方便也很不user friendly。

其实通过Nginx的端口转发可以很简单的实现在同一台机器上的80端口同时跑多个不同服务。

## 0. 找到Nginx的Config File

不同版本的Nginx版本的Config File路径不完全一致，可以通过`nginx -t`列出当前路径：

```c
➜  ~ nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

## 1. 在Config File中添加新服务

用你喜欢的任意编辑器打开上一步找到的Nginx Config File，如：

```c
vim /etc/nginx/nginx.conf
```
只需要在`http`节点新增一个`server`节点就可以了，假如我在本地启了一个Node.js服务，监听端口`6666`，那么应该添加如下内容：

```ruby
http {
....
	server {
        listen 80;
        server_name  example.com;
        location / {
            proxy_set_header Host $host;
            proxy_pass http://127.0.0.1:6666;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
	}
...
}
```

对以上配置做一个简单说明：

- listen 80：这个不能动，意思就是要监听80端口
- server_name  example.com：`example.com`是服务对外的域名，可以是一级域名也可以是二级域名
- proxy_pass http://127.0.0.1:6666：这一行指定你本地需要被转发的服务，需要指定域名和端口

## 2. Domain DNS设置

最后不要忘记去DNS Server将A记录指向你的服务器地址！



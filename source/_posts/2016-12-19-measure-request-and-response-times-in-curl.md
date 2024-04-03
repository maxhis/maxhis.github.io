---
layout: post
title: "通过cURL输出API请求的每一步所花时间"
description: "measure request and response time in cURL"
category: Linux
tags: [cURL, iOS]
---


最近在开发一个App时，发现一个服务端API速度特别慢，于是想用最简单的cURL来模拟APP的请求，进一步找出到底是哪一步慢了。

<!--more-->

## 一、生成cURL命令

APP的接口不可避免的需要传入很多参数，手写cURL命令比较麻烦而且容易出错，而博主刚好使用了[Alamofire](https://github.com/Alamofire/Alamofire)来处理所有的网络请求，Alamofire提供了非常方便的输出cURL命令的方法。比如下面的代码：

```swift
let request = Alamofire.request("https://httpbin.org/get", parameters: ["foo": "bar"])
debugPrint(request)
```
	
会输出以下内容，直接copy到Terminal就可以直接使用了：
```swift
$ curl -i \
-H "User-Agent: Alamofire/4.0.0" \
-H "Accept-Encoding: gzip;q=1.0, compress;q=0.5" \
-H "Accept-Language: en;q=1.0,fr;q=0.9,de;q=0.8,zh-Hans;q=0.7,zh-Hant;q=0.6,ja;q=0.5" \
"https://httpbin.org/get?foo=bar"
```

## 二、让cURL输出API请求每一步所花费的时间

cURL支持格式化输出request的详细信息，我们只需要提供一个格式，让cURL按照该格式输出就可以了。

1. 新建一个文件，取名`curl-format.txt`（名字随意，只要与后面对应就好），并输入以下内容：
```c
time_namelookup:  %{time_namelookup}\n
   time_connect:  %{time_connect}\n
 time_appconnect:  %{time_appconnect}\n
time_pretransfer:  %{time_pretransfer}\n
   time_redirect:  %{time_redirect}\n
time_starttransfer:  %{time_starttransfer}\n
                 ----------\n
 	time_total:  %{time_total}\n
```

2. 运行cURL命令时加上特定的头，示例如下:
```c
curl -w "@curl-format.txt" -o /dev/null -s "http://wordpress.com/"
```
	
简单解释如下：
- `-w "@curl-format.txt"` 告诉cURL用我们的格式化文件输出；
- `-o /dev/null` 重定向cURL输出到/dev/null，也就是不显示输出response信息，因为我们只关心时间消耗在哪里了，并不关心API的返回信息；
- `-s` 不输出进度信息，同上，只是为了让输出更简洁。 

## 参考
- StackOverflow: [How do I measure request and response times at once using cURL?
](http://stackoverflow.com/a/22625150/1150251)



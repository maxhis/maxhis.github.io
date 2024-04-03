---
layout: post
title: "使用fastlane发布iOS extension"
date: 2019-05-20 19:00:00 +0800
category: 技术
tags: [fastlane, iOS]
---

昨天给瓦工助手app加了个今日小组件（Today Widget）功能，可当使用fastlane发版时，提示找不到新增的extension对应的profile文件。

Google了很久，fastlane官方也没有给出这种情况的解决办法，文档也没有特殊说明。在查阅[match](https://docs.fastlane.tools/actions/match/)文档时发现`app_identifier`的字段类型可以是字符串或数组，于是试着把主app和extension的app identifier放到一个数组里，结果还真可以！

将：
```ruby
match(
  type: "appstore",
  git_url: iosCodeSignUrl,
  app_identifier: "com.0x1024.Bandwagon"
)
```

改成：
```ruby
match(
  type: "appstore",
  git_url: iosCodeSignUrl,
  app_identifier: ["com.0x1024.Bandwagon", "com.0x1024.Bandwagon.todayWidget"]
)
```
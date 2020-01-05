---
layout: post
title: "自动更新网站版权年份"
date: 2020-01-05 21:00:00 +0800
category: 技术
tags: [copyright]
---

每年元旦一过，一大批网站的底部的©copyright年份也跟着过期了，然后大部分网站会在相当长时间之后手动更新过来。那有没有一种方式可以方式可以自动化实现这个操作呢？答案当然是有。

> 这里讨论的不包括Wordpress之类成熟的网站程序，这种肯定都有插件来实现。

### Jekyll

首先看看GitHub page上占有率最高的Jekyll，在声明copyright的地方（一般为footer.html)写入下面内容即可：
{% raw %}
```html
{% assign earliestPost = site.posts | last %}
&copy; {{ earliestPost.date | date: "%Y" }}–{{ site.time | date: "%Y" }}
```
{% endraw %}

以上代码会遍历所有文章的日期，找到最早的发文年份作为起始年份，并以当前年份作为终止年份，动态更新。显示内容类似：`© 2015–2020`

### Hugo

Hugo也是很受欢迎的静态网站程序，修改稍微麻烦一些，大致思路是修改配置文件的copyright字段，使用占位符代替当前年份，然后在footer文件中替换占位符为实际的年份。

配置文件(config.toml)示例，这里使用`{year}}`占位：
```html
baseURL = "http://www.example.com/"
title = "Example Site"
copyright = "Copyright 2007-{year} Example LLC. All rights reserved."
```

然后在footer中替换`{year}`占位符：
{% raw %}
```html
<footer>
	<span class="copyright">
		{{ replace .Site.Copyright "{year}" now.Year }}
	</span>
</footer>
```
{% endraw %}

### HTML

如果是完全静态的html，就只能用JavaScript来实现了，如下：

```javascript
2015<script>new Date().getFullYear()>2015&&document.write("-"+new Date().getFullYear());</script>
```

下面再列几个常用的网站程序代码，其实都大同小异，编程语言不一样而已：

### PHP

```php
<?php
$fromYear = 2010;
$thisYear = (int)date('Y');
echo $fromYear . (($fromYear != $thisYear) ? '-' . $thisYear : '');?>
```

### Django

修改footer文件中版权年份的地方：
{% raw %}
```python
{%now "Y"%}
```
{% endraw %}

### Node.js

```javascript
new Date().toISOString().substr(0,4)
```
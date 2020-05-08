---
layout: post
title: "为Jekyll增加文章打赏功能"
date: 2020-05-08 15:00:00 +0800
category: 技术
tags: [Jekyll]
---

最近几年大家逐渐开始形成了知识付费的习惯，而微信公众号的打赏功能典型代表，那有没有可能为个人独立博客也添加打赏功能呢？搜索一下，发现目前主流的博客平台都有类似的插件，而相对比较远古、同时也正是我在使用的Jekyll却没有这样的插件。不过好在开源，自己实现一个打赏功能也比较简单。

### CSS

首先写一个独立的css文件放到 `assets/css` 目录下，这样可以不与原样式文件混在一起，方便维护。内容可以参考使用的[css文件](https://github.com/maxhis/maxhis.github.io/blob/master/assets/css/myreward.css)。

然后在头文件里引用上述 css 即可，一般文件名为 `head.html` 或 `post-head.html` ：

```html
<link  href="/assets/css/myreward.css" rel="stylesheet"  type="text/css">   
```

### HTML

最后在文章页面`post.html`的合适位置（一般放文章内容最后），添加以下内容即可：
```html
<div class="reward">
  <div class="reward-button">赏 <span class="reward-code">
    <span class="alipay-code"> <img class="alipay-img wdp-appear" src="/assets/img/social/alipay.JPG"><b>支付宝打赏</b> </span>
    <span class="wechat-code"> <img class="wechat-img wdp-appear" src="/assets/img/social/wechat.JPG"><b>微信打赏</b> </span> </span>
  </div>
  <p class="reward-notice">您的打赏是对我最大的鼓励！</p>
</div>
```

将其中的`img.src`替换成自己的收款二维码，打赏功能就这样简单粗暴地实现了。

### 优化

作为有洁癖的程序员，上面做法显然不能让自己满意，哪天想把打赏功能去掉，又不得不在一大堆文件里找、删掉了这些代码，不方便维护。

其实我们可以做一个配置项，可以非常方便地配置是否启用打赏功能。这些配置项可以放在`_config.yml`中，包括是否启用、收款码的图片等，往`_config.yml`中添加以下内容：

```ruby
# Reward
reward: true
reward-wechat: '/assets/img/social/wechat.JPG'
reward-alipay: '/assets/img/social/alipay.JPG'
```

然后同步修改 html ：
```html
{% raw %}{% if site.reward %}
<div class="reward">
    <div class="reward-button">赏<span class="reward-code">
        <span class="alipay-code"> <img class="alipay-img wdp-appear" src="{{ site.baseurl }}{{ site.reward-alipay }}"><b>支付宝打赏</b> </span>
        <span class="wechat-code"> <img class="wechat-img wdp-appear" src="{{ site.baseurl }}{{ site.reward-wechat }}"><b>微信打赏</b> </span> </span>
    </div>
    <p class="reward-notice">您的打赏是对我最大的鼓励！</p>
</div>
{% endif %}{% endraw %}
```

这样，不启用打赏功能只需要把`reward`的值改成`false`就好了，而不用再去修改html。
---
layout: post
title: 发布一款有趣的小程序：生日天气
date: 2026-01-29 20:00:00 +0800
category: [我的作品, 技术]
tags: [微信小程序, 生日天气, Birthday Weather, Open-Meteo]
cover: "/images/birthday-weather/cover.svg"
---

你是否好奇过，你出生的那一刻，窗外是怎样的天气？
是阳光明媚，还是大雨倾盆？是雪花飘飘，还是狂风呼啸？
家里的长辈可能记得，但模糊的记忆总不如数据来得确切。

为了满足这份好奇心，我开发了一个微信小程序——**生日天气**。

### 主要功能

#### 1. 历史天气回溯
支持查询 1940 年至今的历史天气数据。无论你是 80 后、90 后还是 00 后，都能找到那一天的天气记忆。数据来源于 Open-Meteo Archive API，精准可靠。

#### 2. 农历/公历完美支持
在中国，很多人的生日是按农历过的。小程序内置了强大的日历转换功能，支持直接选择农历日期进行查询，系统会自动转换为对应的公历日期去获取天气数据。

#### 3. 精美 UI 设计
界面采用了清新的毛玻璃（Glassmorphism）风格，背景会根据查询到的天气情况（晴、雨、雪、云）自动切换，生成一张带有年代感的专属天气卡片。

### 预览

{% swiper effect:cards %}
![首页截图](/images/birthday-weather/index.PNG)
![结果页截图](/images/birthday-weather/result.PNG)
{% endswiper %}

### 如何体验

扫描下方二维码，立刻查看你的出生日天气：

{% image /images/birthday-weather/qr_code.JPG 小程序码 width:300px fancybox:true %}

欢迎大家体验，如果有任何 bug 或建议，欢迎在博客下方留言或在小程序内反馈！

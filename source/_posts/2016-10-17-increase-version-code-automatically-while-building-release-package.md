---
layout: post
title: "Android App如何在编译时让versionCode自增长"
description: "Increase version code automatically while building release package"
category: Android
tags: [gradle]
---



与versionName直接展示给用户不同，versionCode只是为了给系统或是开发者自己看的，必须保证新版本的versionCode大于老版才能够正常安装。而versionCode增长的方式也有很多种，比较常见的是每次发布版本时加一，今天要讨论的是如果便捷地将versionCode加一。

<!--more-->

其实Google一下就能找到一些解决方案，一般都是把版本号写到一个配置文件里，然后在gradle编译的时候读取并改变这个值，需要额外的文件，稍微有些麻烦。

既然可以在编译的时候读写外部文件，那能不能直接改写编译脚本(build.gradle)本身呢？经过尝试，答案是可以的，在`app/build.gradle`加上以下代码就可以了：

```java
import java.util.regex.Pattern

task('increaseVersionCode') << {
    def buildFile = file("build.gradle")
    def pattern = Pattern.compile("versionCode(\\s+\\d+)")
    def buildText = buildFile.getText()
    def matcher = pattern.matcher(buildText)
    matcher.find()
    def versionCode = android.defaultConfig.versionCode
    def buildContent = matcher.replaceAll("versionCode " + ++versionCode)
    buildFile.write(buildContent)

    System.out.println("Incrementing Version Code ===> " + versionCode)
}

tasks.whenTaskAdded { task ->
    if (task.name == 'generateReleaseBuildConfig') {
        task.dependsOn 'increaseVersionCode'
    }
}
```

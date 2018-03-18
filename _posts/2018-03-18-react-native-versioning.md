---
layout: post
title: "React Native版本号管理"
category: "React Native"
tags: ["React Native", "版本号管理"]
cover: "https://om4ukr2l3.qnssl.com/blog/2018-03-18-124647.jpg"
---

经过近两个月的学习和开发，第一个用React Native开发的App已经上线了，一次搞定两个端的感觉真好，我以后自己的项目应该会首选React Native来做了。其实还有一个让我比较难受的是版本号不好管理，在package.json里有一个js版本号，Android和iOS分别又有一个自己的版本号，理想是能够统一成一个（这里说的是versionName）。

## JavaScript

js部分用npm管理，npm对版本号管理有很好的支持，简单运行`npm version`不仅可以修改package.json里的版本号，还能自动打好tag。

```shell
npm version [major|minor|patch]
```

## Android

之前在玩Android的时候，[对gradle有一些研究](https://15tar.com/android/2015/08/18/gradle.html)，它本身就去Groovy语言，可以比较方便地读取package.json里的版本号，然后更新`app/build.gradle`的versionName。

读取版本号：

```groovy
import groovy.json.JsonSlurper

def getNpmVersion() {
    def inputFile = new File("../package.json")
    def packageJson = new JsonSlurper().parseText(inputFile.text)
    return packageJson["version"]
}
```

更新versionName：

```groovy
defaultConfig {
  		...
		versionName getNpmVersion()
}
```

在这里我没有改versionCode，其实我是会在每次release build自动加一，[之前博客有介绍](https://15tar.com/android/2016/10/17/increase-version-code-automatically-while-building-release-package.html)，这里再贴一下方法：

```groovy
import com.android.build.OutputFile
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

## iOS

iOS的版本号是写在Info.plist里的，这里就简单粗暴用shell实现了，新建一个version-ios.sh文件：

```shell
#!/usr/bin/env bash -e

PROJECT_DIR="ios/ReactNativeApp"
INFOPLIST_FILE="Info.plist"
INFOPLIST_DIR="${PROJECT_DIR}/${INFOPLIST_FILE}"

PACKAGE_VERSION=$(cat package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')


# Update plist with new values
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${PACKAGE_VERSION}" "${INFOPLIST_DIR}"


git add "${INFOPLIST_DIR}"
```

我们期望的是每次运行`npm version`，iOS的版本号也会自动更新，只需要在package.json里加上以下内容即可：

```json
"scripts": {
  "version": "./version-ios.sh"
}
```

和iOS一样，每次release buil版本号也会自动加一，使用的发布管理工具fastlane可以很方便实现(`increment_build_number`)。

--EOF--


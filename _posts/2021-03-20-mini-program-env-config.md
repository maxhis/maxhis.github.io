---
layout: post
title: "小程序环境配置管理实践"
date: 2021-03-20 15:00:00 +0800
category: 技术
tags: [小程序]
---

最近帮朋友做了个小程序，后端使用的是腾讯云开发，除了写了几个云函数，没有一行后端代码，大大提高了开发效率。因为开发与生产使用的是两套独立环境，小程序本身没有现成的切换环境配置的方法，来回切换时需要手动修改代码，容易出错，于写了个简单的脚本，通过命令来修改环境配置。

## 创建配置文件

在项目根目录创建config文件夹，并在文件夹下创建env/dev.json和env/prod.json等环境配置文件，用来放置环境信息，如：

```js
// config/env/dev.json
{
    "environment": "dev-xxxx",
    "storagePrefix": "dev-yyyy-dev-zzzz"
}
```

然后我们在根目录建立一个放置默认配置的projectConfig.js文件,并把它引入到app.js。
```js
// projectConfig.js
module.exports = {
  "environment": "dev-xxxx",
  "storagePrefix": "dev-yyyy-dev-zzzz"
}

// app.js
const config = require('./projectConfig')
App({
    ...,
    globalData: {
    ...config
    }
})
```

这样就把配置信息引入到了我们的项目中。

## 选择对应的env下的配置文件

接下来在我们项目的package.json里scripts增加两条命令行,用来启动不同的环境。

```js
// package.json
  "scripts": {
    "switch:dev": "node config/switch.js --dev",
    "switch:prod": "node config/switch.js --prod"
  }
```

在config目录下创建switch.js，利用node.js处理配置信息.

```js
// config/switch.js
/**
* 根据命令行运行参数，修改/config.js 里面的项目配置信息，
*/
const fs = require('fs')
const path = require('path')
//源文件
const sourceFiles = {
  prefix: '/env/',
  dev: 'dev.json',
  prod: 'prod.json'
}
//目标文件
const targetFiles = [{
  prefix: '/../',
  filename: 'projectConfig.js'
}]
// 获取命令行参数
const cliArgs = process.argv.splice(2)
const env = cliArgs[0]
// 判断是否是 prod 环境
const isProd = env.indexOf('prod') > -1 ? true : false
// 根据不同环境选择不同的源文件
const sourceFile = isProd ? sourceFiles.prod : sourceFiles.dev
const preText = '/**\n'+
` * 通过npm run switch:${isProd ? 'prod' : 'dev'}自动生成\n`+
' */\n'+
'module.exports = '
// 根据不同环境处理数据
fs.readFile(__dirname + sourceFiles.prefix + sourceFile,
  (err, data) => {
    if (err) {
      throw new Error(`Error occurs when reading file ${sourceFile}.nError detail: ${err}`)
      process.exit(1)
    }
    // 获取源文件中的内容
    const targetConfig = JSON.parse(data)
    // 将获取的内容写入到目标文件中
    targetFiles.forEach(function (item, index) {
      let result = null
      if (item.filename === 'projectConfig.js') {
        result = preText + JSON.stringify(targetConfig, null, 2)
      }
      console.log(result)
      // 写入文件(这里只做简单的强制替换整个文件的内容)
      fs.writeFile(__dirname + item.prefix + item.filename, result, 'utf8', (err) => {
        if (err) {
          throw new Error(`error occurs when reading file ${sourceFile}. Error detail: ${err}`)
          process.exit(1)
        }
      })
    })
  })
```

至此，当我们输入不同的命令行，动态的将相应环境配置信息写入默认配置文件，并引入到项目中。

## 与开发者工具关联

每次切换环境都要自己运行npm脚本，也会有点不方便，这个时候我们可以配置开发者工具。

在开发者工具的本地设置中，勾选启用自定义处理命令，并分别在编译前预处理和上传前预处理填入我们的命令。

![Screen Shot 2021-03-20 at 16.44.26](/assets/img/Screen%20Shot%202021-03-20%20at%2016.44.26.png)

这样就保证了开发环境和生产环境隔离，避免产生脏数据。
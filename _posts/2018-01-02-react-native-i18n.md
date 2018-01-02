---
layout: post
title: "React Native的国际化"
category: "React Native"
tags: ["React Native", I18n, 国际化]
---

最近在玩React Native，一套代码在多个平台使用确实很爽，而当App做大以后国际化是不可避免的一个问题。趁着元旦假期有空研究了一下，虽然没有Android(不是iOS)上那么方便，但也不算太麻烦。

## I18n

这里需要使用一个第三方库[react-native-i18n
](https://github.com/AlexanderZaytsev/react-native-i18n)，安装：

```shell
npm i react-native-i18n --save
```

安装后还需要link，官方文档里有很长的介绍，亲测只需要运行`react native link`就OK了。

## 字符串本地化

字符串以json格式存储，这样可以嵌套对象以实现资源模块化，这里我们统一将国际化资源文件放在`locales`目录下，目录结构如下：

```shell
ios
android
src
locales
  |__ en.json // English
  |__ zh.json // Chinese
...
```

资源文件如下：

```js
// en.json
{
  "login": {
    "welcome": "Welcome {{name}} to our localized app!",
    "login_button": "Login",
    "signup_button": "Sign Up"
  },
  "user_profile": {
    "title": "Your Profile"  
  }
}
```

```js
// zh.json
{
  "login": {
    "welcome": "欢迎 {{name}} 回来!",
    "login_button": "登录",
    "signup_button": "注册"
  },
  "user_profile": {
    "title": "个人资料"  
  }
}
```

> 需要注意的是，对iOS来说，还需要手动在XCode中添加多语言支持，如下图：
> ![](https://om4ukr2l3.qnssl.com/blog/2018-01-02-072457.jpg)

## 在React Native中使用资源文件

### i18n.js

首先在`locales`目录下新建一个`i18n.js`文件，内容如下：

```js
import ReactNative from 'react-native';
import I18n from 'react-native-i18n';

// Import all locales
import en from './en.json';
import zh from './zh.json';

// Should the app fallback to English if user locale doesn't exists
I18n.fallbacks = true;

// Define the supported translations
I18n.translations = {
  en,
  zh
};

// The method we'll use instead of a regular string
export function strings(name, params = {}) {
  return I18n.t(name, params);
};

export default I18n;
```

在这里引入所有的国际化配置文件，然后封装了一个`strings()`的方法方便其它地方使用。


### 使用国际化字符串

举例如下：

```js
import React, { Component } from 'react';
import {
  View,
  Text,
  Button
} from 'react-native';

import { strings } from '../locales/i18n';

class LoginScreen extends Component {
  constructor(props) {
    super(props);

    this.state = {
      username: 'Daniel'
    };
  }

  render() {
    return (
      <View>
        <Text>{strings('login.welcome', { name: this.state.username })}</Text>
        <Button title={strings('login.login_button')}></Button>
        <Button title={strings('login.singup_button')}></Button>
      </View>
    );
  }
}

export default LoginScreen;
```

上面的示例中，我们可以使用如`login.login_button`的层级调用字符串，还可以通过类似`strings('login.welcome', { name: this.state.username })`的方式指定参数，非常方便。



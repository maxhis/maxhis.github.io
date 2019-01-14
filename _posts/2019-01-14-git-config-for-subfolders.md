---
layout: post
title: "对子目录配置git config"
date: 2019-01-14 19:00:00 +0800
category: 技术
tags: [git]
---

相信很多人跟我一样，在公司和业余使用两个不同的git name和email。正常操作是，设置一个全局的git config，所有repo默认使用；在每个需要特殊处理的repo下单独设置git config。

如果repo数量很少而且固定，这样操作一般是不会有啥问题的，数量一多就很容易忘记单独设置config，从而产生错误git author的commits。

那有没有一劳永逸的方法呢，答案是有，可以通过[git conditional includes](https://git-scm.com/docs/git-config#_conditional_includes)来对不同的目录设置不同的git config，具体步骤如下：

首先设置全局的git config，执行以下：

```shell
git config --global user.name "Name1"
git config --global user.email "name1@example.com"
```
设置后会在用户目录下生成一个`~/.gitconfig`。

然后我们假设用户下有一个`workspace`目录，用于存放业余写的代码，不适合用公司的邮箱提交，我们在该目录下也新建一个`.gitconfig_include`文件，内容如下：

```shell
[user]
	name = Name2
	email = name2@example.com
```

最后，打开`~/.gitconfig`文件，添加一个根据目录判断的条件：

```shell
[includeIf "gitdir:~/workspace/"]
    path = ~/workspace/.gitconfig_include
```

至此，所有在workspace下的repo都会使用workspace下配置的config，而不是全局的。
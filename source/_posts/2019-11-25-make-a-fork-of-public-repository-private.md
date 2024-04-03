---
layout: post
title: "如何将GitHub的公开项目fork为私有项目"
date: 2019-11-25 17:00:00 +0800
category: 技术
tags: [Git]
---

Github对个人用户免费开放私有仓库后，已经将原来的私有项目全部迁移到了GitHub，网络服务还是信赖国外的。今天碰到了一个场景：要把一个public仓库fork为private。想想这应该是挺常见的一个场景，但GitHub并没有提供操作入口。

在这里记录一下我的解决办法：

首先在GitHub网页上新建一个私有repo（姑且叫它private-repo），然后依次执行以下命令就好了：

```shell
git clone --bare https://github.com/exampleuser/public-repo.git
cd public-repo.git
git push --mirror https://github.com/yourname/private-repo.git
cd ..
rm -rf public-repo.git
```

这样，就可以像操作正常私有repo一样操作了，新的repo包含了原repo的所有信息，包括branch和tag等。

**当然，这样操作也有一个弊端：除非你有原public repo的push权限，否则你不能往原repo发送pull request。**
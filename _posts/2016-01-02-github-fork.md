---
layout: post
title: "github fork项目之后，如何与原项目保持同步更新"
description: "Syncing a fork"
category: git
tags: [github]
---


在github上fork一个repo之后，原repo又持续更新，与原repo保持一致是很必要的。简单来说，add一个remote upstream repo就可以解决问题。

<!--more-->

### 配置remote repo 

正常情况下应该只有一个remote repo：
```c
$ git remote -v
origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (fetch)
origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (push)
```

添加原始repo的URL，并命名为upstream：

```c
git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git
```

至此就可以看到两个remote repo：

```c
$ git remote -v
origin    https://github.com/YOUR_USERNAME/YOUR_FORK.git (fetch)
origin    https://github.com/YOUR_USERNAME/YOUR_FORK.git (push)
upstream  https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git (fetch)
upstream  https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git (push)
```
	
### Sync fork repo

现在就可以从原repo（upstream）更新代码了：

```c
git fetch upstream
git checkout master
git merge upstream/master
```
	
如果没有冲突就顺利merge回本地的repo了，若有冲突解决再commit即可。


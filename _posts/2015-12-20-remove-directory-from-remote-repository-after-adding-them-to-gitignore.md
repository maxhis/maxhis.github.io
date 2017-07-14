---
layout: post
title: "Remove directory from remote repository after adding them to .gitignore"
description: "Remove directory from remote repository after adding them to .gitignore"
category: iOS
tags: [git]
---


将不该提交到远程的文件或目录提交到git服务器是件很恼人的事，即使后面把它们加到了`.gitignore`，服务器上的提交还一直在。那有没有什么办法把已经提交到服务器之后又被添加到`.gitignore`里的文件移除呢？答案是肯定的，其实非常简单，几行命令就可以搞定：

<!--more-->
```c
git rm -r --cached . 
git add .
git commit -m 'Removed all files that are in the .gitignore' 
git push origin master
```

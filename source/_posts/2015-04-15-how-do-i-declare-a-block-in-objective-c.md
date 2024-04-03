---
layout: post
title: "How Do I Declare A Block in Objective C"
description: ""
category: iOS
tags: [Objective C]
---


接触OC也有段时间了，对`Block`的语法一直有点犯迷糊，结果发现了一个有意思的网站，[FuckingBlockSyntax](http://fuckingblocksyntax.com/)，下面就是这个网站的全部内容，转载一下，供以后查阅。

<!--more-->

# As a local variable:

```objc
returnType (^blockName)(parameterTypes) = ^returnType(parameters) {...};
```
	
# As a property:

```objc
@property (nonatomic, copy) returnType (^blockName)(parameterTypes);
```
	
# As a method parameter:

```objc
- (void)someMethodThatTakesABlock:(returnType (^)(parameterTypes))blockName;
```
	
# As an argument to a method call:

```objc
[someObject someMethodThatTakesABlock:^returnType (parameters) {...}];
```
	
# As a typedef:

```c-like
typedef returnType (^TypeName)(parameterTypes);
TypeName blockName = ^returnType(parameters) {...};
```

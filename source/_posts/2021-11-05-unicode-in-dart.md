---
layout: post
title: "Dart中处理含unicode的字符串"
date: 2021-11-05 22:00:00 +0800
category: 技术
tags: [Flutter,Dart, Unicode]
---

最近在用Flutter开发一个生成推文图片的app —— Cardit，发现Dart在处理包含emoji的字符串时有些问题，主要是一个emoji的长度并不是1，所以在做类似substring的操作时很麻烦。

## 探索字符串长度

Dart中的String是以UTF-16编码的，已经可以表示绝大部分语言的文字了，包括中文，比如：

```dart
print('hello'.length); // 5
print('中文'.length); // 2
```

所以在处理中文时不用担心，就跟普通拉丁文字一样。而当出现emoji时，情况就不对了：

```dart
print('🍎'.length); // 2
print('👨‍👩‍👧'.length); // 8
```

这种情况要去做字符串截取是很麻烦的，好在虽然Dart foundation中不提供这个能力，但提供了官方的Characters package来处理这种情形。

## Characters package

Flutter中已经默认引入了Characters，可直接使用；如果是纯Dart项目则需要import（不用在`pubspec.yaml`中申明）：

```dart
import 'package:characters/characters.dart';
```

这样长度就正常了：

```dart
print('🍎'.characters.length); // 1
print('👨‍👩‍👧'.characters.length); // 1
```

相当于处理String时先转成Characters再处理，而上面的`characters`，其实是String的一个extension方法：

```dart
import 'characters.dart';

extension StringCharacters on String {
  /// The [Characters] of this string.
  Characters get characters => Characters(this);
}
```

## substrings

最后回到最初的问题，如何像普通String一样处理substring。简单说，使用`getRange(int start, [int? end])`对象就可以了，与`String.substring()`用法几乎一致。

```dart
String str = '🇭🇺👨‍👩‍👧🍎abc';
Characters substring = str.characters.getRange(2);//🍎abc
substring = str.characters.getRange(1, 3);//👨‍👩‍👧🍎
```

而`Characters.toString()`就可以把Characters转化回String对象了。
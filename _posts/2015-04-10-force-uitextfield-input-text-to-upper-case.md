---
layout: post
title: "强制UITextField只能输入大写字母"
description: ""
category: iOS
tags: [iOS,UIKit]
---


这两天在做[深圳通](https://itunes.apple.com/cn/app/id980164721?mt=8)的1.1版，加入了违章查询功能，其中必不可少的是输入车牌号，令人无语的是广东省交管局的系统只认字母是大写的车牌号！在这里顺便吐槽一下官方的这些系统，因为[深圳通](https://itunes.apple.com/cn/app/id980164721?mt=8)的整个数据接口都是用的官方系统，从请求的参数到返回的数据，都相当业余，充其量也就一个应届毕业生的水平，尤其是违章查询系统，那叫一个慢，网络很好的情况下，没有10s是返回不了数据的，很担心会不会因为这么慢，用户都不用我这个APP了：）

<!--more-->

回到正题，让用户每次手动切换到大写输入显然是反人类的，于是翻了一下文档看看有没有解决方法。首先看到了`UITextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters`，看起来像那么回事，run了一下发现根本不working！

这个方法在官方输入法上应该是OK的，但在iOS 8以后开放了第三方输入法之后工作得就不那么好了（只是猜测）。看来要想彻底解决这个问题得从`UITextFieldDelegate`中入手，在输入过程中改成全大写。Show you code：

``` objc
// 转换成全大写字母
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    
    // Check if the added string contains lowercase characters.
    // If so, those characters are replaced by uppercase characters.
    // But this has the effect of losing the editing point
    // (only when trying to edit with lowercase characters),
    // because the text of the UITextField is modified.
    // That is why we only replace the text when this is really needed.
    NSRange lowercaseCharRange;
    lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (lowercaseCharRange.location != NSNotFound) {
        
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:[string uppercaseString]];
        return NO;
    }
    
    return YES;
}
```
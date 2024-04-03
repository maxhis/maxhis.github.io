---
layout: post
title: "UITableView自动加载更多的最佳实践"
description: "UITableView自动加载更多的最佳实践"
category: iOS
tags: [UIKit]
---


实际开发中，一个非常常见的场景是`UITableView`的分页加载，滑动到底部时自动加载更多，大部分开发者的解决方案是监听`UIScrollView`的滑动事件，判断滑动到底部时加载下一页数据，同时为`UITableView addTableFooterView`以展示一个loading的效果(一般是放一个`UIActivityIndicatorView`)。

这种做法有两个缺点：

<!--more-->

1. 当加载完成显示新数据时，新的Cell会替代footer的位置，出现跳动的现象，给人的直接感觉是会“卡顿”一下，很影响体验；
2. 这种方式必须在`- (void)scrollViewDidScroll:(UIScrollView *)scrollView`中判断当前的偏移量以决定什么时机开始加载下一页，这无疑增加了复杂度。

一个更好的解决方案是**把loading more作为一个Cell，而不是footer**，这样，以上两个问题就可以完全避免了。

Talk is cheap，show you code!

```objc
#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_datasource.count && _hasMore)
    {
        return 2; // 增加一个加载更多
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return _datasource.count;
    }
    
    // 加载更多
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 普通Cell，代码省略
        // ...
        
        return cell;
    }
    
    // 加载更多
    static NSString *CellIdentifierLoadMore = @"CellIdentifierLoadMore";
    
    UITableViewCell *loadCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoadMore];
    if (!loadCell)
    {
        loadCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoadMore];
        loadCell.backgroundColor = [UIColor clearColor];
        loadCell.contentView.backgroundColor = [UIColor clearColor];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.tag = kLoadMoreIndicatorTag;
        indicator.hidesWhenStopped = YES;
        indicator.center = CGPointMake(loadCell.dt_width/2, loadCell.dt_height/2);
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|
        			UIViewAutoresizingFlexibleRightMargin|
        			UIViewAutoresizingFlexibleTopMargin|
        			UIViewAutoresizingFlexibleBottomMargin;
        [loadCell.contentView addSubview:indicator];
    }
    
    return loadCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 普通Cell的高度
        // ...
    }
    
    // 加载更多
    return 44;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator startAnimating];
    
    // 加载下一页
    [self loadNextPage];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator stopAnimating];
}
```
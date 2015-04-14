//
//  PullRefreshTableView.m
//  StreamCar
//
//  Created by YangWusheng on 14-8-20.
//  Copyright (c) 2014年 com.Stream. All rights reserved.
//

#import "PullRefreshTableView.h"

#define kPullUpHeight           30.0f
#define kPullDownHeight         60.0f

@interface PullRefreshTableView ()
{
    //下拉刷新
    UIActivityIndicatorView     *pullDownActivityView;
    UILabel                     *showText;
    BOOL                        isRefreshing;
    BOOL                        isDragging;
    
    //上拉加载
    UIActivityIndicatorView     *pullUpActivityView;
    BOOL                        isLoadingMore;
}

@end

@implementation PullRefreshTableView

- (id)initWithTableView:(UITableView *)tableView delegate:(id<PullRefreshTableViewDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _listView = tableView;
        _delegate = delegate;
    }
    return self;
}

- (void)addTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -kPullDownHeight, self.listView.width, kPullDownHeight)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    pullDownActivityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(headerView.width / 2.0 - 15, 10, 30, 30)];
    pullDownActivityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [headerView addSubview:pullDownActivityView];
    pullDownActivityView.hidesWhenStopped = NO;
    
    showText = [[UILabel alloc] initWithFrame:CGRectMake(0, pullDownActivityView.bottom, headerView.width, 20)];
    showText.text = @"下拉刷新";
    showText.textColor = [UIColor darkGrayColor];
    showText.font = [UIFont systemFontOfSize:13.0f];
    showText.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:showText];
    
    [self.listView addSubview:headerView];
    
    isRefreshing = NO;
    isDragging = YES;
}

- (void)addTableFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.listView.width, kPullUpHeight)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    pullUpActivityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(footerView.width / 2.0 - 15, 0, 30, kPullUpHeight)];
    pullUpActivityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [footerView addSubview:pullUpActivityView];
    
    self.listView.tableFooterView = footerView;
    
    isLoadingMore = NO;
}

- (void)scrollViewDidScroll
{
    CGFloat offSet = self.listView.contentOffset.y;
    if (offSet <= -kPullDownHeight && isDragging)
    {
        showText.text = @"松手刷新";
    }
    else if (offSet >= -kPullDownHeight && isDragging)
    {
        showText.text = @"下拉刷新";
        //上拉加载更多
        if (!isLoadingMore)
        {
            CGFloat scrollPosition = 0;
            if (self.listView.contentSize.height > self.listView.frame.size.height)
                scrollPosition = self.listView.contentSize.height - self.listView.frame.size.height - self.listView.contentOffset.y;
            if (scrollPosition < 0)
            {
                [self loadMore];
                isLoadingMore = YES;
            }
        }
    }
}

- (void)scrollViewDidEndDragging
{
    if (!isRefreshing && isDragging && self.listView.contentOffset.y <= -kPullDownHeight)
    {
        isRefreshing = YES;
        [self beginRefresh];
    }
}

- (void)beginRefresh
{
    [pullDownActivityView startAnimating];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.listView.contentInset = UIEdgeInsetsMake(kPullDownHeight, 0, 0, 0);
    } completion:^(BOOL finished) {
        showText.text = @"正在刷新";
        isRefreshing = YES;
        isDragging = NO;
        
        if ([self.delegate respondsToSelector:@selector(beginRefresh)])
            [self.delegate beginRefresh];
    }];
}

//头部更新
- (void)finishRefresh
{
    [pullDownActivityView stopAnimating];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.listView.contentInset = UIEdgeInsetsZero;
        showText.text = @"刷新完成";
    } completion:^(BOOL finished) {
        showText.text = @"下拉刷新";
        isRefreshing = NO;
        isDragging = YES;
    }];
}

//底部更新
- (void)loadMore
{
    [pullUpActivityView startAnimating];
    if ([self.delegate respondsToSelector:@selector(loadMore)])
        [self.delegate loadMore];
}

- (void)finishLoad
{
    [pullUpActivityView stopAnimating];
    isLoadingMore = NO;
}

- (BOOL)isRefreshing
{
    return isRefreshing;
}
- (BOOL)isLoadingMore
{
    return isLoadingMore;
}

@end

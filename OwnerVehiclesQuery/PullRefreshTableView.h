//
//  PullRefreshTableView.h
//  StreamCar
//
//  Created by hjd on 14-11-20.
//  Copyright (c) 2014年 com.Stream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PullRefreshTableViewDelegate <NSObject>

@optional
- (void)beginRefresh;
- (void)loadMore;

@end

@interface PullRefreshTableView : NSObject

@property (nonatomic, assign)   id<PullRefreshTableViewDelegate> delegate;
@property (nonatomic, assign)   UITableView                     *listView;

- (id)initWithTableView:(UITableView *)tableView delegate:(id<PullRefreshTableViewDelegate>)delegate;

- (void)addTableHeaderView;
- (void)addTableFooterView;

- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDragging;

- (void)finishRefresh;
- (void)finishLoad;

- (BOOL)isRefreshing;
- (BOOL)isLoadingMore;

@end

//
//  MyProgress.h
//  CaiChao
//
//  Created by YangWusheng on 13-12-26.
//  Copyright (c) 2013年 YangWusheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProgress : UIView

@property (nonatomic, retain) UILabel *textLabel;

+ (MyProgress *)showMyProgressToView:(UIView *)view animated:(BOOL)animated;

- (void)setText:(NSString *)newText;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end

//
//  MyProgress.m
//  CaiChao
//
//  Created by YangWusheng on 13-12-26.
//  Copyright (c) 2013年 YangWusheng. All rights reserved.
//

#import "MyProgress.h"
#import <QuartzCore/QuartzCore.h>

#define kFontSize           14.0f

@interface MyProgress ()
{
    UIActivityIndicatorView *indicatorView;
    UIView                  *backView;
}

- (void)initSubviews;

@end

@implementation MyProgress

+ (MyProgress *)showMyProgressToView:(UIView *)view animated:(BOOL)animated;
{
    MyProgress *progress = [[MyProgress alloc] initWithFrame:view.bounds];
    [view addSubview:progress];
    [progress show:animated];
    return progress;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.4]];
        [self initSubviews];
    }
    return self;
}

- (void)setText:(NSString *)newText
{
    self.textLabel.text = newText;
}

- (void)initSubviews
{
    backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    backView.layer.cornerRadius = 6;
    backView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    backView.layer.shadowOffset = CGSizeMake(0, 5);
    backView.layer.shadowOpacity = 0.8;
    backView.layer.cornerRadius = 5;
    [self addSubview:backView];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [backView addSubview:indicatorView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
    [backView addSubview:_textLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (nil != _textLabel.text)
    {
        CGSize textSize = [Helper getContentActualSize:_textLabel.text WithFont:_textLabel.font];
        NSUInteger textWidth = textSize.width;
        NSUInteger textHeight = textSize.height;
        if (textWidth > 50)
        {
            backView.frame = CGRectMake(self.frame.size.width / 2.0 - textWidth / 2.0 - 10, self.frame.size.height / 2.0 - textHeight / 2.0 - 25 - 10, textWidth + 20, textHeight + 50);
            indicatorView.frame = CGRectMake(textWidth / 2.0 - 25 + 10, 0, 50, 45);
            _textLabel.frame = CGRectMake(backView.frame.size.width / 2.0 - (textWidth + 10)/2.0, 45, textWidth + 10, textHeight);
        }
        else
        {
            backView.frame = CGRectMake(self.frame.size.width / 2.0 - 25, self.frame.size.height / 2.0 - 25 - textHeight / 2.0, 50, 50 + textHeight);
            indicatorView.frame = CGRectMake(0, 0, 50, 45);
            _textLabel.frame = CGRectMake(backView.frame.size.width / 2.0 - (textWidth + 10) / 2.0, 45, textWidth + 10, textHeight);
        }
    }
    else
    {
        backView.frame = CGRectMake(self.frame.size.width / 2.0 - 40, self.frame.size.height / 2 - 40, 80, 80);
        indicatorView.frame = CGRectMake(0, 0, 80, 80);
    }
}

- (void)show:(BOOL)animated;
{
    [indicatorView startAnimating];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
}

@end

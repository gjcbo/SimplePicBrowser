//
//  RBWaitingView.m
//  图片选择器
//
//  Created by RaoBo on 2018/3/31.
//  Copyright © 2018年 关键词. All rights reserved.
//

#import "RBWaitingView.h"
#define kRBWaitingItemMargin 3
#define kRBWaitingViewBGC [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

@implementation RBWaitingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 5;
        self.style = RBWaitingStyleLoop;
    }
    return self;
}

#pragma mark - set方法
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
    
    if (progress >= 1) { // 加载完成，移除进度
        [self removeFromSuperview];
    }
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect
{
    // 创建上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat rw = rect.size.width;
    CGFloat rh = rect.size.height;
    
    CGFloat xCenter = rw * 0.5;
    CGFloat yCenter = rh * 0.5;
    
    // 设置颜色
    [[UIColor whiteColor] set];
    
    switch (self.style) {
        case RBWaitingStylePie:
        {
            CGFloat radius = MIN(rw*0.5, rh*0.5) - kRBWaitingItemMargin;
            CGFloat w = radius * 2 + kRBWaitingItemMargin;
            CGFloat h = w;
            CGFloat x = (rw - w) * 0.5;
            CGFloat y = (rh - h) * 0.5;
            
            CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
            CGContextFillPath(ctx);
            
            [kRBWaitingViewBGC set];
            CGContextMoveToPoint(ctx, xCenter, 0);
            CGFloat to = - M_PI * 0.5 + _progress * M_PI * 2 + 0.001; // 初始值
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
            CGContextClosePath(ctx);
            CGContextFillPath(ctx);
        }
            break;
            
        default:
        {
            CGContextSetLineWidth(ctx, self.bounds.size.width/4);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
            CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - kRBWaitingItemMargin;
            CGContextAddArc(ctx, xCenter, yCenter, radius, -M_PI*0.5, to, 0);
            CGContextStrokePath(ctx);
        }
            break;
    }
}
@end

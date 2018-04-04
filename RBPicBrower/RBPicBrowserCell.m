//
//  RBPicBrowserCell.m
//  图片选择器
//
//  Created by RaoBo on 2018/3/31.
//  Copyright © 2018年 关键词. All rights reserved.
//

#import "RBPicBrowserCell.h"
#import "RBGestureView.h"
@implementation RBPicBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _gestureView = [[RBGestureView alloc] init];
        _gestureView.frame = self.bounds;
        
        [self.contentView addSubview:_gestureView];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    [_gestureView.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}
@end

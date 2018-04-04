//
//  RBGestureView.m
//  图片选择器
//
//  Created by RaoBo on 2018/3/31.
//  Copyright © 2018年 关键词. All rights reserved.
//

#define kRBScreenW [UIScreen mainScreen].bounds.size.width
#define kRBScreenH [UIScreen mainScreen].bounds.size.height
#define kRBScreenScale kRBScreenW / kRBScreenH

#import "RBGestureView.h"
#import "RBWaitingView.h"
#import "UIImageView+WebCache.h"

@interface RBGestureView() <UIScrollViewDelegate>
@property(nonatomic, strong) RBWaitingView *waitingView; // 显示进度view
@end


@implementation RBGestureView
{
    CGFloat _originScale; // 原图尺寸
    CGFloat _lastScale; // 缩放后的尺寸
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 布局子视图
        [self createSubViews];
        
    }
    return self;
}
#pragma mark - UI
- (void)createSubViews{
    
    [self createScrollView];
    
    [self createImageView];
}

- (RBWaitingView *)waitingView{
    if (!_waitingView) {
        _waitingView = [[RBWaitingView alloc] init];
        _waitingView.center = self.center;
        _waitingView.bounds = CGRectMake(0, 0, 40, 40);
        _waitingView.style = RBWaitingStyleLoop;
    }
    return _waitingView;
}

- (void)createScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.minimumZoomScale = 1.0;
    
    [self addSubview:_scrollView];
}

- (void)createImageView
{
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_scrollView addSubview:_imageView];
}

#pragma mark - layoutSubViews
- (void)layoutSubviews{
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark - 外部接口实现
- (void)rb_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    // 如果连占位图都没有直接返回
    if (!placeholder) {
        return;
    }
    CGSize imgSize = placeholder.size; // 缩略图尺寸
    CGFloat imgScale = imgSize.width / imgSize.height; // 图片的长宽比,用于判断是否为长图，如果图片的长宽比大于‘屏幕的长宽比’ 说明图片过大，需要等比缩放图片，最大状况为手机屏幕那么大
    
    // 320、 568 = 0.563
    // 375、 667 = 0.562
    
    
    if (imgScale >= kRBScreenScale) { //不是长图
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _scrollView.contentSize = _imageView.frame.size;
    }else {
        //如果
        CGSize size = CGSizeMake(kRBScreenW, kRBScreenW * (1/imgScale));
        _imageView.frame = CGRectMake(0, 0, size.width, size.height);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;//?
        
        _scrollView.contentSize = size;
    }
    
    
    // 根据url显示图片
    [self showImgWithURL:url placeHolderImage:placeholder imgViewScale:imgScale];
}

// 利用SD显示图片
- (void)showImgWithURL:(NSURL *)url placeHolderImage:(UIImage *)placeholder imgViewScale:(CGFloat)imgScale
{
    if (url) {
        [_imageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            // 显示加载进度
            [self addSubview:self.waitingView];
            
            if (expectedSize) {
                double prog = receivedSize * 0.1 / expectedSize;
                self.waitingView.progress = prog;
            }else{ // 已经加载完
                self.waitingView.progress = 1.0;
            }
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (error) {
                [self showErrow];
            } else {
                // 根据下载的图片计算最大缩放比例
                
                CGFloat imgW = image.size.width;
                CGFloat imgH = image.size.height;
                
                if (imgScale >= kRBScreenScale) {//?
                    // 屏幕可以完全显示
                    _scrollView.maximumZoomScale = MAX((imgW / kRBScreenW), 1.2);
                }else { //?
                    _scrollView.maximumZoomScale = MAX((imgH / kRBScreenH), 1.2);
                }
            }
        }];
        
    } else { // 显示占位图
        _imageView.image = placeholder;
        if (imgScale >= kRBScreenScale) {
 // 不是长图
            _scrollView.maximumZoomScale = MAX(placeholder.size.width/kRBScreenW, 1.2);
        }else { // 长图
            _scrollView.maximumZoomScale = MAX(placeholder.size.height/kRBScreenH, 1.2);
        }
        
    }
    
}

#pragma mark - showError
- (void)showErrow
{
    [self.waitingView removeFromSuperview];
    
    // 加载失败
    UILabel *failLabel = [[UILabel alloc] init];
    failLabel.bounds = CGRectMake(0, 0, 160, 30);
    failLabel.center = self.center;
    failLabel.font = [UIFont systemFontOfSize:16];
    failLabel.text = @"图片加载失败";
    failLabel.textColor = [UIColor whiteColor];
    failLabel.textAlignment = NSTextAlignmentCenter;
    failLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]; // 黑色
    failLabel.clipsToBounds = YES;
    failLabel.layer.cornerRadius = 5;
    failLabel.alpha = 0; // 默认为0,看不见,通过透明度显示动画效果
    
    [self addSubview:failLabel];
    
    [UIView animateWithDuration:0.8 animations:^{
        failLabel.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.8 animations:^{
            failLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [failLabel removeFromSuperview];
        }];
    }];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */



@end

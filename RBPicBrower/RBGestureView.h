//
//  RBGestureView.h
//  图片选择器
//
//  Created by RaoBo on 2018/3/31.
//  Copyright © 2018年 关键词. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBGestureView : UIView
/**scrollview 贴到 self上*/
@property(nonatomic, strong) UIScrollView *scrollView;
/**图片View 贴到 scrollView上*/
@property(nonatomic, strong) UIImageView *imageView;


/**
 给 imageView设置图片

 @param url 图片url,为空时,显示占位图
 @param placeholder 占位图
 */
- (void)rb_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end

//
//  RBPicBrowser.h
//  图片选择器
//
//  Created by RaoBo on 2018/4/1.
//  Copyright © 2018年 关键词. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBPicBrowser : UIViewController
+ (RBPicBrowser *)sharedBrowser;

- (void)rb_showPhotoBrowserWithUrls:(NSArray *)urls imageView:(UIImageView *)imgView presentByController:(UIViewController *)presentedByVC;

@end

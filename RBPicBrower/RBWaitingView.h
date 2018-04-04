//
//  RBWaitingView.h
//  图片选择器
//
//  Created by RaoBo on 2018/3/31.
//  Copyright © 2018年 关键词. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, RBWaitingStyle) {
    RBWaitingStyleLoop, // 环形
    RBWaitingStylePie // 饼形
};

@interface RBWaitingView : UIView

/**进度 */
@property (nonatomic, assign) CGFloat progress;

/**进度条样样式 默认环形*/
@property (nonatomic, assign) RBWaitingStyle style;



@end

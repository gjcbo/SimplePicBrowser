//
//  ViewController.m
//  SimplePicBrowser
//
//  Created by RaoBo on 2018/4/4.
//  Copyright © 2018年 关键词. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "RBPicBrowser.h"

@interface ViewController ()

/**imageView*/
@property(nonatomic, strong) UIImageView *imgView;
@end

@implementation ViewController
{
    NSArray *_imgURLArr;
}

#pragma mark - lazy
- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPicAction:)];
        [_imgView addGestureRecognizer:tapG];
    }
    
    return _imgView;
}

- (void)clickPicAction:(UITapGestureRecognizer *)tap
{
    NSLog(@"点击了图片");
    
    NSArray *imgURLArr = [self picURLs];
    
    [[RBPicBrowser sharedBrowser] rb_showPhotoBrowserWithUrls:imgURLArr imageView:_imgView presentByController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *tipsLb = [[UILabel alloc] initWithFrame:CGRectMake(50, 400, 200, 50)];
    tipsLb.text = @"点击图片查看";
    tipsLb.backgroundColor = [UIColor brownColor];
    [self.view addSubview:tipsLb];
    
    // UIImageView
    self.imgView.frame = CGRectMake(10, 100, 300, 250);
    NSURL *imgUrl = [NSURL URLWithString:@"http://www.airshe.com/Uploads/roomimg/2018-03-30/5abdb46baf120.jpg"];
    [self.imgView sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
    [self.view addSubview:self.imgView];
}

- (NSArray *)picURLs{
    NSArray *urls = @[
                      @"http://www.airshe.com/Uploads/roomimg/2018-03-30/5abdb46baf120.jpg",
                      @"http://www.airshe.com/Uploads/roomimg/2018-03-30/5abdb46c43ee3.jpg",
                      @"http://www.airshe.com/Uploads/roomimg/2018-03-30/5abdb46c90bba.jpg",
                      @"http://www.airshe.com/Uploads/roomimg/2018-03-30/5abdb46ccd8d1.jpg",
                      @"http://www.airshe.com/Uploads/roomimg/2018-03-30/5abdb46cd7e13.jpg",
                      @"http://www.airshe.com/Uploads/roomimg/2018-03-30/5abdb46d0a621.jpg"
                      ];
    
    return urls;
}
@end

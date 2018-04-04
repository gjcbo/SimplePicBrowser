//
//  RBPicBrowser.m
//  图片选择器
//
//  Created by RaoBo on 2018/4/1.
//  Copyright © 2018年 关键词. All rights reserved.
//
#define kScreen_W [UIScreen mainScreen].bounds.size.width
#define kScreen_H [UIScreen mainScreen].bounds.size.height
#define kKeyWindow [UIApplication sharedApplication].keyWindow
#define kPhotoPadding 10
#define kDurationTime 0.35
#define kScreenScale (kScreen_W / kScreen_H)

#import "RBPicBrowser.h"
#import "RBPicBrowserCell.h"
#import "RBGestureView.h"
#import "UIImageView+WebCache.h"


@interface RBPicBrowser()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>
{
    NSArray *_urls;
    UIImageView *_imageView; // 外面传进来的imageView
    UIViewController *_presentedVC; // 记录外面传进来的控制器,用于模态出当前视图
    NSInteger _currentIndex; // 记录当前选中的图片的下标
    BOOL _isScale; // 记录图片是否没放大过(放大过、放大后又还原也算是放大过)
    UITapGestureRecognizer *_singleTap; // 单击
    UITapGestureRecognizer *_doubleTap; // 双击
}

/**当前选中的是第一个图片文字和提示Label*/
@property(nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation RBPicBrowser

static NSString *picBrowserCellId = @"picBrowserCellId";

+ (RBPicBrowser *)sharedBrowser
{
    static RBPicBrowser *shareBr = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shareBr = [[RBPicBrowser alloc] init];
    });
    
    return shareBr;
}

#pragma mark - 一 init
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(0, 0, kScreen_W, kScreen_H);
        self.view.backgroundColor = [UIColor blackColor];
        
        _isScale = NO; // 一开始缩放状态为 NO
        
        [self prepared];
    }
    
    return self;
}

- (void)prepared
{
    [self createCollectionView];
    
    // 单击
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesAction:)];
    [self.view addGestureRecognizer:_singleTap];
    
    // 双击
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesAction:)];
    _doubleTap.numberOfTapsRequired = 2;
    [_singleTap requireGestureRecognizerToFail:_doubleTap]; // 禁用单击手势。
    [self.view addGestureRecognizer:_doubleTap];
}

#pragma mark- 手势
- (void)singleTapGesAction:(UITapGestureRecognizer *)tapGes
{
    NSLog(@"单击");
    _singleTap.enabled = NO;
    _doubleTap.enabled = NO;
    
    if (_isScale) {
        NSLog(@"111111");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    } else {
        NSLog(@"222222");
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)doubleTapGesAction:(UITapGestureRecognizer *)doubleTap
{
    NSLog(@"双击");
    _singleTap.enabled = NO;
    _doubleTap.enabled = NO;
    
    CGPoint doubleTapPoint = CGPointZero;
    if (doubleTap) { //
        doubleTapPoint = [doubleTap locationInView:self.view];
    }
    
    RBPicBrowserCell *cell = [self.collectionView.visibleCells firstObject];
    UIScrollView *scrollView = cell.gestureView.scrollView;
    
    if (scrollView.zoomScale == 1) {//原始状态、双击放大
        if (!doubleTap) return;
        
        [cell.gestureView.scrollView setZoomScale:2.0f animated:YES]; // 放大一倍
        
        _isScale = YES; // 将图片状态设置为放大状态。
        
    } else {  //放大状态、双击还原
        
        _isScale = (scrollView.contentOffset.y != 0); // 如果还原后,切scrollView未滚动,默认还是处于缩放状态
        [scrollView setZoomScale:1.0f animated:YES];
    }
    
    // 解决bug:防止用户连续点击
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _singleTap.enabled = YES;
        _doubleTap.enabled = YES;
    });
}


#pragma mark - 二 UI & set
- (void)createCollectionView
{
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:(UICollectionViewScrollDirectionHorizontal)];
    flowLayout.itemSize = mainBounds.size;
    
    flowLayout.minimumLineSpacing = kPhotoPadding;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:mainBounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    
    [_collectionView registerClass:[RBPicBrowserCell class] forCellWithReuseIdentifier:picBrowserCellId];
    
    [self.view addSubview:_collectionView];
}

#pragma mark - 三 UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RBPicBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:picBrowserCellId forIndexPath:indexPath];
    
    UIImageView *originIv = _imageView;
    
    // 设置图片,并显示下载进度图
    if (_urls.count) {
        NSURL *url = [_urls[indexPath.row] isKindOfClass:[NSString class]] ? [NSURL URLWithString:_urls[indexPath.row]] : _urls[indexPath.row];
        
        [cell.gestureView rb_setImageWithURL:url placeholderImage:originIv.image];
    }
    return cell;
}

#pragma mark - 四 UIScrollViewDelegate
// 在scrollView代理方法中手动 计算分页
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    CGFloat pageW = self.collectionView.frame.size.width + kPhotoPadding; // w + space
//    CGFloat currentOffset = scrollView.contentOffset.x;
//    CGFloat targetOffset = targetContentOffset->x; // -> 访问结构体成员
//    CGFloat newTargetOffset = 0;
//
//    if (targetOffset > currentOffset) {
//        // 向上取整数 ceilf  https://www.jianshu.com/p/0ca725ecf7f7
//        newTargetOffset = ceilf(currentOffset / pageW);
//    } else {
//        // 向下取整
//        newTargetOffset = floorf(currentOffset / pageW) * pageW;
//    }
//
//    if (newTargetOffset < 0) {
//        newTargetOffset = 0;
//    }else if (newTargetOffset  > scrollView.contentSize.width){
//        newTargetOffset = scrollView.contentSize.width;
//    }
//
//    targetContentOffset->x = currentOffset;
//
//    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
//
//    // 设置当前页码
//    _currentIndex = newTargetOffset / pageW;
//    [self currentIndex:_currentIndex totoalCount:_urls.count];
//}

#pragma mark - 五 私有方法
- (void)show
{
    self.view.hidden = YES; // 先加载图片,加载完之后在让他显示
    
    // present self
    [_presentedVC presentViewController:self animated:NO completion:^{
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];
    
    // 设置偏移量
    CGFloat offsetY = _currentIndex * (kScreen_W + kPhotoPadding);
    
    self.collectionView.contentOffset = CGPointMake(offsetY, 0);
}

/**当前选中图片是总图片中的第几张*/
- (void)currentIndex:(NSInteger)index totoalCount:(NSInteger)count
{
    if (count == 1) {
        self.indexLabel.text = nil;
    } else {
        // 调整字间距的富文本
        NSString *indexStr = [NSString stringWithFormat:@"%li/%li",(long)index+1, (long)count];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
        
        attDic[NSParagraphStyleAttributeName] = paragraphStyle;
        attDic[NSKernAttributeName] = @2;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:indexStr attributes:attDic];
        
        self.indexLabel.attributedText = attStr;
    }
}

#pragma mark - 六 执行动画效果
- (void)performZoomInAnimation
{
    // 1、获取原图
    UIImageView *originIv = _imageView;
    CGSize imgSize  =originIv.image.size;
    CGFloat imgScale = imgSize.width / imgSize.height;
    
    //2.复制图片
    UIImageView *imageViewC = [UIImageView new];
    imageViewC.contentMode = originIv.contentMode;
    imageViewC.image = originIv.image;
    imageViewC.frame = [originIv.superview convertRect:originIv.frame toView:kKeyWindow]; // convert坐标转换
    
    // 3.更具图片宽高比计算imageViewC的bounds以及center
    CGPoint center ;
    CGRect rect = imageViewC.bounds;
    rect.size.width = kScreen_W;
    rect.size.height = rect.size.width * (1/imgScale);
    if (imgScale >= kScreenScale) { // 判断屏幕是否可以完全显示
        center = self.view.center;
    } else {
        center = CGPointMake(kScreen_W/2, rect.size.height/2);
    }
    
    // 将bounds和center转为frame
    CGFloat rw = rect.size.width;
    CGFloat rh = rect.size.height;
    CGFloat cX = center.x;
    CGFloat cY = center.y;
    CGRect zoomInRect = CGRectMake(cX - rw/2, cY-rh/2, rw, rh);
    
    // 动画
    [self animateImageView:imageViewC toRect:zoomInRect];
}

- (void)perfomrZoonOutAnimation
{
    // 恢复状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    // 获取图片
    RBPicBrowserCell *cell = [self.collectionView.visibleCells firstObject];
    UIImageView *imgView = cell.gestureView.imageView;
    CGSize imgSize = imgView.image.size;
    CGFloat imgScale = imgSize.width / imgSize.height;
    
    // 拷贝一份图片
    UIImageView *ivC = [UIImageView new];
    ivC.contentMode = UIViewContentModeScaleAspectFill;
    ivC.clipsToBounds = YES;
    ivC.image = imgView.image;
    
    // 3.按照cell中图片的size设置图片的frame
    CGRect rect = ivC.bounds;
    rect.size.width = kScreen_W;
    rect.size.height = rect.size.width * (1 /imgScale);
    
    // 根据scrollView滚动的距离计算中心点
    // 真心复杂.日了狗了。不想搞了。崩溃了. 对scrollView的属性不熟。 算的蛋疼
    CGPoint scrollCenter = CGPointMake(imgView.center.x - cell.gestureView.scrollView.contentOffset.x, imgView.center.y - cell.gestureView.scrollView.contentOffset.y);
    
    ivC.center = scrollCenter;
    ivC.bounds = rect;
    
    // 动画
    [self animateImageView:ivC toRect:ivC.frame];
    
    // 重置scrollView
    [cell.gestureView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


- (void)animateImageView:(UIImageView *)imageView toRect:(CGRect)destinationRect{
    // 设置蒙版
    UIView *cover = [[UIView alloc] initWithFrame:kKeyWindow.bounds];
    cover.backgroundColor = [UIColor blackColor];
    [kKeyWindow addSubview:cover];
    
    //2.添加图片
    [cover addSubview:imageView];
    
    // 判断是否缩放了
    BOOL isZoomIn = self.view.hidden;
    
    UIImageView *originPic = _imageView;
    
    if ((originPic.tag != _currentIndex) && !isZoomIn) {
        // 关键点: 让手势可用
        _singleTap.enabled = YES;
        _doubleTap.enabled = YES;
        
        [cover removeFromSuperview];
    } else {
        originPic.hidden = YES;
        
        _singleTap.enabled = YES;
        _doubleTap.enabled = YES;
        
        [cover removeFromSuperview];
        
        // 恢复原图
        originPic.hidden = NO;
        if (isZoomIn) {
            self.view.hidden = NO; //让view显示
        }
    }
}


#pragma makr - 接口
- (void)rb_showPhotoBrowserWithUrls:(NSArray *)urls imageView:(UIImageView *)imgView presentByController:(UIViewController *)presentedByVC
{
    _currentIndex = 0;
    _urls = urls;
    _presentedVC = presentedByVC;
    _imageView = imgView;
    
    [self.collectionView reloadData];
    
    [self show];
    
    // 必须调用给你
    [self performZoomInAnimation];
}

@end


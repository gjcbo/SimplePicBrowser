# SimplePicBrowser
简易图片浏览器
功能有限:1.点击可以浏览图片。2.双击放大、单击消失。
实现思路:主要是用collectionView 来写的。用SDWebImage获取网络图片。
使用
```
// 传一个图片数组、传一个当前点击的图片、和当前视图控制器。
 [[RBPicBrowser sharedBrowser] rb_showPhotoBrowserWithUrls:imgURLArr imageView:_imgView presentByController:self];
```

![1单输入框](https://github.com/gjcbo/SimplePicBrowser/raw/master/Pictures/简易图片浏览器.gif)


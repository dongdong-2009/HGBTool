//
//  HGBScreenShotTool.m
//  VirtualCard
//
//  Created by huangguangbao on 2017/6/24.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBScreenShotTool.h"

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBScreenShotTool
/**
 截屏
 
 @param view 要截屏的界面
 */
+(UIImage *)shotCurrentScreenWithView:(UIView *)view{
    if(view==nil){
        HGBLog(@"view不能为空");
        return nil;
    }
    CGSize boundsSize = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(boundsSize, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return image;
}
/**
 截屏
 
 @param webview 要截屏的界面
 */
+(UIImage *)shotFullScreenWithView:(UIWebView *)webview{
    if(webview==nil){
        HGBLog(@"webview不能为空");
        return nil;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize boundsSize = webview.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize contentSize = webview.scrollView.contentSize;
    CGFloat contentHeight = contentSize.height;
    
    CGPoint offset = webview.scrollView.contentOffset;
    
    [webview.scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, 0.0);
        [webview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        
        CGFloat offsetY = webview.scrollView.contentOffset.y;
        [webview.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    
    [webview.scrollView setContentOffset:offset];
    
    CGSize imageSize = CGSizeMake(contentSize.width * scale,
                                  contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0,
                                     scale * boundsHeight * idx,
                                     scale * boundsWidth,
                                     scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}


@end

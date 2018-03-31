//
//  HGBCordovaController.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/13.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */


/**
 按钮拖动类型
 */
typedef enum HGBCordovaCloseButtonDragType
{
    HGBCordovaCloseButtonDragTypeNO,//无拖拽
    HGBCordovaCloseButtonDragTypeNOLimit,//无限制
    HGBCordovaCloseButtonDragTypeBorder//贴边

}HGBCordovaCloseButtonDragType;

/**
 按钮初始位置
 */
typedef enum HGBCordovaCloseButtonPositionType
{
    HGBCordovaCloseButtonPositionTypeTopLeft,//左上角
    HGBCordovaCloseButtonPositionTypeTopRight,//右上角
    HGBCordovaCloseButtonPositionTypeBottomLeft,//左下角
    HGBCordovaCloseButtonPositionTypeBottomRight//右下角

}HGBCordovaCloseButtonPositionType;


@interface HGBCordovaController : CDVViewController
/**
 是否显示返回按钮
 */
@property(assign,nonatomic)BOOL isShowReturnButton;
/**
 返回按钮拖拽类型
 */
@property(assign,nonatomic)HGBCordovaCloseButtonDragType   returnButtonDragType;

/**
 返回按钮初始位置
 */
@property(assign,nonatomic)HGBCordovaCloseButtonPositionType returnButtonPositionType;

/**
 加载html

 @param source 路径或url或html字符串
 */
-(BOOL)loadHtmlSource:(NSString *)source;
/**
 加载html

 @param source 路径或url或html字符串
 @param baseUrl 基础路径或url或html字符串
 */
-(BOOL)loadHtmlSource:(NSString *)source andWithBaseUrl:(NSString *)baseUrl;

@end

@interface HGBCordovaCommandDelegate : CDVCommandDelegateImpl
@end

@interface HGBCordovaCommandQueue : CDVCommandQueue
@end


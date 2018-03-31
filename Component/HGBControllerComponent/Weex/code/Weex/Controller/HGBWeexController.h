//
//  HGBWeexController.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/13.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>


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
typedef enum HGBWeexCloseButtonDragType
{
    HGBWeexCloseButtonDragTypeNO,//无拖拽
    HGBWeexCloseButtonDragTypeNOLimit,//无限制
    HGBWeexCloseButtonDragTypeBorder//贴边

}HGBWeexCloseButtonDragType;

/**
 按钮初始位置
 */
typedef enum HGBWeexCloseButtonPositionType
{
    HGBWeexCloseButtonPositionTypeTopLeft,//左上角
    HGBWeexCloseButtonPositionTypeTopRight,//右上角
    HGBWeexCloseButtonPositionTypeBottomLeft,//左下角
    HGBWeexCloseButtonPositionTypeBottomRight//右下角

}HGBWeexCloseButtonPositionType;
@interface HGBWeexController : UIViewController
/**
 是否显示返回按钮
 */
@property(assign,nonatomic)BOOL isShowReturnButton;
/**
 返回按钮拖拽类型
 */
@property(assign,nonatomic)HGBWeexCloseButtonDragType   returnButtonDragType;

/**
 返回按钮初始位置
 */
@property(assign,nonatomic)HGBWeexCloseButtonPositionType returnButtonPositionType;

/**
 加载html

 @param source 路径或url或js字符串
 */
-(BOOL)loadJSSource:(NSString *)source;
/**
 加载js

 @param source 路径或url或js字符串
 @param baseUrl 基础路径或url或js字符串
 */
-(BOOL)loadJSSource:(NSString *)source andWithBaseUrl:(NSString *)baseUrl;
@end


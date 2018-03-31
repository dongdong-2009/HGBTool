//
//  HGBFileManageController.h
//  测试
//
//  Created by huangguangbao on 2017/8/14.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGBFileModel.h"

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */


/**
 文件管理样式
 */
typedef enum HGBFileManageStyle
{
    HGBFileManageStyleTable,//列表
    HGBFileManageStyleSpaceCollection,//留白表格
    HGBFileManageStyleFullCollection,//饱满表格
    HGBFileManageStyleSwitch//样式选择

}HGBFileManageStyle;
/**
 文件管理样式
 */
typedef enum HGBFileManageClickStyle
{
    HGBFileManageClickStyleOpen,//首选打开模式
    HGBFileManageClickStyleSelect//首选选择模式

}HGBFileManageClickStyle;

/**
 文件管理代理
 */
@protocol HGBFileManageControllerDelegate <NSObject>

/**
 返回选中文件路径

 @param url 快捷路径
 */
-(void)fileManageDidReturnFileUrl:(NSString *)url;
@optional
/**
 返回选中文件路径

 @param path 路径
 */
-(void)fileManageDidReturnFilePath:(NSString *)path;
/**
 取消文件管理
 */
-(void)fileManageDidCanced;
@end





@interface HGBFileManageController : UIViewController
//@property(assign,nonatomic)
/**
 代理
 */
@property(strong,nonatomic)id<HGBFileManageControllerDelegate>delegate;
/**
 样式
 */
@property(assign,nonatomic)HGBFileManageStyle style;
/**
 选择模式
 */
@property(assign,nonatomic)HGBFileManageClickStyle clickStyle;
/**
 根路径
 */
@property(strong,nonatomic)NSString *basePath;


@end

//
//  HGBFileWebController.h
//  测试
//
//  Created by huangguangbao on 2017/8/17.
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
@interface HGBFileWebController : UIViewController

/**
 导航栏

 @param title 标题
 */
-(void)createNavigationItemWithTitle:(NSString *)title;

/**
 加载url

 @param source 路径或url或html界面
 */
-(void)loadHtmlSource:(NSString *)source;


/**
 打开工具栏

 @param type 打开方式 0 显示工具栏开启按钮 1直接显示工具栏
 */
-(void)openToolBarWithType:(NSInteger)type;

@end

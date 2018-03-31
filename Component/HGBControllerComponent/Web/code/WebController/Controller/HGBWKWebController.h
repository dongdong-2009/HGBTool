//
//  HGBWKWebController.h
//  测试app
//
//  Created by huangguangbao on 2017/7/12.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


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
 基础浏览器代理
 */
@protocol  HGBWKWebControllerDelegate <NSObject>
@optional
@end
@interface HGBWKWebController : UIViewController<WKScriptMessageHandler>
@property(strong,nonatomic)id<HGBWKWebControllerDelegate>delegate;

/**
 导航栏
 
 @param title 标题
 */
-(void)createNavigationItemWithTitle:(NSString *)title;

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

/**
 打开工具栏
 
 @param type 打开方式 0 显示工具栏开启按钮 1直接显示工具栏
 */
-(void)openToolBarWithType:(NSInteger)type;
@end

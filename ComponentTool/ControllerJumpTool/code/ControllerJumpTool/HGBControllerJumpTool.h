//
//  HGBControllerJumpTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HGBControllerJumpTool : NSObject
#pragma mark Present-Dismiss 模态
/**
 模态视图推出-有导航栏

 @param controller 控制器
 */
+(void)presentControllerWithNavgation:(UIViewController *)controller;


/**
 模态视图推出-无导航栏

 @param controller 控制器
 */
+(void)presentController:(UIViewController *)controller;



/**
 返回到上一级控制器
 */
+(void)dismissToParentViewController;
/**
 返回到根视图控制器
 */
+(void)dismissToRootViewController;

/**
 返回到指定控制器

 @param controllerName 控制器名称
 */
+(void)dismissToControllerWithControllerName:(NSString *)controllerName;

/**
 返回指定次数

 @param count 返回层数
 */
+(void)dismissToControllerWithDismissCount:(NSInteger)count;

#pragma mark Push-Pop
/**
 视图推出

 @param controller 控制器
 */
+(void)pushController:(UIViewController *)controller;
/**
 返回到上一层控制器
 */
+(void)popToParentViewController;
/**
 返回到根层视图控制器
 */
+(void)popToRootViewController;

/**
 返回到指定层控制器

 @param controllerName 控制器名称
 */
+(void)popToControllerWithControllerName:(NSString *)controllerName;

/**
 返回指定次数

 @param count 返回层数
 */
+(void)popToControllerWithPopCount:(NSInteger)count;
@end

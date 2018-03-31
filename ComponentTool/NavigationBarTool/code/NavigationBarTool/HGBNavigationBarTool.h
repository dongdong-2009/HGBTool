//
//  HGBNavigationBarTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 导航栏元素位置
 */
typedef enum HGBNavigationItem
{
    HGBNavigationItemTitle,//标题
    HGBNavigationItemLeft,//左按钮
    HGBNavigationItemRight//右侧按钮
}HGBNavigationItem;


@interface HGBNavigationBarTool : NSObject
#pragma mark 导航栏整体
/**
 设置当前导航栏显示隐藏

 @param isHidden 是否隐藏
 */
+(void)setNavgationBarIsHidden:(BOOL)isHidden;


/**
 修改当前导航栏的颜色

 @param color 颜色
 */
+(void)changeNavgationBarColor:(UIColor *)color;
/**
 修改所有导航栏的颜色

 @param color 颜色
 */
+(void)changeAllNavgationBarColor:(UIColor *)color;


#pragma mark 导航栏创建
/**
 快捷创建导航栏-仅有标题和左按钮

 @param title 标题
 @param target 目标
 @param action 左按钮事件
 @param controller 控制器
 */
+(void)createNavigationItemWithTitle:(NSString *)title andWithTarget:(id)target andWithLeftAction:(SEL)action inController:(UIViewController *)controller;

/**
 创建导航栏-标题按钮多个采用segment

 @param type  导航栏类型
 @param titles 标题集合
 @param target 目标
 @param action 事件
 @param controller 控制器
 */
+(void)createNavigationItem:(HGBNavigationItem )type andWithTitles:(NSArray <NSString *>*)titles andWithTarget:(id)target andWithAction:(SEL)action inController:(UIViewController *)controller;
/**
 创建导航栏-标题按钮多个采用segment

 @param titles 标题集合 R L T
 @param target 目标
 @param action 事件
 @param controller 控制器
 */
+(void)createNavigationItemWithTitles:(NSDictionary *)titles andWithTarget:(id)target andWithAction:(SEL )action inController:(UIViewController *)controller;
@end

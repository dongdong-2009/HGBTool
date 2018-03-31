//
//  HGBTabBarBadgeTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HGBTabBarBadgeTool : NSObject
/**
  单例
*/
+(instancetype)shareInstance;
#pragma mark tableBar标记点
/**
 tabBar添加标记点

 @param controller controller
 */
-(void)addPointInController:(UIViewController *)controller;
/**
 设置tabBar提示点颜色

 @param pointColor 角标颜色
 @param controller controller
 */
-(void)setTabBarPointColor:(UIColor *)pointColor inController:(UIViewController *)controller;
/**
 tabBar标记点隐藏

 @param controller controller
 */
-(void)hideTabBarPointInController:(UIViewController *)controller;
#pragma mark tableBar角标
/**
 获取tabBar角标

 @param controller controller
 @return tabBar角标
 */

-(NSString *)getTabBarBadgeInController:(UIViewController *)controller;
/**
 设置tabBar角标

 @param badge 角标
 @param controller controller
 */
-(void)setTabBarBadge:(NSString *)badge inController:(UIViewController *)controller;
/**
 tabBar角标+1

 @param controller controller
 */
-(void)addTabBarBadgeInController:(UIViewController *)controller;
/**
 tabBar角标-1

 @param controller controller
 */
-(void)reduceTabBarBadgeInController:(UIViewController *)controller;

/**
 tabBar角标增加

 @param number 增加的数目
 @param controller controller
 */
-(void)addTabBarBadgeWithNumber:(NSInteger)number InController:(UIViewController *)controller;
/**
 tabBar角标隐藏

 @param controller controller
 */
-(void)hideTabBarBadgeInController:(UIViewController *)controller;
/**
 设置tabBar角标颜色

 @param badgeColor 角标颜色
 @param controller controller
 */
-(void)setTabBarBadgeColor:(UIColor *)badgeColor inController:(UIViewController *)controller;
/**
 设置tabBar角标文字颜色

 @param badgeTextColor 角标文字颜色
 @param controller controller
 */
-(void)setTabBarBadgeTextColor:(UIColor *)badgeTextColor inController:(UIViewController *)controller;
@end

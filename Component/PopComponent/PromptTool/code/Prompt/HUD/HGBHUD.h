//
//  HGBHUD.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/5.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 吐司提示
 */
@interface HGBHUD : NSObject
/**
 提示字符串
 */
@property(strong,nonatomic)NSString *title;
/**
 显示时间
 */
@property(assign,nonatomic)NSInteger duration;
#pragma mark 单例
/**
 单例

@return 实体
 */
+(instancetype)shareInstance;
#pragma mark 保存

/**
 *  保存
 *
 *  @param view 显示界面
*/
-(void)showHUDSaveToView:(UIView *)view;
/**
*  隐藏保存
*/
-(void)hideSave;//隐藏保存

#pragma mark 结果
/**
* //显示结果
*
*  @param view 显示界面
*/
-(void)showHUDResult:(NSString *)result ToView:(UIView *)view;

/**
* 显示结果-无遮挡
*
*  @param view 显示界面
*/
-(void)showHUDResult:(NSString *)result WithoutBackToView:(UIView *)view;
@end

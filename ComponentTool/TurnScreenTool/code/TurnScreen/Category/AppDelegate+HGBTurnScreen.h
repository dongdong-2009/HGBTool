//
//  AppDelegate+HGBTurnScreen.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/27.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "AppDelegate.h"

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

/**
 结果

 @param orientation 屏幕方向
 @param returnMessage 信息
 */
typedef void (^HGBTurnScreenReslutBlock)(UIDeviceOrientation orientation,NSDictionary *returnMessage);

@interface AppDelegate (HGBTurnScreen)
/**
 设置屏幕方向允许

 @param allowOrientation 允许的屏幕方向
 */
-(void)setAllowOrientation:(UIInterfaceOrientationMask )allowOrientation;
/**
 旋转屏幕

 @param interfaceOrientation 屏幕方向
 */
- (void)turnOrientation:(UIInterfaceOrientation)interfaceOrientation;
/**
 监听屏幕方向

 @param reslut 结果
 */
-(void)monitorOrientationWithReslut:(HGBTurnScreenReslutBlock)reslut;
@end

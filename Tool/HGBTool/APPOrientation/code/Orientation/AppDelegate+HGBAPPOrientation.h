//
//  AppDelegate+HGBAPPOrientation.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/18.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
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
typedef void (^HGBOrientationReslutBlock)(UIDeviceOrientation orientation,NSDictionary *returnMessage);

@interface AppDelegate (HGBAPPOrientation)
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
-(void)monitorOrientationWithReslut:(HGBOrientationReslutBlock)reslut;
@end

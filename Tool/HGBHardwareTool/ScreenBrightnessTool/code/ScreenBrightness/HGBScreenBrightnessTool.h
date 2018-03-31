//
//  HGBScreenBrightnessTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/29.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HGBScreenBrightnessTool : NSObject
/**
 获取屏幕亮度

 @return 屏幕亮度
 */
+(CGFloat)getScreenBrightness;
/**
 设置屏幕亮度

 @param brightness 屏幕亮度
 */
+(void)setScreenBrightness:(CGFloat)brightness;

@end

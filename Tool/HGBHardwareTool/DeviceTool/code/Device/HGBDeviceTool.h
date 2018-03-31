//
//  HGBDeviceTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/25.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface HGBDeviceTool : NSObject
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
/**
 震动
 */
+(void)vibrate;
/**
 播放系统声音

 @param soundId 声音id
 */
+(void)playSystemSoundWithSoundId:(int)soundId;
@end

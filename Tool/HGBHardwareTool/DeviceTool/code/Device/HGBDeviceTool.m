//
//  HGBDeviceTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/25.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBDeviceTool.h"
#import <AudioToolbox/AudioToolbox.h>


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@implementation HGBDeviceTool
/**
 获取屏幕亮度

 @return 屏幕亮度
 */
+(CGFloat)getScreenBrightness{
    CGFloat currentLight = [[UIScreen mainScreen] brightness];
    return currentLight;
}
/**
 设置屏幕亮度

 @param brightness 屏幕亮度
 */
+(void)setScreenBrightness:(CGFloat)brightness{
    CGFloat brightness2=brightness;
    if(brightness>=1&&brightness<=100){
        brightness2=brightness/100.0;
    }
    [[UIScreen mainScreen] setBrightness: brightness2];

}
/**
 震动
 */
+(void)vibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
/**
 播放系统声音

 @param soundId 声音id
 */
+(void)playSystemSoundWithSoundId:(int)soundId{
    // 系统声音
    AudioServicesPlayAlertSound(soundId);
    // 震动 只有iPhone才能震动而且还得在设置里开启震动才行,其他的如touch就没有震动功能
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

}
@end

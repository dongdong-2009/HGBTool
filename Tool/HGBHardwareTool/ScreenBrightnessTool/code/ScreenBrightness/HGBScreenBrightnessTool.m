//
//  HGBScreenBrightnessTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/29.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBScreenBrightnessTool.h"

@implementation HGBScreenBrightnessTool
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
@end

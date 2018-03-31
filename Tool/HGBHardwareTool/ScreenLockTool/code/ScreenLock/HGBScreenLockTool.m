//
//  HGBScreenLockTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/18.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBScreenLockTool.h"
#import <UIKit/UIKit.h>

@implementation HGBScreenLockTool
/**
 开启自动锁屏
 */
+(void)openAutoScreenLock{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

/**
 关闭自动锁屏
 */
+(void)closeAutoScreenLock{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
@end

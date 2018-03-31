//
//  AppDelegate+HGBException.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate+HGBException.h"
#import "HGBExceptionTool.h"
@implementation AppDelegate (HGBException)
/**
 错误捕捉初始化

 @param launchOptions 加载参数
 */
-(void)init_Exception_ServerWithOptions:(NSDictionary *)launchOptions{
    [HGBExceptionTool setExceptionMonitor];
}

@end

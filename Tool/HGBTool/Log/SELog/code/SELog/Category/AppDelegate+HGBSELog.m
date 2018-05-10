
//
//  AppDelegate+HGBSELog.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/5/10.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate+HGBSELog.h"
#import "HGBSELogTool.h"
@implementation AppDelegate (HGBSELog)
/**
 日志重定向

 @param launchOptions 加载参数
 */
-(void)init_SELog_ServerWithOptions:(NSDictionary *)launchOptions{
    [HGBSELogTool shareInstance].logBlock = ^(NSString *log) {
        NSLog(@"%@",log);
    };
}
@end

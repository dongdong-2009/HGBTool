//
//  AppDelegate+HGBSEDataBase.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/9/20.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "AppDelegate+HGBSEDataBase.h"
#import <objc/runtime.h>
#import "HGBSEDataBaseTool.h"

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation AppDelegate (HGBSEDataBase)
#pragma mark init
/**
 数据库初始化

 @param launchOptions 加载参数
 */
-(void)init_SEDataBase_ServerWithOptions:(NSDictionary *)launchOptions{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(application_SEDataBase_didLaunchHandle:) name:UIApplicationDidFinishLaunchingNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(application_SEDataBase_willTerminateHandle:) name:UIApplicationWillTerminateNotification object:nil];
}
#pragma mark life
-(void)application_SEDataBase_didLaunchHandle:(NSNotification *)notification{
    [HGBSEDataBaseTool shareInstance];
}
-(void)application_SEDataBase_willTerminateHandle:(NSNotification *)notification{
    [[HGBSEDataBaseTool shareInstance] closeDataBase];
}

@end

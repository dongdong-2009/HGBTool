//
//  AppDelegate+HGBAppCheck.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate+HGBAppCheck.h"
#import "HGBAppCheckTool.h"

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation AppDelegate (HGBAppCheck)
/**
 app自检初始化

 @param launchOptions 加载参数
 */
-(void)init_AppCheck_ServerWithOptions:(NSDictionary *)launchOptions{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(application_DataBase_didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)application_DataBase_didBecomeActive:(NSNotification *)_n{
    HGBLog(@"%@",[HGBAppCheckTool getAppCodeSignatureData]);
    [HGBAppCheckTool appCheck];
}
@end

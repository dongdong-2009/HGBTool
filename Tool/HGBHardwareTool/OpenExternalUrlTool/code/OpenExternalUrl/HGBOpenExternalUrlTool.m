//
//  HGBOpenExternalUrlTool.m
//  VirtualCard
//
//  Created by huangguangbao on 2017/6/26.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBOpenExternalUrlTool.h"
#import <UIKit/UIKit.h>



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBOpenExternalUrlTool
static HGBOpenExternalUrlTool*instance=nil;
#pragma mark 初始化
+(instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBOpenExternalUrlTool alloc]init];
    }
    return instance;
}
#pragma mark 基础
/**
 打开浏览器
 
 @param urlString url字符串
 @return 结果
 */
+(BOOL)openBrowserWithUrlString:(NSString *)urlString{
    if(urlString==nil){
        HGBLog(@"url不能为空");
        return NO;
    }
    NSURL *url=[NSURL URLWithString:urlString];
    if([[UIApplication sharedApplication]canOpenURL:url]){
#ifdef __IPHONE_10_0
         static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif

    }else{
        HGBLog(@"url无法打开");
        return NO;
    }
}
/**
 打电话
 
 @param phoneNumber 电话号码
 @return 结果
 */
+(BOOL)openToCallPhoneWithPhoneNumber:(NSString *)phoneNumber{

    if(phoneNumber==nil){
        HGBLog(@"phoneNumber不能为空");
        return NO;
    }
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[HGBOpenExternalUrlTool deleteSpace:phoneNumber]]];
    if([[UIApplication sharedApplication]canOpenURL:url]){
        ;
#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        HGBLog(@"无法拨打电话");
        return NO;
    }
}
/**
 打开外部链接
 
 @param urlString url
 @return 结果
 */
+(BOOL)openAppWithUrlString:(NSString *)urlString{
    if(urlString==nil){
        HGBLog(@"urlString不能为空");
        return NO;
    }
    NSURL *url=[NSURL URLWithString:urlString];
    if([[UIApplication sharedApplication]canOpenURL:url]){
#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        HGBLog(@"链接无法打开");
        return NO;
    }
}

/**
 打开设置界面
 
 @return 结果
 */
+(BOOL)openAppSetView{

    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {

#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        HGBLog(@"设置界面无法打开");
        return NO;
    }
}
#pragma mark 打开各种设置界面
/**
 打开各种设置界面
 
 @param seturl 类型
 @return 结果
 */
+(BOOL)openAppSetViewWithType:(HGBSetURL)seturl{
    NSArray *urlArray=@[@"root=General&path=About",
                     @"root=General&path=ACCESSIBILITY",
                     @"root=AIRPLANE_MODE",
                     @"root=General&path=AUTOLOCK",
                     @"root=Brightness",
                     @"root=General&path=Bluetooth",
                     @"root=General&path=DATE_AND_TIME",
                     @"root=FACETIME",
                     @"root=General",
                     @"root=General&path=Keyboard",
                     @"root=CASTLE iCloud",
                     @"root=CASTLE&path=STORAGE_AND_BACKUP",
                     @"root=General&path=INTERNATIONAL",
                     @"root=LOCATION_SERVICES",
                     @"root=MUSIC",
                     @"MUSIC&path=EQ",
                     @"root=MUSIC&path=VolumeLimit",
                     @"root=General&path=Network",
                     @"root=NIKE_PLUS_IPOD",
                     @"root=NOTES",
                     @"root=NOTIFICATIONS_ID",
                     @"root=Phone",
                     @"root=Photos",
                     @"root=General&path=ManagedConfigurationList",
                     @"root=General&path=Reset",
                     @"root=Safari",
                     @"root=General&path=Assistant",
                     @"root=Sounds",
                     @"root=General&path=SOFTWARE_UPDATE_LINK",
                     @"root=STORE",
                     @"root=TWITTER",
                     @"root=General&path=USAGE",
                     @"root=General&path=Network/VPN",
                     @"root=Wallpaper",
                     @"root=WIFI",
                     @"root=INTERNET_TETHERING"];
    
    NSString *urlStr=urlArray[seturl];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"App-Prefs:%@",urlStr]];
    if([[UIApplication sharedApplication] canOpenURL:url]) {

#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        HGBLog(@"设置界面无法打开");
        return NO;
    }
}
#pragma mark 删除空格
+(NSString *)deleteSpace:(NSString *)string
{
    NSString *str=string;
    while ([str containsString:@" "]){
        str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return str;
}

@end

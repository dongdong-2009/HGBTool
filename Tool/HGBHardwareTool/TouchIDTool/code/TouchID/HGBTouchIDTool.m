//
//  HGBTouchIDTool.m
//  指纹锁
//
//  Created by huangguangbao on 2017/6/23.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBTouchIDTool.h"
#import <sys/utsname.h>

#ifndef SYSTEM_VERSION
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]//系统版本号
#endif

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"
#define ReslutError @"ResultError"

@interface HGBTouchIDTool ()
@end

@implementation HGBTouchIDTool


/**
 指纹解锁

 @param message 提示文本
 @param cancelTitle 取消按钮显示内容(此参数只有iOS10以上才能生效),默认显示：取消
 @param otherTitle 密码登录按钮显示内容(默认*密码登录*),如果传入空字符串@""/nil,则只会显示独立的取消按钮
 @param enabled 默认为NO点击密码使用系统解锁/YES时，自己操作点击密码登录
 @param resultBlock 返回结果
 */
+ (void)touchIDWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle enabled:(BOOL)enabled andWithOperatingrResultBlock:(void(^)( HGBOperatingTouchIDResult result,NSDictionary *messageInfo))resultBlock{
    
    [HGBTouchIDTool validationTouchIDIsSupportWithBlock:^(BOOL isSupport, LAContext *context, NSInteger policy, NSDictionary *messageInfo) {
        context.localizedFallbackTitle = !otherTitle?@"":otherTitle;
        if(SYSTEM_VERSION>=10) context.localizedCancelTitle = cancelTitle;
        NSInteger policy2 = enabled?LAPolicyDeviceOwnerAuthenticationWithBiometrics:LAPolicyDeviceOwnerAuthentication;
       __block HGBOperatingTouchIDResult type;
       __block NSString *prompt;
        if (isSupport) {
            [context evaluatePolicy:policy2 localizedReason:message reply:^(BOOL success, NSError * _Nullable error) {

                if (success) {
                    type=HGBTouchIDResultTypeSucess;
                    prompt=@"验证成功";
                }else if (error) {
                    switch (error.code) {
                        case LAErrorAuthenticationFailed:{
                            type=HGBTouchIDResultTypeFailed;
                            prompt=@"TouchID 验证失败";
                            HGBLog(@"TouchID 验证失败");
                            break;}
                        case LAErrorUserCancel:{
                            type=HGBTouchIDResultTypeUserCancel;
                            prompt=@"TouchID 被用户取消";
                            HGBLog(@"TouchID 被用户取消");
                            break;
                        }

                        case LAErrorSystemCancel:{
                            type=HGBTouchIDResultTypeSystemCancel;
                            prompt=@"TouchID 被系统取消";
                             HGBLog(@"TouchID 被系统取消");
                            break;
                        }

                        case LAErrorAppCancel:{
                            type=HGBTouchIDResultTypeAppCancel;
                            prompt=@"当前软件被挂起并取消了授权(如App进入了后台等)";
                             HGBLog(@"当前软件被挂起并取消了授权(如App进入了后台等)");
                            if (enabled)[context evaluatePolicy:policy localizedReason:message reply:^(BOOL success, NSError * _Nullable error) {
                            }];
                            break;
                        }

                        case LAErrorInvalidContext:{
                            type=HGBTouchIDResultTypeAppCancel;
                            prompt=@"当前软件被挂起并取消了授权(LAContext对象无效)";
                             HGBLog(@"当前软件被挂起并取消了授权(LAContext对象无效)");
                            if (enabled)[context evaluatePolicy:policy localizedReason:message reply:^(BOOL success, NSError * _Nullable error) {
                            }];
                            break;
                        }

                        case LAErrorUserFallback:{
                            type=HGBTouchIDResultTypeInputPassword;
                            prompt=@"手动输入密码";
                            HGBLog(@"手动输入密码");
                              break;

                        }

                        case LAErrorPasscodeNotSet:{
                            type=HGBTouchIDResultTypeInputPassword;
                            prompt=@"TouchID 无法启动,因为用户没有设置密码";
                             HGBLog(@"TouchID 无法启动,因为用户没有设置密码");
                            break;
                        }

                        case LAErrorTouchIDNotEnrolled:{
                            type=HGBTouchIDResultTypeNotSet;
                            prompt=@"TouchID 无法启动,因为用户没有设置TouchID";
                            HGBLog(@"TouchID 无法启动,因为用户没有设置TouchID");
                            break;
                        }


                        case LAErrorTouchIDNotAvailable:{
                            type=HGBTouchIDResultTypeNotAvailable;
                            prompt=@"TouchID 无效";
                             HGBLog(@"TouchID 无效");
                            break;
                        }

                        case LAErrorTouchIDLockout:{
                            type=HGBTouchIDResultTypeLockout;
                            prompt=@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码";
                            HGBLog(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码");
                            if (enabled)[context evaluatePolicy:policy localizedReason:message reply:^(BOOL success, NSError * _Nullable error) {}];
                            break;
                        }

                        default:{
                            type=HGBTouchIDResultTyoeUnknown;
                            prompt=@"未知情况";
                             HGBLog(@"未知情况");
                            if (enabled)[context evaluatePolicy:policy localizedReason:message reply:^(BOOL success, NSError * _Nullable error) {}];
                            break;
                        }

                    }
                }
                if(resultBlock){
                    if(prompt){
                        resultBlock(type,@{ReslutCode:@(type).stringValue,ReslutMessage:prompt});
                    }else{
                         resultBlock(type,@{ReslutCode:@(type).stringValue});

                    }
                }
            }];
        }else {
            NSError *error=messageInfo[ReslutError];
            
            if(error.code==-8||[error.localizedDescription isEqualToString:@"Biometry is locked out"]){
                type=HGBTouchIDResultTypeLockout;
                prompt=@"该设备TouchID已被系统锁定,请到设置界面TouchID与密码解锁";
               HGBLog(@"该设备TouchID已被系统锁定,请到设置界面TouchID与密码解锁");
                resultBlock(HGBTouchIDResultTypeLockout,@{ReslutCode:@(HGBTouchIDResultTypeLockout).stringValue,ReslutMessage:@"该设备TouchID已被系统锁定,请到设置界面TouchID与密码解锁"});
        }else{
            type=HGBTouchIDResultTypeVersionNotSupport;
            prompt=[NSString stringWithFormat:@"此设备不支持TouchID:\n设备操作系统:%@\n设备系统版本号:%@\n设备型号:%@", [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] systemName], [HGBTouchIDTool getDeviceModelName]];
             HGBLog(@"%@",[NSString stringWithFormat:@"此设备不支持TouchID:\n设备操作系统:%@\n设备系统版本号:%@\n设备型号:%@", [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] systemName], [HGBTouchIDTool getDeviceModelName]]);
        }
            if(resultBlock){
                if(prompt){
                    resultBlock(type,@{ReslutCode:@(type).stringValue,ReslutMessage:prompt});
                }else{
                    resultBlock(type,@{ReslutCode:@(type).stringValue});

                }
            }
        }


        
   }];
    
}

/**
 验证设备是否支持指纹解锁

 @param block block
 @return 返回结果
 */
+ (BOOL)validationTouchIDIsSupportWithBlock:(void(^)(BOOL isSupport,LAContext *context, NSInteger policy, NSDictionary *messageInfo))block{
    LAContext* context = [[LAContext alloc] init];
#ifdef __IPHONE_9_0
#else
    context.maxBiometryFailures = @(3);//最大的错误次数,9.0后失效
#endif
    NSInteger policy = SYSTEM_VERSION<9.0&&SYSTEM_VERSION>=8.0?LAPolicyDeviceOwnerAuthenticationWithBiometrics:LAPolicyDeviceOwnerAuthentication;
    NSError *error = nil;
    BOOL isSupport = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];//实测中发现如果使用LAPolicyDeviceOwnerAuthentication,则每次返回的结果都是true,使用LAPolicyDeviceOwnerAuthenticationWithBiometrics则可以返回真实的结果
    NSString *promptstr;
     if(error.code==-8||[error.localizedDescription isEqualToString:@"Biometry is locked out"]){
         promptstr=@"该设备TouchID已被系统锁定,请到设置界面TouchID与密码解锁";
     }else{
          promptstr=@"此设备不支持TouchID";
     }
    HGBLog(@"%@",promptstr);
    if(promptstr&&error){
        block(isSupport, context, policy,@{ReslutMessage:promptstr});
    }else if(promptstr){
        block(isSupport, context, policy,@{ReslutMessage:promptstr});
    }else{
        block(isSupport, context, policy,@{});
    }
    return isSupport;
}

#pragma mark ---获取设备型号
+ (NSString *)getDeviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone 系列
    if ([deviceModel isEqualToString:@"iPhone1,1"])    return @"iPhone1G";
    if ([deviceModel isEqualToString:@"iPhone1,2"])    return @"iPhone3G";
    if ([deviceModel isEqualToString:@"iPhone2,1"])    return @"iPhone3GS";
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"VerizoniPhone4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone5";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone5C";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone5C";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone5S";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone5S";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone6Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone6sPlus";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone7(CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone7(GSM)";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone7Plus(CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone7Plus(GSM)";
    
    //iPod 系列
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPodTouch1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPodTouch2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPodTouch3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPodTouch4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPodTouch5G";
    
    //iPad 系列
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad2(WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad2(GSM)";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad2(CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad2(32nm)";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPadMini(WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPadMini(GSM)";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPadMini(CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad3(WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad3(CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad3(4G)";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad4 WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad4(4G)";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad4(CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPadAir";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPadAir";
    if ([deviceModel isEqualToString:@"iPad4,3"])      return @"iPadAir";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPadAir2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPadAir2";
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    if ([deviceModel isEqualToString:@"iPad4,4"]
        ||[deviceModel isEqualToString:@"iPad4,5"]
        ||[deviceModel isEqualToString:@"iPad4,6"])      return @"iPadMini2";
    if ([deviceModel isEqualToString:@"iPad4,7"]
        ||[deviceModel isEqualToString:@"iPad4,8"]
        ||[deviceModel isEqualToString:@"iPad4,9"])      return @"iPadMini3";
    return deviceModel;
}
@end

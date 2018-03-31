//
//  AppDelegate+HGBAPPOrientation.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/18.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate+HGBAPPOrientation.h"





#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface AppDelegate()

/**
 * 是否允许转向
 */
@property(nonatomic,assign)UIInterfaceOrientationMask allowOrientation;


@end

@implementation AppDelegate (HGBAPPOrientation)
static UIInterfaceOrientationMask appAllowOrientation=UIInterfaceOrientationMaskPortrait;
static HGBOrientationReslutBlock appOrientationReslut=nil;
/**
 旋转屏幕

 @param interfaceOrientation 屏幕方向
 */
- (void)turnOrientation:(UIInterfaceOrientation)interfaceOrientation;
{

    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

    NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];

    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

}
/**
 监听屏幕方向

 @param reslut 结果
 */
-(void)monitorOrientationWithReslut:(HGBOrientationReslutBlock)reslut{
    appOrientationReslut=reslut;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)orientationChange:(NSNotification *)_n{
    UIDeviceOrientation orientation;
    NSString *message=@"";
    HGBLog(@"收到了屏幕旋转的通知");
    //判断屏幕当前方向
    //获取当前的设备(手机,ipad)
    UIDevice  *device=[UIDevice currentDevice];
    //device.orientation
    orientation=device.orientation;
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            message=@"UIDeviceOrientationPortrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            message=@"UIDeviceOrientationPortraitUpsideDown";
            break;
        case UIDeviceOrientationLandscapeLeft:
            message=@"UIDeviceOrientationLandscapeLeft";
            break;
        case UIDeviceOrientationLandscapeRight:
            message=@"UIDeviceOrientationLandscapeRight";
            break;
        case UIDeviceOrientationFaceUp:
            message=@"UIDeviceOrientationFaceUp";
            break;
        case UIDeviceOrientationFaceDown:
            message=@"UIDeviceOrientationFaceDown";
            break;
        default:
            message=@"UIDeviceOrientationUnknown";
        break;
    }
    if(appOrientationReslut){
        appOrientationReslut(orientation,@{@"orientation":@(orientation),@"description":message});
    }
}
/**
 设置屏幕方向允许

 @param allowOrientation 允许的屏幕方向
 */
-(void)setAllowOrientation:(UIInterfaceOrientationMask )allowOrientation{
    appAllowOrientation=allowOrientation;

}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window

{

    return appAllowOrientation;

}

@end

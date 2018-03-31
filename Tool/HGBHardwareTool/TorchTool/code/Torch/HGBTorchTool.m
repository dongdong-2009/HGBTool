//
//  HGBTorchTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/28.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBTorchTool.h"
#import <AVFoundation/AVFoundation.h>


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@implementation HGBTorchTool
 static  AVCaptureDevice *device;
#pragma mark 手电筒
/**
 打开手电筒
 */
+(BOOL)startOnTorch{
    if (TARGET_IPHONE_SIMULATOR) {
         HGBLog(@"无手电筒功能－相机闪光灯!");
        return NO;
    }

    //获取摄像头设备
    //AVMediaTypeVideo 视频设备
    if(device==nil){
         device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    if([device hasTorch]){

        //加锁
        [device lockForConfiguration:nil];
        //开
        [device setTorchMode:AVCaptureTorchModeOn];
        //解锁
        [device unlockForConfiguration];

        return YES;
    }else{
        HGBLog(@"设备不支持");
        return NO;

    }
}
/**
 关闭手电筒
 */
+(BOOL)startOffTorch{
    if (TARGET_IPHONE_SIMULATOR) {
        HGBLog(@"无手电筒功能－相机闪光灯!");
        return NO;
    }
    if(device==nil){
        device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    if([device hasTorch]){

        [device lockForConfiguration:nil];
        //关
        [device setTorchMode:AVCaptureTorchModeOff];
        //解锁
        [device unlockForConfiguration];
        device=nil;
        return YES;
    }else{
        HGBLog(@"设备不支持");
        return NO;

    }

}
@end

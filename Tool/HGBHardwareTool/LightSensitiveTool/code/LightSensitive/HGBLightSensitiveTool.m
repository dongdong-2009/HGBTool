
//
//  HGBLightSensitiveTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/15.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBLightSensitiveTool.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@interface HGBLightSensitiveTool()<AVCaptureVideoDataOutputSampleBufferDelegate>

/**
 相机
 */
@property(strong,nonatomic) AVCaptureSession * session;


/**
 时间
 */
@property(strong,nonatomic) NSTimer * timer;
/**
 数据更新
 */
@property(assign,nonatomic)BOOL sendFlag;
@end

@implementation HGBLightSensitiveTool
static HGBLightSensitiveTool *instance=nil;
+ (instancetype)shareInstanceWithDelegate:(id<HGBLightSensitiveToolDelegate>)delegate
{
    if (instance==nil) {
        instance=[[HGBLightSensitiveTool alloc]init];
        instance.delegate=delegate;
    }
    return instance;
}
+(instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBLightSensitiveTool alloc]init];
    }
    return instance;
}

#pragma mark set

/**
 开始监测光照强度
 @param isRepeat 是否重复
 */
-(void)startMonitLightSensitiveWithRepeat:(BOOL)isRepeat{
    self.isRepeat=isRepeat;
    if(self.session){
        HGBLog(@"已打开,请先关闭后再操作");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(lightSensitive:didFailedWithError:)]){
            [self.delegate lightSensitive:self didFailedWithError:@{ReslutCode:@(HGBLightSensitiveToolErrorTypeOther).stringValue,ReslutMessage:@"已打开,请先关闭后再操作"}];
        }
        return ;
    }

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(lightSensitive:didFailedWithError:)]){
            [self.delegate lightSensitive:self didFailedWithError:@{ReslutCode:@(HGBLightSensitiveToolErrorTypeDevice).stringValue,ReslutMessage:@"设备不支持或无权限"}];
        }
        [self jumpToSet];
        return;
    }else{

        if(![self isCanUseCamera]){
            HGBLog(@"设备不支持或无权限");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(lightSensitive:didFailedWithError:)]){
                [self.delegate lightSensitive:self didFailedWithError:@{ReslutCode:@(HGBLightSensitiveToolErrorTypeDevice).stringValue,ReslutMessage:@"设备不支持或无权限"}];
            }
            [self jumpToSet];
            return ;

        }
    }


    // 1.获取硬件设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device == nil) {
        HGBLog(@"设备不支持或无权限");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(lightSensitive:didFailedWithError:)]){
            [self.delegate lightSensitive:self didFailedWithError:@{ReslutCode:@(HGBLightSensitiveToolErrorTypeDevice).stringValue,ReslutMessage:@"设备不支持或无权限"}];
        }
        [self jumpToSet];
        return;
    }


    // 2.创建输入流
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];

    // 3.创建设备输出流
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    // AVCaptureSession属性
    self.session = [[AVCaptureSession alloc]init];
    // 设置为高质量采集率
    [self.session  setSessionPreset:AVCaptureSessionPresetHigh];
    // 添加会话输入和输出
    if ([self.session  canAddInput:input]) {
        [self.session  addInput:input];
    }
    if ([self.session  canAddOutput:output]) {
        [self.session  addOutput:output];
    }
    self.sendFlag=YES;
    self.timer= [NSTimer scheduledTimerWithTimeInterval:self.timeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.sendFlag=YES;
    }];

    // 9.启动会话
    [self.session  startRunning];
}
/**
 关闭光强传感器

 @return 结果
 */
-(BOOL)stopMonitLightSensitive{
    if(self.session){
         [self.session stopRunning];
        instance=nil;
        if(self.timer){
            [self.timer invalidate];
        }
        return YES;
    }else{
        return NO;
    }

}
#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {


    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];

    




    if(!self.isRepeat){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(lightSensitive:didUpdatedWithBrightness:)]){
            [self.delegate lightSensitive:self didUpdatedWithBrightness:brightnessValue];
        }
         [_session stopRunning];
         instance=nil;
    }else{
        if(self.timeInterval==0){
            if(self.delegate&&[self.delegate respondsToSelector:@selector(lightSensitive:didUpdatedWithBrightness:)]){
                [self.delegate lightSensitive:self didUpdatedWithBrightness:brightnessValue];
            }
        }else{
            if(self.sendFlag){
                 self.sendFlag=NO;
                if(self.delegate&&[self.delegate respondsToSelector:@selector(lightSensitive:didUpdatedWithBrightness:)]){
                    [self.delegate lightSensitive:self didUpdatedWithBrightness:brightnessValue];
                }

            }
        }

    }


}

#pragma mark --set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"相机访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"去设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if([[UIApplication sharedApplication] canOpenURL:url]) {

            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];

        }

    }];
    [alert addAction:action2];
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}
/**
 相机权限判断

 @return 是否有权限
 */
- (BOOL)isCanUseCamera {
    if (TARGET_IPHONE_SIMULATOR) {
        return NO;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        HGBLog(@"%@",granted ? @"相机准许":@"相机不准许");
    }];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return NO;
    }

    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}
#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
- (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}
/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
- (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
@end

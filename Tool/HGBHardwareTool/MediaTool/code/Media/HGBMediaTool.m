//
//  HGBMediaTool.m
//  测试
//
//  Created by huangguangbao on 2017/8/8.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBMediaTool.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HGBMediaImageLookTool.h"
#import "HGBMediaFileQuickLookTool.h"




/**
 多媒体类型
 */
typedef enum HGBMediaType
{
    HGBMediaTypeTorchOn,//手电筒打开
    HGBMediaTypeTorchOff,//手电筒关闭
    HGBMediaTypeCamera,//拍照
    HGBMediaTypePhotoLibrary,//相册
    HGBMediaTypeVideo,//录像
    HGBMediaTypeAudio//录音

}HGBMediaType;


/**
 权限类型
 */
typedef enum HGBAuthorityType
{
    HGBAuthorityTypeCamera,//拍照
    HGBAuthorityTypePhotoLibrary,//相册
    HGBAuthorityTypeVideo,//录像
    HGBAuthorityTypeAudio//录音

}HGBAuthorityType;

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@interface HGBMediaTool()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,HGBMediaImageLookToolDelegate,HGBMediaFileQuickLookToolDelegate>
/**
 父控制器
 */
@property (strong,nonatomic)UIViewController *parent;
/**
 代理
 */
@property (assign,nonatomic)id<HGBMediaToolDelegate>delegate;
/**
 媒体类型
 */
@property(assign,nonatomic)HGBMediaType mediaType;
/**
 设备
 */
@property (strong,nonatomic)AVCaptureDevice *device;
/**
 媒体:拍照-相册-录像支持
 */
@property(strong,nonatomic)UIImagePickerController *picker;

/**
 录音器:录音
 */
@property (strong, nonatomic)AVAudioRecorder *recorder;
/**
 录音路径
 */
@property (strong, nonatomic)NSString *recorderPath;
@end


@implementation HGBMediaTool
static HGBMediaTool *instance=nil;

#pragma mark init
/**
 单例

 @return 实例
 */
+(instancetype)instanceWithParent:(UIViewController *)parent andWithDelegate:(id<HGBMediaToolDelegate>)delegate
{
    if (instance==nil) {
        instance=[[HGBMediaTool alloc]init];
    }
    instance.delegate=delegate;
    instance.parent=parent;
    return instance;
}
#pragma mark 媒体调用
/**
 启动媒体

 @param mediaType 媒体类型
 */
-(void)startMediaWithMediaType:(HGBMediaType)mediaType{
    if(mediaType==HGBMediaTypeTorchOn){
        [self startOnTorch];
    }else if (mediaType==HGBMediaTypeTorchOff){
        [self startOffTorch];
    }else if (mediaType==HGBMediaTypeCamera){
        [self startCamera];
    }else if (mediaType==HGBMediaTypePhotoLibrary){
        [self startPhotoAlbum];
    }else if (mediaType==HGBMediaTypeVideo){
        [self startVideo];
    }
}

#pragma mark 手电筒
/**
 打开手电筒
 */
-(BOOL)startOnTorch{
    if (TARGET_IPHONE_SIMULATOR) {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeDevice).stringValue,ReslutMessage:@"无手电筒功能－相机闪光灯!"}];
        }
        [self alertWithPrompt:@"无手电筒功能－相机闪光灯!"];
        return NO;
    }
    //获取摄像头设备
    //AVMediaTypeVideo 视频设备
    instance.device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([instance.device hasTorch]){

        //加锁
        [self.device lockForConfiguration:nil];
        //开
        [self.device setTorchMode:AVCaptureTorchModeOn];
        //解锁
        [self.device unlockForConfiguration];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
            [self.delegate mediaToolDidSucessed:self];
        }
        return YES;
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeDevice).stringValue,ReslutMessage:@"无手电筒功能－相机闪光灯!"}];
        }
         [self alertWithPrompt:@"无手电筒功能－相机闪光灯!"];
        return NO;

    }

}
/**
 关闭手电筒
 */
-(BOOL)startOffTorch{
    if (TARGET_IPHONE_SIMULATOR) {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeDevice).stringValue,ReslutMessage:@"无手电筒功能－相机闪光灯!"}];
        }
        [self alertWithPrompt:@"无手电筒功能－相机闪光灯!"];
        return NO;
    }
    if([instance.device hasTorch]){

        //加锁
        [self.device lockForConfiguration:nil];
        //关
        [self.device setTorchMode:AVCaptureTorchModeOff];
        //解锁
        [self.device unlockForConfiguration];
        self.device=nil;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
            [self.delegate mediaToolDidSucessed:self];
        }
        return YES;
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeDevice).stringValue,ReslutMessage:@"无手电筒功能－相机闪光灯!"}];
        }
        [self alertWithPrompt:@"无手电筒功能－相机闪光灯!"];
        return NO;

    }


}
#pragma mark 调用相机
/**
 调用相机
 */
-(BOOL)startCamera{
    if([self.picker.view superview]){
        [self.picker dismissViewControllerAnimated:YES completion:nil];
    }
    self.mediaType=HGBMediaTypeCamera;

    if (![self isCanUseCamera])
    {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"相机权限受限!"}];
        }
        NSString *errorStr = @"应用相机权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;
    }
    self.picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    self.picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
    //设置捕获模式
    self.picker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
    self.picker.delegate=self;
    if(self.withoutEdit){
        self.picker.allowsEditing=NO;
    }else{
        self.picker.allowsEditing=YES;
    }
    [self.parent presentViewController:self.picker animated:YES completion:nil];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
        [self.delegate mediaToolDidSucessed:self];
    }
    return YES;

}
#pragma mark 调用相册
/**
 调用相册
 */
-(BOOL)startPhotoAlbum{
    if([self.picker.view superview]){
        [self.picker dismissViewControllerAnimated:YES completion:nil];
    }
    self.mediaType=HGBMediaTypePhotoLibrary;

    if (![self isCanUsePhotos])
    {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"应用相册权限受限!"}];
        }
        NSString *errorStr = @"应用相册权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;
    }
    self.picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.delegate=self;
    if(self.withoutEdit){
        self.picker.allowsEditing=NO;
    }else{
        self.picker.allowsEditing=YES;
    }
    [self.parent presentViewController:self.picker animated:YES completion:nil];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
        [self.delegate mediaToolDidSucessed:self];
    }
    return YES;

}
#pragma mark 调用录像
/**
 调用录像
 */
-(BOOL)startVideo{
    if([self.picker.view superview]){
        [self.picker dismissViewControllerAnimated:YES completion:nil];
    }
    self.mediaType=HGBMediaTypeVideo;
    if (![self isCanUseCamera])
    {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"相机权限受限!"}];
        }
        NSString *errorStr = @"应用相机权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;
    }


    self.picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    self.picker.delegate=self;
    //设置录像媒体类型
    self.picker.mediaTypes=@[(NSString *)kUTTypeMovie];
    //kUTTypeVideo 有视频没声音 movie有视频有声音
    self.picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
    //视频质量
    self.picker.videoQuality=UIImagePickerControllerQualityTypeMedium;
    //设置捕获方式为视频录制
    self.picker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
    if(self.withoutEdit){
        self.picker.editing=NO;
    }else{
        self.picker.editing=YES;
    }
    [self.parent presentViewController:self.picker animated:YES completion:nil];

    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
        [self.delegate mediaToolDidSucessed:self];
    }
    return YES;
}
#pragma mark 录音
/**
 录音初始化

 @param path 录音文件路径
 @param rate 采样率
 @param numberOfChannels 声道数
 @param depth 采样位数
 @param quality 录音质量
 @return 结果
 */
-(BOOL)initRecordingWithPath:(NSString *)path andWithRate:(CGFloat)rate andWithNumberOfChannels:(NSInteger)numberOfChannels andWithPCMBitDepth:(NSInteger)depth andwithQuality:(AVAudioQuality)quality{
    if(![self isCanUseMicrophone]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"麦克风权限受限!"}];
        }
        NSString *errorStr = @"麦克风权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;

    }
    if(path==nil||path.length==0){
        HGBLog(@"地址不能为空");
        if(instance.delegate&&[instance.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [instance.delegate mediaTool:instance didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeParams).stringValue,ReslutMessage:@"地址不能为空"}];
        }
        return NO;
    }

    NSString *lastPath=lastPath=[HGBMediaTool urlAnalysisToPath:path];;

    NSString *dirPath=[lastPath stringByDeletingLastPathComponent];
    if(![HGBMediaTool isExitAtFilePath:dirPath]){
        [HGBMediaTool createDirectoryPath:dirPath];
    }
    if([HGBMediaTool isExitAtFilePath:lastPath]){
        HGBLog(@"路径已存在");
        if(instance.delegate&&[instance.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [instance.delegate mediaTool:instance didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeExistPath).stringValue,ReslutMessage:@"路径已存在"}];
        }
        return NO;
    }
    if(![self isCanUseMicrophone]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"麦克风权限受限!"}];
        }
        NSString *errorStr = @"麦克风权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;

    }


    self.recorderPath=lastPath;
    //对录音机进行配置
    NSMutableDictionary *setting=[NSMutableDictionary dictionary];
     [setting setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置采样率
    if(rate==0){
        [setting setObject:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    }else{
        [setting setObject:[NSNumber numberWithFloat:rate] forKey:AVSampleRateKey];
    }
    //设置声道数
    if(numberOfChannels==0){
       [setting setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    }else{
        [setting setObject:[NSNumber numberWithInteger:numberOfChannels] forKey:AVNumberOfChannelsKey];
    }

    //设置采样位数
    if(depth==0){
        [setting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    }else{
        [setting setObject:[NSNumber numberWithInteger:depth] forKey:AVLinearPCMBitDepthKey];
    }

    //设置录音质量
    [setting setObject:[NSNumber numberWithInt:quality] forKey:AVEncoderAudioQualityKey];
    //真迹调试需要添加
    AVAudioSession *as=[AVAudioSession sharedInstance];
    [as setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [as setActive:YES error:nil];
    //
    NSError *error;
    self.recorder=[[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:lastPath] settings:setting error:&error];
    if(error)
    {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];

        }

        return NO;
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
            [self.delegate mediaToolDidSucessed:self];
        }
        return YES;
    }
}
/**
 开始录音
 */
-(BOOL)startRecording{
    if(![self isCanUseMicrophone]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"麦克风权限受限!"}];
        }
        NSString *errorStr = @"麦克风权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;

    }
    if(!self.recorder){
        //录音文件路径
        NSString *lastPath=[NSString stringWithFormat:@"caches://media/%@.aac",[HGBMediaTool getSecondTimeStringSince1970]];
        lastPath=[HGBMediaTool urlAnalysisToPath:lastPath];
        NSString *dirPath=[lastPath stringByDeletingLastPathComponent];
        if(![HGBMediaTool isExitAtFilePath:dirPath]){
            [HGBMediaTool createDirectoryPath:dirPath];
        }
        if([HGBMediaTool isExitAtFilePath:lastPath]){
            HGBLog(@"路径已存在");
            if(instance.delegate&&[instance.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
                [instance.delegate mediaTool:instance didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeExistPath).stringValue,ReslutMessage:@"路径已存在"}];
            }
            return NO;
        }
        self.recorderPath=lastPath;
        //对录音机进行配置
        NSMutableDictionary *setting=[NSMutableDictionary dictionary];
         [setting setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
        //设置采样率
        [setting setObject:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        //设置声道数
        [setting setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //设置采样位数
        [setting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        //设置录音质量
        [setting setObject:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        //真迹调试需要添加
        AVAudioSession *as=[AVAudioSession sharedInstance];
        [as setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [as setActive:YES error:nil];
        //
        NSError *error;
        self.recorder=[[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:lastPath] settings:setting error:&error];
        if(error)
        {
            if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
                [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];
            }
            return NO;
        }
    }
    if([self.recorder record]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
            [self.delegate mediaToolDidSucessed:self];
        }
        return YES;
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeError).stringValue,ReslutMessage:@"录音失败!"}];
        }
        return NO;
    }
}
/**
 暂停录音
 */
-(BOOL)parseRecording{
    if(![self isCanUseMicrophone]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"麦克风权限受限!"}];
        }
        NSString *errorStr = @"麦克风权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;

    }
    if(self.recorderPath){
         [self.recorder pause];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
            [self.delegate mediaToolDidSucessed:self];
        }
        return YES;
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeError).stringValue,ReslutMessage:@"录音失败!"}];
        }

        return NO;
    }
}
/**
 结束录音
 */
-(BOOL)stopRecording{
    if(self.recorderPath){

        [self.recorder stop];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
            [self.delegate mediaToolDidSucessed:self];
        }
        NSString *path=[HGBMediaTool urlEncapsulation:self.recorderPath];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didSucessSaveToCachePath:)]){
            [self.delegate mediaTool:self didSucessSaveToCachePath:path];
        }
        self.recorderPath=nil;
        instance=nil;
        return YES;
    }else{
        self.recorderPath=nil;
        instance=nil;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeError).stringValue,ReslutMessage:@"录音失败!"}];
        }
        return NO;
    }
}
/**
 取消录音
 */
-(BOOL)cancelRecording{
    [HGBMediaTool removeFilePath:self.recorderPath];
    self.recorderPath=nil;
    instance=nil;
    return YES;
}
#pragma mark 保存到相册
/**
 保存到相册

 @param object 图片或图片视频路径
 @return 结果
 */
-(BOOL)saveToAlbumWithObject:(id)object{
    if(!([object isKindOfClass:[UIImage class]]||[object isKindOfClass:[NSString class]])){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeError).stringValue,ReslutMessage:@"参数类型错误"}];
        }
        return NO;
    }
    if (![self isCanSavePhotos])
    {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeAuthority).stringValue,ReslutMessage:@"应用相册权限受限!"}];
        }
        NSString *errorStr = @"应用相册权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;
    }
    UIImage *image;

    NSString *path;
    if([object isKindOfClass:[UIImage class]]){
        image=object;
    }else{
        path=object;
        path=[HGBMediaTool urlAnalysisToPath:path];
        image=[UIImage imageWithContentsOfFile:path];
    }
    if(image){
          UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

    }else{
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:  didFinishSavingWithError: contextInfo:),NULL);
    }



    return YES;
}
#pragma mark 播放wav文件
/**
 播放wav文件

 @param src 文件路径
 */
-(void)playWavWithSource:(NSString *)src{
    if(src==nil||src.length==0){
        HGBLog(@"参数不对");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeParams).stringValue,ReslutMessage:@"参数不对"}];
        }
        return;
    }
    if(![[src pathExtension] isEqualToString:@"wav"]){
         HGBLog(@"参数格式错误");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypePathTypeError).stringValue,ReslutMessage:@"文件格式错误"}];
        }
        return;
    }
    src=[HGBMediaTool urlAnalysis:src];
    if(![HGBMediaTool urlExistCheck:src]){
        HGBLog(@"文件不存在");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"文件不存在"}];
        }
        return;
    }
    NSURL *url=[NSURL URLWithString:src];
    //注册
    SystemSoundID sid;
    OSStatus status=AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url),&sid);//创建结果
    if(status!=0){
        HGBLog(@"注册为系统声音失败,无法播放!");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
            [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeError).stringValue,ReslutMessage:@"注册为系统声音失败,无法播放!"}];
        }
        return;}
    //播放
    AudioServicesPlaySystemSound(sid);
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
        [self.delegate mediaToolDidSucessed:self];
    }


    
}
#pragma mark 震动
/**
 震动
 */
-(void)vibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
#pragma mark 播放系统声音
/**
 播放系统声音

 @param soundId 声音id
 */
-(void)playSystemSoundWithSoundId:(int)soundId{
    // 系统声音
    AudioServicesPlayAlertSound(soundId);
    // 震动 只有iPhone才能震动而且还得在设置里开启震动才行,其他的如touch就没有震动功能
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

}
#pragma mark 打开图片
/**
 查看图片

 @param parent 父控制器
 @param source 路径或url
 */
-(void)lookImageAtSource:(NSString *)source inParent:(UIViewController *)parent{
    [HGBMediaImageLookTool setWebLookDelegate:self];
    [HGBMediaImageLookTool lookFileAtSource:source inParent:parent];
}

#pragma mark 播放录音

/**
 查看录音

 @param parent 父控制器
 @param source 路径或url
 */
-(void)lookAudioAtSource:(NSString *)source inParent:(UIViewController *)parent{
    [HGBMediaFileQuickLookTool setQuickLookDelegate:self];
    [HGBMediaFileQuickLookTool lookFileAtSource:source inParent:parent];
}

#pragma mark 播放录像

/**
 查看视频

 @param parent 父控制器
 @param source 路径或url
 */
-(void)lookVideoAtSource:(NSString *)source inParent:(UIViewController *)parent{
    [HGBMediaFileQuickLookTool setQuickLookDelegate:self];
    [HGBMediaFileQuickLookTool lookFileAtSource:source inParent:parent];

}

#pragma mark 权限判断
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
/**
 相册权限判断

 @return 是否有权限
 */
- (BOOL)isCanUsePhotos {

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        HGBLog(@"%ld",status);
    }];


    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        return NO;
    }
#ifdef __IPHONE_8_0
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
#else
    ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
#endif
    return YES;
}
/**
 相册权限判断

 @return 是否有权限
 */
- (BOOL)isCanSavePhotos {

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        HGBLog(@"%ld",status);
    }];


    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        return NO;
    }
#ifdef __IPHONE_8_0
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
#else
    ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
#endif
    return YES;
}
/**
 麦克风权限判断

 @return 是否有权限
 */
- (BOOL)isCanUseMicrophone{
    if (TARGET_IPHONE_SIMULATOR) {
        return NO;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        HGBLog(@"%@",granted ? @"麦克风准许":@"麦克风不准许");
    }];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus==AVAuthorizationStatusRestricted||authStatus==AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;

}
#pragma mark ImagePickerDelegate
//拿出图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //拍照及相册
    if(self.mediaType==HGBMediaTypeCamera||self.mediaType==HGBMediaTypePhotoLibrary){
        //在图片库中获取照片
        UIImage *image;
        if(self.withoutEdit){
            image=info[UIImagePickerControllerOriginalImage];
        }else{
            image=info[UIImagePickerControllerEditedImage];
        }
        //返回图片
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didReturnImage:)]){
            [self.delegate mediaTool:self didReturnImage:image];
        }
        if(self.isSaveToCache){
            [self saveImageToCaches:image];
        }

        //保存到相册
        if(self.isSaveToAlbum){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }else if(self.mediaType==HGBMediaTypeVideo){
        NSURL *url=info[UIImagePickerControllerMediaURL];
        if(self.isSaveToCache){
            [self saveFileToCaches:[url path]];
        }

        if(self.isSaveToAlbum){
            UISaveVideoAtPathToSavedPhotosAlbum([url pathExtension], self, @selector(video:  didFinishSavingWithError: contextInfo:),NULL);

        }
        
    }
    //隐藏选取照片控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker=nil;
    instance=nil;

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
     HGBLog(@"取消");
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidCanceled:)]){
        [self.delegate mediaToolDidCanceled:self];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker=nil;
    instance=nil;
}
#pragma mark 保存到缓存
/**
 文件保存到缓存

 @param filePath 文件路径
 */
-(void)saveFileToCaches:(NSString *)filePath{
    NSString *dirPath=[NSString stringWithFormat:@"caches://media/%@",[filePath lastPathComponent]];
    dirPath=[[NSURL URLWithString:[HGBMediaTool urlAnalysis:dirPath]] path];
    NSString *path=[HGBMediaTool urlEncapsulation:dirPath];
    NSString *directoryPath=[dirPath stringByDeletingLastPathComponent];
    if(![HGBMediaTool isExitAtFilePath:directoryPath]){
        [HGBMediaTool createDirectoryPath:directoryPath];
    }

    [HGBMediaTool copyFilePath:filePath ToPath:dirPath];
    if([HGBMediaTool isExitAtFilePath:dirPath]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didSucessSaveToCachePath:)]){
            [self.delegate mediaTool:self didSucessSaveToCachePath:path];
        }
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidFailToSaveToCache:)]){
            [self.delegate mediaToolDidFailToSaveToCache:self];
        }
    }
}
/**
 图片保存到缓存

 @param image 图片
 */
-(void)saveImageToCaches:(UIImage *)image{
    NSString *dirPath=[NSString stringWithFormat:@"caches://media/%@.png",[HGBMediaTool getSecondTimeStringSince1970]];
    dirPath=[[NSURL URLWithString:[HGBMediaTool urlAnalysis:dirPath]] path];
    NSString *path=[HGBMediaTool urlEncapsulation:dirPath];
    NSString *directoryPath=[dirPath stringByDeletingLastPathComponent];
    if(![HGBMediaTool isExitAtFilePath:directoryPath]){
        [HGBMediaTool createDirectoryPath:directoryPath];
    }
    NSData *data=UIImagePNGRepresentation(image);
    [data writeToFile:dirPath atomically:YES];

    if([HGBMediaTool isExitAtFilePath:dirPath]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didSucessSaveToCachePath:)]){

            [self.delegate mediaTool:self didSucessSaveToCachePath:path];
        }
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidFailToSaveToCache:)]){
            [self.delegate mediaToolDidFailToSaveToCache:self];
        }
    }
}
#pragma mark 保存相册结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error){
         HGBLog(@"图片保存相册失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidFailToSaveToAlbum:)]){
            [self.delegate mediaToolDidFailToSaveToAlbum:self];
        }

    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessToSaveToAlbum:)]){
            [self.delegate mediaToolDidSucessToSaveToAlbum:self];
        }


    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error){
        HGBLog(@"视频保存相册失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidFailToSaveToAlbum:)]){
            [self.delegate mediaToolDidFailToSaveToAlbum:self];
        }

    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessToSaveToAlbum:)]){
            [self.delegate mediaToolDidSucessToSaveToAlbum:self];
        }

    }
}
#pragma mark look delegate
-(void)imageLookDidOpenSucessed:(HGBMediaImageLookTool *)imageLook{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
        [self.delegate mediaToolDidSucessed:self];
    }

}
-(void)imageLookDidClose:(HGBMediaImageLookTool *)imageLook{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidCanceled:)]){
        [self.delegate mediaToolDidCanceled:self];
    }
}
-(void)imageLookDidOpenFailed:(HGBMediaImageLookTool *)imageLook{
    HGBLog(@"图片打开失败");
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
        [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeError).stringValue,ReslutMessage:@"图片打开失败!"}];
    }

}
-(void)quickLookDidClose:(HGBMediaFileQuickLookTool *)quickLook{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidCanceled:)]){
        [self.delegate mediaToolDidCanceled:self];
    }
}
-(void)quickLookDidOpenFailed:(HGBMediaFileQuickLookTool *)quickLook{
    HGBLog(@"文件打开失败");
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaTool:didFailedWithError:)]){
        [self.delegate mediaTool:self didFailedWithError:@{ReslutCode:@(HGBMediaToolErrorTypeError).stringValue,ReslutMessage:@"文件打开失败!"}];
    }
}
-(void)quickLookDidOpenSucessed:(HGBMediaFileQuickLookTool *)quickLook{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mediaToolDidSucessed:)]){
        [self.delegate mediaToolDidSucessed:self];
    }
}
#pragma mark prompt
-(void)alertWithPrompt:(NSString *)prompt{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self.parent presentViewController:alert animated:YES completion:nil];

}
-(void)alertAuthorityWithPrompt:(NSString *)prompt{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"权限提示" message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if(![HGBMediaTool openAppSetView]){
            [self alertWithPrompt:@"跳转失败,请在设置界面开启权限"];
        }

    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action2];
    [self.parent presentViewController:alert animated:YES completion:nil];
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
        return NO;
    }
}
#pragma mark 获取时间
/**
 获取时间戳-秒级

 @return 秒级时间戳
 */
+ (NSString *)getSecondTimeStringSince1970
{
    NSDate* date = [NSDate date];
    NSTimeInterval interval=[date timeIntervalSince1970];  //  *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%f", interval]; //转为字符型
    NSString *timeStr = [NSString stringWithFormat:@"%lf",[timeString doubleValue]*1000000];

    if(timeStr.length>=16){
        return [timeStr substringToIndex:16];
    }else{
        return timeStr;
    }
}

#pragma mark 文件
/**
 文件拷贝

 @param srcPath 文件路径
 @param filePath 复制文件路径
 @return 结果
 */
+(BOOL)copyFilePath:(NSString *)srcPath ToPath:(NSString *)filePath{
    if(![HGBMediaTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBMediaTool isExitAtFilePath:directoryPath]){
        [HGBMediaTool createDirectoryPath:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage copyItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}

/**
 文件剪切

 @param srcPath 文件路径
 @param filePath 复制文件路径
 @return 结果
 */
+(BOOL)moveFilePath:(NSString *)srcPath ToPath:(NSString *)filePath{
    if(![HGBMediaTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBMediaTool isExitAtFilePath:directoryPath]){
        [HGBMediaTool createDirectoryPath:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage moveItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark 文档通用
/**
 删除文档

 @param filePath 归档的路径
 @return 结果
 */
+ (BOOL)removeFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return YES;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    BOOL deleteFlag=NO;
    if(isExit){
        deleteFlag=[filemanage removeItemAtPath:filePath error:nil];
    }else{
        deleteFlag=NO;
    }
    return deleteFlag;
}
/**
 文档是否存在

 @param filePath 归档的路径
 @return 结果
 */
+(BOOL)isExitAtFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    return isExit;
}

#pragma mark 文件夹

/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBMediaTool isExitAtFilePath:directoryPath]){
        return YES;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];
    BOOL flag=[filemanage createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark url
/**
 判断路径是否是URL

 @param url url路径
 @return 结果
 */
+(BOOL)isURL:(NSString*)url{
    if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"/User"]||[url hasPrefix:@"/var"]||[url hasPrefix:@"http://"]||[url hasPrefix:@"https://"]||[url hasPrefix:@"file://"]){
        return YES;
    }else{
        return NO;
    }
}
/**
 url校验存在

 @param url url
 @return 是否存在
 */
+(BOOL)urlExistCheck:(NSString *)url{
    if(url==nil||url.length==0){
        return NO;
    }
    if(![HGBMediaTool isURL:url]){
        return NO;
    }
     url=[HGBMediaTool urlAnalysis:url];
    if(![url containsString:@"://"]){
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    if([url hasPrefix:@"file://"]){
        NSString *filePath=[[NSURL URLWithString:url]path];
        if(filePath==nil||filePath.length==0){
            return NO;
        }
        NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
        return [filemanage fileExistsAtPath:filePath];
    }else{
        NSURL *urlCheck=[NSURL URLWithString:url];

        return [[UIApplication sharedApplication]canOpenURL:urlCheck];

    }
}
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysisToPath:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![HGBMediaTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBMediaTool urlAnalysis:url];
    return [[NSURL URLWithString:urlstr]path];
}
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysis:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![HGBMediaTool isURL:url]){
        return nil;
    }
    if([url containsString:@"://"]){
        //project://工程包内
        //home://沙盒路径
        //http:// https://网络路径
        //document://沙盒Documents文件夹
        //caches://沙盒Caches
        //tmp://沙盒Tmp文件夹
        if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]){
            if([url hasPrefix:@"project://"]){
                url=[url stringByReplacingOccurrencesOfString:@"project://" withString:@""];
                NSString *projectPath=[[NSBundle mainBundle]resourcePath];
                url=[projectPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"home://"]){
                url=[url stringByReplacingOccurrencesOfString:@"home://" withString:@""];
                NSString *homePath=NSHomeDirectory();
                url=[homePath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"document://"]){
                url=[url stringByReplacingOccurrencesOfString:@"document://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"defaults://"]){
                url=[url stringByReplacingOccurrencesOfString:@"defaults://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"caches://"]){
                url=[url stringByReplacingOccurrencesOfString:@"caches://" withString:@""];
                NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
                url=[cachesPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"tmp://"]){
                url=[url stringByReplacingOccurrencesOfString:@"tmp://" withString:@""];
                NSString *tmpPath =NSTemporaryDirectory();
                url=[tmpPath stringByAppendingPathComponent:url];
            }
            url=[[NSURL fileURLWithPath:url]absoluteString];

        }else{

        }
    }else {
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
}
/**
 url封装

 @return 封装后url
 */
+(NSString *)urlEncapsulation:(NSString *)url{
    if(![HGBMediaTool isURL:url]){
        return nil;
    }
    NSString *homePath=NSHomeDirectory();
    NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
    NSString *projectPath=[[NSBundle mainBundle]resourcePath];
    NSString *tmpPath =NSTemporaryDirectory();

    if([url hasPrefix:@"file://"]){
        url=[url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    if([url hasPrefix:projectPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",projectPath] withString:@"project://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",projectPath] withString:@"project://"];
    }else if([url hasPrefix:documentPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",documentPath] withString:@"defaults://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",documentPath] withString:@"defaults://"];
    }else if([url hasPrefix:cachesPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",cachesPath] withString:@"caches://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",cachesPath] withString:@"caches://"];
    }else if([url hasPrefix:tmpPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",tmpPath] withString:@"tmp://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",tmpPath] withString:@"tmp://"];
    }else if([url hasPrefix:homePath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",homePath] withString:@"home://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",homePath] withString:@"home://"];
    }else if([url containsString:@"://"]){

    }else{
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
}
#pragma mark get
-(UIImagePickerController *)picker{
    if(_picker==nil){
        _picker=[[UIImagePickerController alloc]init];
        _picker.delegate=self;
    }
    return _picker;
}
@end

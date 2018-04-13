//
//  HGBAudioTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/29.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBAudioTool.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>




#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@interface HGBAudioTool ()<AVAudioPlayerDelegate>

/**
 录音
 */
@property(strong,nonatomic)AVAudioRecorder *recorder;
/**
 播放录音
 */
@property(strong,nonatomic)AVAudioPlayer *player;
/**
 录音路径
 */
@property (strong, nonatomic)NSString *recorderPath;
/**
 播放路径
 */
@property (strong, nonatomic)NSURL *playerURL;
@end
@implementation HGBAudioTool
static HGBAudioTool *instance=nil;
#pragma mark init
/**
 单例

 @return 实例
 */
+(instancetype)shareInstance{
    if(instance==nil){
        instance=[[HGBAudioTool alloc]init];
    }
    return instance;
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
    if(![HGBAudioTool isCanUseMicrophone]){
        HGBLog(@"录音功能权限受限!");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];
        }
        [self jumpToSet];
        return NO;
    }
    if(path==nil||path.length==0){
        HGBLog(@"地址不能为空");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeParams).stringValue,ReslutMessage:@"地址不能为空"}];
        }
        return NO;
    }

    NSString *lastPath=[HGBAudioTool urlAnalysisToPath:path];

    NSString *dirPath=[lastPath stringByDeletingLastPathComponent];
    if(![HGBAudioTool isExitAtFilePath:dirPath]){
        [HGBAudioTool createDirectoryPath:dirPath];
    }
    if([HGBAudioTool isExitAtFilePath:lastPath]){
        HGBLog(@"路径已存在");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeExistPath).stringValue,ReslutMessage:@"路径已存在"}];
        }
        return NO;
    }
    self.recorderPath=lastPath;


    //对录音机进行配置
    NSMutableDictionary *setting=[NSMutableDictionary dictionary];
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
    [setting setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];

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
        HGBLog(@"录音功能权限受限!");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];
        }
        return NO;
    }
    if([self.recorder record]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未知错误");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未知错误"}];
        }
        return NO;
    }
}
/**
 开始录音
 */
-(BOOL)startRecording{
    if(![HGBAudioTool isCanUseMicrophone]){
        HGBLog(@"录音功能权限受限!");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];
        }
        [self jumpToSet];
        return NO;
    }
    if(!self.recorder){
        //录音文件路径
        NSString *lastPath=[NSString stringWithFormat:@"caches://media/%@.aac",[HGBAudioTool getSecondTimeStringSince1970]];
        lastPath=[HGBAudioTool urlAnalysisToPath:lastPath];
        NSString *dirPath=[lastPath stringByDeletingLastPathComponent];
        if(![HGBAudioTool isExitAtFilePath:dirPath]){
            [HGBAudioTool createDirectoryPath:dirPath];
        }
        if([HGBAudioTool isExitAtFilePath:lastPath]){
            HGBLog(@"路径已存在");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
                [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeExistPath).stringValue,ReslutMessage:@"路径已存在"}];
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
            HGBLog(@"录音功能权限受限!");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
                [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];
            }
            return NO;
        }
    }
    if([self.recorder record]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未知错误");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未知错误"}];
        }
        return NO;
    }
    
}
/**
 暂停录音
 */
-(BOOL)parseRecording{
    if(![HGBAudioTool isCanUseMicrophone]){
        HGBLog(@"录音功能权限受限!");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];
        }
        [self jumpToSet];
        return NO;
    }
    if(self.recorder){

        [self.recorder pause];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }
}
/**
 结束录音
 */
-(BOOL)stopRecording{
    if(![HGBAudioTool isCanUseMicrophone]){
        HGBLog(@"录音功能权限受限!");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeAuthority).stringValue,ReslutMessage:@"录音功能权限受限!"}];
        }
        [self jumpToSet];
        return NO;
    }
    if(self.recorder){
        [self.recorder stop];
        self.recorder=nil;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }

}
/**
 取消录音
 */
-(BOOL)cancelRecording{
    if(self.recorder){
        [self.recorder stop];
        self.recorder=nil;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }
}

#pragma mark 播放录音
-(void)playAudioWithSource:(NSString *)source{

}
/**
 初始化播放器

 @param source 地址
 */
-(BOOL)initPlayerWithSource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"路径不存在");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"路径不存在"}];
        }
        return NO;
    }
    NSError *error;
    NSString *src=[HGBAudioTool urlAnalysis:source];
    if(![HGBAudioTool urlExistCheck:src]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"播放声音文件不存在!"}];
        }
        return NO;
    }
    self.playerURL=[NSURL URLWithString:src];
    //真迹调试需要添加
    AVAudioSession *as=[AVAudioSession sharedInstance];
    [as setCategory:AVAudioSessionCategoryPlayback error:nil];
    self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:self.playerURL error:&error];

    [as setActive:YES error:nil];
    if(error)
    {
        HGBLog(@"播放声音功能权限受限!");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeAuthority).stringValue,ReslutMessage:@"播放声音功能权限受限!"}];
        }
        return NO;
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didSucessedWithPath:)]){
            [self.delegate audioTool:self didSucessedWithPath:self.recorderPath];
        }
        return YES;
    }
}
/**
 开始播放
 */
-(BOOL)startPlayer{
    if(self&&self.player){
        BOOL flag= [self.player play];
        if(flag){
            if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
                [self.delegate audioToolDidSucessed:self];
            }

            return YES;

        }else{
            HGBLog(@"播放失败");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
                [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"播放失败"}];
            }
            return NO;

        }

    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }

}
/**
 暂停播放
 */
-(BOOL)parsePlayer{
    if(self&&self.player){
         [self.player pause];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }

}
/**
 结束播放
 */
-(BOOL)stopPlayer{
    if(self&&self.player){
        [self.player stop];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }

}
/**
 获取播放器播放音频信息

 @return 信息
 */
-(NSArray *)getPlayerInfo{
    if(self&&self.player&&self.playerURL){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        NSMutableArray *infos=[NSMutableArray array];
        AVURLAsset *avUrlAsset=[[AVURLAsset alloc]initWithURL:self.playerURL options:nil];
        for(NSString *format in [avUrlAsset availableMetadataFormats]){
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            //format-制式
            for(AVMetadataItem *metadata in [avUrlAsset metadataForFormat:format]){

                //作家
                if([metadata.commonKey isEqualToString:@"artist"]){
                    [dic setObject:(NSString *)metadata.value forKey:@"artist"];
                }
                //专辑名
                if([metadata.commonKey isEqualToString:@"albumName"]){
                    [dic setObject:(NSString *)metadata.value forKey:@"albumName"];
                }
                //歌曲名
                if([metadata.commonKey isEqualToString:@"title"]){
                    [dic setObject:(NSString *)metadata.value forKey:@"title"];
                }
                //歌集名
                if([metadata.commonKey isEqualToString:@"artwork"]){
                    [dic setObject:(NSData *)metadata.value forKey:@"artwork"];
                }
            }
            [infos addObject:dic];
        }
        return infos;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return nil;
    }

}
/**
 获取音频时间

 @return 音频时间
 */
-(NSTimeInterval)getDuration{

    if(self&&self.player){

        return self.player.duration;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return 0;
    }

}
/**
 获取已播放时间

 @return 已播放时间
 */
-(NSTimeInterval)getCurrentTime{
    if(self&&self.player){
        return self.player.currentTime;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return 0;
    }

}
/**
 设置播放时间点

 @param currentTime 播放时间点
 @return 结果
 */
-(BOOL)setCurrentTime:(NSTimeInterval)currentTime{
    if(self&&self.player){
         self.player.currentTime=currentTime;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }
        return YES;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }

}
/**
 设置声音

 @param volume 声音
 @return 结果
 */
-(BOOL)setVolume:(CGFloat)volume{
    if(self&&self.player){
         self.player.volume=volume;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
            [self.delegate audioToolDidSucessed:self];
        }

        return YES;
    }else{
        HGBLog(@"未开启");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"未开启"}];
        }
        return NO;
    }


}
#pragma mark set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"麦克风访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
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
#pragma mark 权限
/**
 麦克风权限判断

 @return 是否有权限
 */
+ (BOOL)isCanUseMicrophone{
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
#pragma mark player
//错误
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    HGBLog(@"未开启");
    if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
        [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:error.localizedDescription}];
    }
}
//结束
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
        [self.delegate audioToolDidSucessed:self];
    }

}
#pragma mark 播放wav文件
/**
 播放wav文件

 @param src 文件路径
 */
-(BOOL)playWavWithSource:(NSString *)src{
    if(src==nil||src.length==0){
        HGBLog(@"参数不对");

        return NO;
    }
    if(![[src pathExtension] isEqualToString:@"wav"]){
        HGBLog(@"参数格式错误");

        return NO;
    }
    src=[HGBAudioTool urlAnalysis:src];
    if(![HGBAudioTool urlExistCheck:src]){
        HGBLog(@"文件不存在");

       return NO;
    }
    NSURL *url=[NSURL URLWithString:src];
    //注册
    SystemSoundID sid;
    OSStatus status=AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url),&sid);//创建结果
    if(status!=0){
        HGBLog(@"注册为系统声音失败,无法播放!");
        return NO;

    }
    //播放
    AudioServicesPlaySystemSound(sid);
    return YES;
}
#pragma mark 震动
/**
 震动
 */
-(BOOL)vibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    return YES;
}
#pragma mark 播放系统声音
/**
 播放系统声音

 @param soundId 声音id
 */
-(BOOL)playSystemSoundWithSoundId:(int)soundId{
    // 系统声音
    AudioServicesPlayAlertSound(soundId);
    // 震动 只有iPhone才能震动而且还得在设置里开启震动才行,其他的如touch就没有震动功能
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    return YES;

}
#pragma mark 音频处理

/**
 音频剪切

 @param source 音频路径
 @param startTime 开始时间
 @param endTime 结束时间
 @param destination 目标路径
 @return 结果
 */
-(BOOL)cutAudioWithSource:(NSString *)source andWithStartTime:(NSInteger)startTime andWithEndTime:(NSInteger)endTime toDestination:(NSString*)destination{
    if(source==nil||destination==nil){
        HGBLog(@"音频路径不能为空");
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeParams).stringValue,ReslutMessage:@"参数不能为空"}];
        }
        return NO;
    }
    source=[HGBAudioTool urlAnalysisToPath:source];
    destination=[HGBAudioTool urlAnalysisToPath:destination];
    
    if(![HGBAudioTool urlExistCheck:source]){
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"音频文件不存在"}];
        }
        return NO;
    }
    NSString *extension= [destination pathExtension];
    if(extension==nil||extension.length==0||(![extension isEqualToString:@"m4a"])){
        HGBLog(@"音频输出格式不正确");
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeParams).stringValue,ReslutMessage:@"音频输出格式不正确，目前仅支持输出.m4a的音频"}];
        }
        return NO;
    }
    if([HGBAudioTool urlExistCheck:destination]){
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"音频处理后保存路径存在"}];
        }
        return NO;
    }


    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:source]];
    //音频输出会话
    //AVAssetExportPresetAppleM4A: This export option will produce an audio-only .m4a file with appropriate iTunes gapless playback data(输出音频,并且是.m4a格式)
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:videoAsset presetName:AVAssetExportPresetAppleM4A];
    //设置输出路径 / 文件类型 / 截取时间段
    exportSession.outputURL = [NSURL URLWithString:destination];
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = CMTimeRangeFromTimeToTime(CMTimeMake(startTime, 1), CMTimeMake(endTime, 1));
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status==3) {
            if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
                [self.delegate audioToolDidSucessed:self];
            }

        }else{
            if (exportSession.error) {
                if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
                    [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"视频合成失败"}];
                }

            }else{
                if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
                    [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:exportSession.error.localizedDescription}];
                }
            }


        }
    }];
    return YES;
}
/**
 音频合成

 @param source 音频路径
 @param otherSource 音频路径2
 @param destination 目标路径
 @return 结果
 */
-(BOOL)makeupAudioWithSource:(NSString *)source andWithOtherSource:(NSString *)otherSource  toDestination:(NSString*)destination{

    if(source==nil||destination==nil||otherSource==nil){
        HGBLog(@"音频路径不能为空");
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeParams).stringValue,ReslutMessage:@"参数不能为空"}];
        }
        return NO;
    }
    NSString *extension= [destination pathExtension];
    if(extension==nil||extension.length==0||(![extension isEqualToString:@"m4a"])){
        HGBLog(@"音频输出格式不正确");
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeParams).stringValue,ReslutMessage:@"音频输出格式不正确，目前仅支持输出.m4a的音频"}];
        }
        return NO;
    }
    source=[HGBAudioTool urlAnalysisToPath:source];
    otherSource=[HGBAudioTool urlAnalysisToPath:otherSource];
    destination=[HGBAudioTool urlAnalysisToPath:destination];

    if(!([HGBAudioTool urlExistCheck:source]||[HGBAudioTool urlExistCheck:otherSource])){
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"音频文件不存在"}];
        }
        return NO;
    }
    if([HGBAudioTool urlExistCheck:destination]){
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]) {
            [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"音频处理后保存路径存在"}];
        }
        return NO;
    }
    //AVURLAsset子类的作用则是根据NSURL来初始化AVAsset对象.
    AVURLAsset *videoAsset1 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:source] options:nil];
    AVURLAsset *videoAsset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:otherSource] options:nil];
    //音频轨迹(一般视频至少有2个轨道,一个播放声音,一个播放画面.音频有一个)
    AVAssetTrack *assetTrack1 = [[videoAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetTrack *assetTrack2 = [[videoAsset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    //AVMutableComposition用来合成视频或音频
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 把第二段录音添加到第一段后面
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset1.duration) ofTrack:assetTrack1 atTime:kCMTimeZero error:nil];
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset2.duration) ofTrack:assetTrack2 atTime:videoAsset1.duration error:nil];
    //输出
    AVAssetExportSession *exporeSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    exporeSession.outputFileType = AVFileTypeAppleM4A;
    exporeSession.outputURL = [NSURL fileURLWithPath:destination];
    [exporeSession exportAsynchronouslyWithCompletionHandler:^{

        if (exporeSession.status==3) {
            if(self.delegate&&[self.delegate respondsToSelector:@selector(audioToolDidSucessed:)]){
                [self.delegate audioToolDidSucessed:self];
            }

        }else{
            if (exporeSession.error) {
                if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
                    [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:@"视频合成失败"}];
                }

            }else{
                if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
                    [self.delegate audioTool:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeError).stringValue,ReslutMessage:exporeSession.error.localizedDescription}];
                }
            }


        }

    }];
    return YES;
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
    if(![HGBAudioTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBAudioTool isExitAtFilePath:directoryPath]){
        [HGBAudioTool createDirectoryPath:directoryPath];
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
    if(![HGBAudioTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBAudioTool isExitAtFilePath:directoryPath]){
        [HGBAudioTool createDirectoryPath:directoryPath];
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
    if([HGBAudioTool isExitAtFilePath:directoryPath]){
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
    if(![HGBAudioTool isURL:url]){
        return NO;
    }
     url=[HGBAudioTool urlAnalysis:url];
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
    if(![HGBAudioTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBAudioTool urlAnalysis:url];
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
    if(![HGBAudioTool isURL:url]){
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
    if(![HGBAudioTool isURL:url]){
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

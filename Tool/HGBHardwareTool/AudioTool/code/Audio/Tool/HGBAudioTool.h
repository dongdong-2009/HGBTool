//
//  HGBAudioTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/29.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


/**
 错误类型
 */
typedef enum HGBAudioToolErrorType
{
    HGBAudioToolErrorTypeParams=0,//参数错误
    HGBAudioToolErrorTypeDevice=10,//设备受限
    HGBAudioToolErrorTypeNotExistPath=20,//路径已存在
    HGBAudioToolErrorTypeExistPath=21,//路径已存在
    HGBAudioToolErrorTypePathTypeError=22,//文件格式错误
    HGBAudioToolErrorTypeError=99,//错误
    HGBAudioToolErrorTypeAuthority=11//权限受限

}HGBAudioToolErrorType;

@class HGBAudioTool;
/**
 代理
 */
@protocol HGBAudioToolDelegate <NSObject>

@optional

/**
 成功

 @param audio 媒体
 */
-(void)audioToolDidSucessed:(HGBAudioTool *)audio;
/**
 成功

 @param audio 媒体
 @param path 路径
 */
-(void)audioTool:(HGBAudioTool *)audio didSucessedWithPath:(NSString *)path;
/**
 失败

 @param audio 媒体
 @param errorInfo 错误信息
 */
-(void)audioTool:(HGBAudioTool *)audio didFailedWithError:(NSDictionary *)errorInfo;
/**
 取消

 @param audio 媒体
 */
-(void)audioToolDidCanceled:(HGBAudioTool *)audio;
@end

@interface HGBAudioTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBAudioToolDelegate>delegate;
#pragma mark init
/**
 单例

 @return 实例
 */
+(instancetype)shareInstance;

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
-(BOOL)initRecordingWithPath:(NSString *)path andWithRate:(CGFloat)rate andWithNumberOfChannels:(NSInteger)numberOfChannels andWithPCMBitDepth:(NSInteger)depth andwithQuality:(AVAudioQuality)quality;
/**
 开始录音
 */
-(BOOL)startRecording;
/**
 暂停录音
 */
-(BOOL)parseRecording;
/**
 结束录音
 */
-(BOOL)stopRecording;
/**
 取消录音
 */
-(BOOL)cancelRecording;
#pragma mark 播放录音
/**
 初始化播放器

 @param source 地址
 */
-(BOOL)initPlayerWithSource:(NSString *)source;
/**
 开始播放
 */
-(BOOL)startPlayer;
/**
 暂停播放
 */
-(BOOL)parsePlayer;
/**
 结束播放
 */
-(BOOL)stopPlayer;
/**
 获取播放器播放音频信息

 @return 信息
 */
-(NSArray *)getPlayerInfo;
/**
 获取音频时间

 @return 音频时间
 */
-(NSTimeInterval)getDuration;
/**
 获取已播放时间

 @return 已播放时间
 */
-(NSTimeInterval)getCurrentTime;
/**
 设置播放时间点

 @param currentTime 播放时间点
 @return 结果
 */
-(BOOL)setCurrentTime:(NSTimeInterval)currentTime;
/**
 设置声音

 @param volume 声音
 @return 结果
 */
-(BOOL)setVolume:(CGFloat)volume;
#pragma mark 播放wav文件
/**
 播放wav文件

 @param src 文件路径
 */
-(BOOL)playWavWithSource:(NSString *)src;
#pragma mark 震动
/**
 震动
 */
-(BOOL)vibrate;
#pragma mark 播放系统声音
/**
 播放系统声音

 @param soundId 声音id
 */
-(BOOL)playSystemSoundWithSoundId:(int)soundId;
#pragma mark 音频处理

/**
  音频剪切

 @param source 音频路径
 @param startTime 开始时间
 @param endTime 结束时间
 @param destination 目标路径
 @return 结果
 */
-(BOOL)cutAudioWithSource:(NSString *)source andWithStartTime:(NSInteger)startTime andWithEndTime:(NSInteger)endTime toDestination:(NSString*)destination;
/**
 音频合成

 @param source 音频路径
 @param otherSource 音频路径2
 @param destination 目标路径
 @return 结果
 */
-(BOOL)makeupAudioWithSource:(NSString *)source andWithOtherSource:(NSString *)otherSource  toDestination:(NSString*)destination;
@end

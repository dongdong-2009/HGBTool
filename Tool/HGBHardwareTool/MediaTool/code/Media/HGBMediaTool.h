//
//  HGBMediaTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/8.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
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
typedef enum HGBMediaToolErrorType
{
    HGBMediaToolErrorTypeParams=0,//参数错误
    HGBMediaToolErrorTypeDevice=10,//设备受限
    HGBMediaToolErrorTypeNotExistPath=20,//路径已存在
    HGBMediaToolErrorTypeExistPath=21,//路径已存在
    HGBMediaToolErrorTypePathTypeError=22,//文件格式错误
    HGBMediaToolErrorTypeError=99,//错误
    HGBMediaToolErrorTypeAuthority=11//权限受限

}HGBMediaToolErrorType;

@class HGBMediaTool;
/**
 多媒体代理
 */
@protocol HGBMediaToolDelegate <NSObject>

@optional
#pragma mark 图片:拍照-相册支持

/**
 相机相册返回图片

 @param image 图片
 */
-(void)mediaTool:(HGBMediaTool *)media  didReturnImage:(UIImage *)image;

#pragma mark 保存到缓存:拍照-相册-录音-录像支持
/**
 相机相册录像录音返回媒体保存路径

 @param path 路径
 */
-(void)mediaTool:(HGBMediaTool *)media  didSucessSaveToCachePath:(NSString *)path;
/**
 保存缓存失败

 @param media 媒体
 */
-(void)mediaToolDidFailToSaveToCache:(HGBMediaTool *)media;

#pragma mark 保存到相册:拍照-相册-录像支持
/**
 保存相册失败

 @param media 媒体
 */
-(void)mediaToolDidFailToSaveToAlbum:(HGBMediaTool *)media;
/**
 保存相册成功

 @param media 媒体
 */
-(void)mediaToolDidSucessToSaveToAlbum:(HGBMediaTool *)media;


#pragma mark 取消:拍照-相册-录音-录像-查看支持
/**
 成功

 @param media 媒体
 */
-(void)mediaToolDidSucessed:(HGBMediaTool *)media;
/**
 失败

 @param media 媒体
 @param errorInfo 错误信息
 */
-(void)mediaTool:(HGBMediaTool *)media didFailedWithError:(NSDictionary *)errorInfo;
/**
 取消

 @param media 媒体
 */
-(void)mediaToolDidCanceled:(HGBMediaTool *)media;
@end


@interface HGBMediaTool : NSObject
#pragma mark 配置参数
/**
 图片是否可编辑:拍照-相册支持
 */
@property(assign,nonatomic)BOOL withoutEdit;
/**
 是否保存到相册:拍照-相册-录像支持
 */
@property(assign,nonatomic)BOOL isSaveToAlbum;
/**
 是否保存缓存:拍照-相册-录音-录像支持
 */
@property(assign,nonatomic)BOOL isSaveToCache;


#pragma mark init
/**
 单例

 @return 实例
 */
+(instancetype)instanceWithParent:(UIViewController *)parent andWithDelegate:(id<HGBMediaToolDelegate>)delegate;

#pragma mark 手电筒
/**
 打开手电筒
 */
-(BOOL)startOnTorch;
/**
 关闭手电筒
 */
-(BOOL)startOffTorch;
#pragma mark 调用相机
/**
 调用相机
 */
-(BOOL)startCamera;
#pragma mark 调用相册
/**
 调用相册
 */
-(BOOL)startPhotoAlbum;
#pragma mark 调用录像
/**
 调用录像
 */
-(BOOL)startVideo;
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

#pragma mark 保存到相册
/**
 保存到相册

 @param object 图片或图片视频路径
 @return 结果
 */
-(BOOL)saveToAlbumWithObject:(id)object;
#pragma mark 播放wav文件
/**
 播放wav文件

 @param src 文件路径
 */
-(void)playWavWithSource:(NSString *)src;
#pragma mark 震动
/**
 震动
 */
-(void)vibrate;
#pragma mark 播放系统声音
/**
 播放系统声音

 @param soundId 声音id
 */
-(void)playSystemSoundWithSoundId:(int)soundId;
#pragma mark 打开图片


/**
 查看图片

 @param parent 父控制器
 @param source 路径或url
 */
-(void)lookImageAtSource:(NSString *)source inParent:(UIViewController *)parent;



#pragma mark 播放录音

/**
 查看录音

 @param parent 父控制器
 @param source 路径或url
 */
-(void)lookAudioAtSource:(NSString *)source inParent:(UIViewController *)parent;


#pragma mark 播放录像

/**
 查看视频

 @param parent 父控制器
 @param source 路径或url
 */
-(void)lookVideoAtSource:(NSString *)source inParent:(UIViewController *)parent;




@end

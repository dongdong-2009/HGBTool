//
//  HGBVideoTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/29.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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
typedef enum HGBVideoToolErrorType
{
    HGBVideoToolErrorTypeParams=0,//参数错误
    HGBVideoToolErrorTypeDevice=10,//设备受限
    HGBVideoToolErrorTypeNotExistPath=20,//路径已存在
    HGBVideoToolErrorTypeExistPath=21,//路径已存在
    HGBVideoToolErrorTypePathTypeError=22,//文件格式错误
    HGBVideoToolErrorTypeError=99,//错误
    HGBVideoToolErrorTypeAuthority=11//权限受限

}HGBVideoToolErrorType;

@class HGBVideoTool;
/**
 代理
 */
@protocol HGBVideoToolDelegate <NSObject>


@optional

/**
 成功

 @param audio 媒体
 */
-(void)videoToolDidSucessed:(HGBVideoTool *)audio;
/**
录像返回媒体保存路径

 @param path 路径
 */
-(void)videoTool:(HGBVideoTool *)video  didSucessSaveToCachePath:(NSString *)path;
/**
 保存缓存失败

 @param video 媒体
 */
-(void)videoToolDidFailToSaveToCache:(HGBVideoTool *)video;

#pragma mark 保存到相册:拍照-相册-录像支持
/**
 保存相册失败

 @param video 媒体
 */
-(void)videoToolDidFailToSaveToAlbum:(HGBVideoTool *)video;
/**
 保存相册成功

 @param video 媒体
 */
-(void)videoToolDidSucessToSaveToAlbum:(HGBVideoTool *)video;
/**
 失败

 @param video 媒体
 @param errorInfo 错误信息
 */
-(void)videoTool:(HGBVideoTool *)video didFailedWithError:(NSDictionary *)errorInfo;
/**
 取消

 @param video 媒体
 */
-(void)videoToolDidCanceled:(HGBVideoTool *)video;
@end

@interface HGBVideoTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBVideoToolDelegate>delegate;
/**
 单例

 @return 实例
 */
+(instancetype)shareInstance;
#pragma mark 配置参数
/**
 是否保存到相册
 */
@property(assign,nonatomic)BOOL isSaveToAlbum;
/**
 是否保存缓存
 */
@property(assign,nonatomic)BOOL isSaveToCache;

#pragma mark 调用录像
/**
 调用录像
@param parent 父控制器
 */
-(BOOL)startVideoInParent:(UIViewController *)parent;
/**
 打开视频

 @param source 视频源
 */
-(void)openPlayerWithSource:(NSString *)source;
@end

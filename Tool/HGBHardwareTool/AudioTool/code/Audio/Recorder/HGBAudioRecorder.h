//
//  HGBAudioRecorder.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/20.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

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


@class HGBAudioRecorder;
/**
 代理
 */
@protocol HGBAudioRecorderDelegate <NSObject>

@optional

/**
 成功

 @param recorder 媒体
 */
-(void)audioRecorderDidSucessed:(HGBAudioRecorder *)recorder;
/**
 成功

 @param recorder 媒体
 @param path 路径
 */
-(void)audioRecorder:(HGBAudioRecorder *)recorder didSucessedWithPath:(NSString *)path;
/**
 失败

 @param recorder 媒体
 @param errorInfo 错误信息
 */
-(void)audioRecorder:(HGBAudioRecorder *)recorder didFailedWithError:(NSDictionary *)errorInfo;
/**
 取消

 @param recorder 媒体
 */
-(void)audioRecorderDidCanceled:(HGBAudioRecorder *)recorder;
@end

@interface HGBAudioRecorder : UIViewController
/**
 代理
 */
@property(strong,nonatomic)id<HGBAudioRecorderDelegate>delegate;
/**
 录音地址
 */
@property(strong,nonatomic)NSString *url;
@end

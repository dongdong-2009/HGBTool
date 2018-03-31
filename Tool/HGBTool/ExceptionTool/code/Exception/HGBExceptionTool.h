//
//  HGBExceptionTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/11.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

typedef void (^HGBExceptionHandleBlock)(void);
typedef void (^HGBExceptionErrorBlock)(NSException *exception);
typedef void (^HGBExceptionFinalBlock)(void);

@interface HGBExceptionTool : NSObject

#pragma mark 崩落捕获

/**
 设置崩溃监控-app登录时
 */
+(void)setExceptionMonitor;

/**
 错误捕捉

 @param hanldeBloack 函数
 @param errorBloack 错误
 */
+(void)catchExceptionWithHandle:(HGBExceptionHandleBlock)hanldeBloack andWithError:(HGBExceptionErrorBlock)errorBloack;

/**
 错误捕捉

 @param hanldeBloack 函数
 @param errorBloack 错误
 @param finalBloack 下一步执行
 */
+(void)catchExceptionWithHandle:(HGBExceptionHandleBlock)hanldeBloack andWithError:(HGBExceptionErrorBlock)errorBloack andWithFinal:(HGBExceptionFinalBlock)finalBloack;


#pragma mark 错误文件处理
/**
 获取未标记错误列表-一般用于未上传服务器

 @return 已归档错误列表
 */
+(NSArray *)getUnMarkExceptionLogs;
/**
 标记错误日志

 @param exceptionLogs 错误日志列表
 @return 成功失败
 */
+(BOOL)markExceptionLogs:(NSArray *)exceptionLogs;
/**
 获取已归档错误列表

 @return 已归档错误列表
 */
+(NSArray *)getAllExceptionLogs;
/**
 主动保存崩溃

 @param exception 崩溃
 */
+ (void)saveException:(NSException *)exception;
/**
  保存错误日志

 @param exceptions 错误日志
 @return 结果
 */
+(BOOL)saveExceptions:(NSArray *)exceptions;
#pragma mark 路径
/**
 获取崩溃日志log版路径

 @return 崩溃日志路径url
 */
+(NSString *)getExceptionLogFile;
/**
 获取崩溃日志plist版路径url

 @return 崩溃日志路径
 */
+(NSString *)getExceptionPlistFile;
#pragma mark 工具
/**
 *  获取UUID
 *
 *  @return 获取的UUID的值
 */
+ (NSString *)getDefaultsUdidCode;
#pragma mark url
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysis:(NSString *)url;
/**
 url解析

 @return path
 */
+(NSString *)urlAnalysisToPath:(NSString *)url;
@end

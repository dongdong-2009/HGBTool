//
//  HGBLogTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/5/9.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGBLogTool : NSObject
#pragma mark 日志文件重定向
/**
 将日志文件重定向
 */
+ (void)redirectLogToDocumentFolder;
#pragma mark 获取日志列表
/**
 获取日志路径列表文件路径

 @return 路径
 */
+(NSString *)getLogPathListFilePath;
/**
 获取日志路径列表

 @return 日志路径列表
 */
+(NSArray *)getLogListPaths;
/**
 获取日志列表

 @return 日志列表
 */
+(NSArray *)getLogLists;

#pragma mark url
/**
 判断路径是否是URL

 @param url url路径
 @return 结果
 */
+(BOOL)isURL:(NSString*)url;
/**
 url校验存在

 @param url url
 @return 是否存在
 */
+(BOOL)urlExistCheck:(NSString *)url;
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysisToPath:(NSString *)url;
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysis:(NSString *)url;
/**
 url封装

 @return 封装后url
 */
+(NSString *)urlEncapsulation:(NSString *)url;
@end

//
//  HGBSELogTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/5/10.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HGBSELogKey @"HGBSELog"

#define HGBSELog(FORMAT,...) fprintf(stderr,"**********HGBLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);  [[NSNotificationCenter defaultCenter]postNotification:[[NSNotification alloc]initWithName:HGBSELogKey object:nil userInfo:@{@"log":[NSString stringWithFormat:@"**********HGBLog-satrt***********{文件名称:%s;方法:%s;行数:%d;提示:%s}**********HGBLog-end***********",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]]}]]


typedef void (^HGBSELogToolLogBlock)(NSString *log);

@interface HGBSELogTool : NSObject
#pragma mark init
+ (instancetype)shareInstance;
/**
 日志块
 */
@property(strong,nonatomic)HGBSELogToolLogBlock logBlock;

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

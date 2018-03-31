//
//  HGBURLTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/7.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface HGBURLTool : NSObject
#pragma mark url常用
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
#pragma mark url编码
/**
 *  url字符处理
 *
 *  @param urlString 原url
 *
 *  @return 新url
 */
+(NSString *)urlFormatString:(NSString *)urlString;
#pragma mark url参数
/**
 从url中获取参数

 @param url url
 @return 参数
 */
+(NSDictionary *)getParamsFromURL:(NSString *)url;
/**
 从url中获取参数

 @param url url
 @param key 字段名
 @return 参数
 */
+(NSString *)getParamsFromURL:(NSString *)url andWithKey:(NSString *)key;

@end

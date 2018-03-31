//
//  HGBXMLWriter.h
//  测试
//
//  Created by huangguangbao on 2017/9/5.
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



@interface HGBXMLWriter : NSObject

#pragma mark 字典
/**
 *  XML生成
 *
 *  @param object 数据源 数据类型可以为字典数组json字符串
 *
 *  @return xml结果
 */
+(NSString *)XMLStringFromObject:(NSObject *)object;
/**
 *  XML生成
 *
 *  @param object 数据源 数据类型可以为字典数组json字符串
 *  @param header 是否是属性
 *
 *  @return xml结果
 */
+(NSString *)XMLStringFromObject:(NSObject *)object withHeader:(BOOL)header;
/**
 *  XML生成
 *
 *  @param object 数据源 数据类型可以为字典数组json字符串
 *  @param header 是否是属性
 *  @param destination xml文件地址或url
 *  @param error 错误
 *
 *  @return xml结果
 */
+(BOOL)XMLFileFromObject:(NSObject *)object withHeader:(BOOL)header toDestinationFile:(NSString *)destination  Error:(NSError **)error;
#pragma mark url

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
@end

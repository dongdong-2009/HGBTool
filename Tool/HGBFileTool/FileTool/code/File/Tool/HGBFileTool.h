//
//  HGBFileTool.h
//  二维码条形码识别
//
//  Created by huangguangbao on 2017/6/9.
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

@interface HGBFileTool : NSObject

#pragma mark 文件归档和反归档-普通

/**
 归档-普通
 
 @param object 要归档的数据
 @param destination 归档的路径或url
 @return 保存结果
 */
+ (BOOL)archiverWithObject:(id)object toDestination:(NSString *)destination;
/**
 反归档-普通
 
 @param source 要解归档的路径或url
 @return 保存结果
 */
+ (id)unarcheiverWithFileSource:(NSString *)source;
#pragma mark 文件归档和反归档-加密
/**
 归档-加密
 
 @param object 要归档的数据
 @param destination 归档路径或url
 @param key 密钥
 @return 保存结果
 */
+ (BOOL)archiverEncryptWithObject:(id)object toDestination:(NSString *)destination andWithKey:(NSString *)key;
/**
 反归档-加密
 
 @param source 要解归档路径或url
 @param key 密钥
 @return 解归档后对象
 */
+ (id)unarcheiverWithEncryptFileSource:(NSString *)source andWithKey:(NSString *)key;

#pragma mark 文档通用
/**
 文件拷贝
 
 @param source 文件路径或url
 @param destination 复制文件路径或url
 @return 结果
 */
+(BOOL)copyFileSource:(NSString *)source toDestination:(NSString *)destination;

/**
 文件剪切
 
 @param source 文件路径或url
 @param destination 复制文件路径或url
 @return 结果
 */
+(BOOL)moveFileSource:(NSString *)source toDestination:(NSString *)destination;

/**
 删除文档
 
 @param source 归档的路径或url
 @return 结果
 */
+ (BOOL)removeFileSource:(NSString *)source;
/**
 文档是否存在
 
 @param source 归档的路径或url
 @return 结果
 */
+(BOOL)isExitAtFileSource:(NSString *)source;

#pragma mark 文件夹
/**
 路径是不是文件夹

 @param source 路径或url
 @return 结果
*/
+(BOOL)isDirectoryAtSource:(NSString *)source;
/**
 创建文件夹
 
 @param source 路径或url
 @return 结果
 */
+(BOOL)createDirectorySource:(NSString *)source;

/**
 获取文件夹直接子路径
 
 @param source 文件夹路径或url
 @return 结果
 */
+(NSArray *)getDirectSubPathsInDirectorySource:(NSString *)source;
/**
 获取文件夹所有子路径或url
 
 @param source 文件夹路径
 @return 结果
 */
+(NSArray *)getAllSubPathsInDirectorySource:(NSString *)source;
#pragma mark 文件信息
/**
 获取文件信息

 @param source 文件路径或url
 @return 文件信息
 */
+(NSDictionary *)getFileInfoFromFileSource:(NSString *)source;
/**
 文档是否可读

 @param source 文件路径或url
 @return 结果
 */
+(BOOL)isReadableFileAtFileSource:(NSString *)source;
/**
 文档是否可写

 @param source 文件路径或url
 @return 结果
 */
+(BOOL)isWriteableFileAtFileSource:(NSString *)source;
/**
 文档是否可删

 @param source 文件路径或url
 @return 结果
 */
+(BOOL)isDeleteableFileAtFileSource:(NSString *)source;
#pragma mark url
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

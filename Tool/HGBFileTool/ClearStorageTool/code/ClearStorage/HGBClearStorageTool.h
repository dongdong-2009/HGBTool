//
//  HGBClearStorageTool.h
//  HelloCordova
//
//  Created by huangguangbao on 2017/8/3.
//
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
@interface HGBClearStorageTool : NSObject
/**
 清除缓存

 @param source 缓存URL或路径
 */
+(BOOL)clearStrorageAtSource:(NSString *)source;
/**
 清除http Caches缓存
 */
+(BOOL)clearHttpCachesStrorage;
/**
 清除缓存

 @param path 缓存地址
 */
+(BOOL)clearStrorageAtPath:(NSString *)path;
/**
 清除沙盒路径或子路径的缓存

 @param subPath 子路径-子路径为空时清空沙盒
 @return 结果
 */
+(BOOL)clearHomeStrorageWithSubPath:(NSString *)subPath;
/**
 清除沙盒Document路径或子路径的缓存

 @param subPath 子路径-子路径为空时清空Document
 @return 结果
 */
+(BOOL)clearDocumentStrorageWithSubPath:(NSString *)subPath;
/**
 清除沙盒Cache路径或子路径的缓存

 @param subPath 子路径-子路径为空时清空Cache
 @return 结果
 */
+(BOOL)clearCacheStrorageWithSubPath:(NSString *)subPath;
/**
 清除沙盒Tmp路径或子路径的缓存

 @param subPath 子路径-子路径为空时清空Tmp
 @return 结果
 */
+(BOOL)clearTmpStrorageWithSubPath:(NSString *)subPath;
@end

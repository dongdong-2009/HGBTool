//
//  HGBXMLReader.h
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



/** 解析超时时间，默认 1.0s */
#define PARSER_TIMEOUT 1.0

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

@interface HGBXMLReader : NSObject
#pragma mark 设置
/**
 *  是否读取最外层Item
 *
 *  @param isReadBaseItem 读取
 *
 */
+(void)isReadBaseItem:(BOOL)isReadBaseItem;
#pragma mark 工具
/**
 *  XML解析
 *
 *  @param source 待解析的xml路径或url
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithXmlFile:(NSString *)source;

/**
 *  XML解析
 *
 *  @param xmlString 待解析的xml字符串
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithXMLString:(NSString *)xmlString;
/**
 *  XML解析
 *
 *  @param data 待解析的二进制数据
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithData:(NSData *)data;
@end

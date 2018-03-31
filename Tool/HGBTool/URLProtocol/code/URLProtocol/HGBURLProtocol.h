//
//  HGBURLProtocol.h
//  测试
//
//  Created by huangguangbao on 2017/12/26.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>


//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

@interface HGBURLProtocol : NSURLProtocol
/**
 设置URL黑名单

 @param blackList 黑名单
 */
+(void)setBlackListArray:(NSArray <NSString *>*)blackList;
/**
 设置URL 白名单

 @param whiteList 白名单
 */
+(void)setWhiteListArray:(NSArray <NSString *>*)whiteList;
@end

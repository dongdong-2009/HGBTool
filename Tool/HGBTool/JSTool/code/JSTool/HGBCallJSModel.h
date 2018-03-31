//
//  HGBCallJSModel.h
//  测试
//
//  Created by huangguangbao on 2017/7/13.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

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

@interface HGBCallJSModel : NSObject
/**
 调用js方法

 @param source js文件路径或url
 @param jsFunction 方法名
 @param jsArguments 参数
 @return 结果
 */
+(JSValue *)callJSInJSFile:(NSString *)source WithFunction:(NSString *)jsFunction andWithArguments:(NSArray *)jsArguments;

/**
 调用js方法
 
 @param jsString js
 @param jsFunction 方法名
 @param jsArguments 参数
 @return 结果
 */
+(JSValue *)callJSWithJSString:(NSString *)jsString WithFunction:(NSString *)jsFunction andWithArguments:(NSArray *)jsArguments;
@end

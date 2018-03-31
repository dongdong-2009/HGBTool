//
//  HGBDefaultsTool.h
//  测试
//
//  Created by huangguangbao on 2017/9/15.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


/**
 偏好保存
 */
@interface HGBDefaultsTool : NSObject

/**
 *  Defaults保存
 *
 *  @param value   要保存的数据
 *  @param key   关键字
 *  @return 保存结果
 */
+(BOOL)saveDefaultsValue:(id)value WithKey:(NSString *)key;
/**
 *  Defaults取出
 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
+(id)getDefaultsWithKey:(NSString *)key;
/**
 *  Defaults删除 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
+(BOOL)deleteDefaultsWithKey:(NSString *)key;
#pragma mark defaults加密版

/**
 *  Defaults保存加密版
 *
 *  @param value   要保存的数据
 *  @param key   关键字
 *  @param encryptKey    密钥默认为key
 *  @return 保存结果
 */
+(BOOL)saveDefaultsValue:(id)value WithKey:(NSString *)key andWithEncryptKey:(NSString *)encryptKey;
/**
 *  Defaults取出加密版
 *
 *  @param key     关键字
 *  @param encryptKey    密钥默认为key
 *  return  返回已保存的数据
 */
+(id)getDefaultsWithKey:(NSString *)key andWithEncryptKey:(NSString *)encryptKey;
@end

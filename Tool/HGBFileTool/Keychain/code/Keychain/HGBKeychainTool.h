//
//  HGBKeychainTool.h
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
 钥匙串保存
 */
@interface HGBKeychainTool : NSObject

/**
 *  keychain存
 *
 *  @param key   要存的对象的key值
 *  @param value 要保存的value值
 *  @return 保存结果
 */
+ (BOOL)saveKeyChainValue:(id)value withKey:(NSString *)key;
/**
 *  keychain取
 *
 *  @param key 对象的key值
 *
 *  @return 获取的对象
 */

+ (id)getKeychainWithKey:(NSString *)key;
/**
 *  keychain删除
 *
 *  @param key   要存的对象的key值
 *  @return 保存结果
 */
+ (BOOL)deleteKeyChainWithKey:(NSString *)key;
@end

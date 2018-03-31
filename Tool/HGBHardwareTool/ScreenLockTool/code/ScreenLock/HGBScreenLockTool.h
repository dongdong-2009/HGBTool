//
//  HGBScreenLockTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/18.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGBScreenLockTool : NSObject
/**
 开启自动锁屏
 */
+(void)openAutoScreenLock;
/**
 关闭自动锁屏
 */
+(void)closeAutoScreenLock;
@end

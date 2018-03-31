//
//  HGBBackgroundTaskTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HGBBackgroundTaskTool : NSObject
#pragma mark 单例
+(instancetype)shareInstance;
#pragma mark 功能
/**
 开启后台模式-执行完毕后请结束任务
 */
-(void)startBackgroundTask;
/**
 结束后台任务
 */
-(void)stopBackgroundTask;
@end

//
//  HGBBackgroundTaskTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBBackgroundTaskTool.h"
#import <UIKit/UIKit.h>


typedef void (^HGBBackgroundTaskToolBlock)(void);


@interface HGBBackgroundTaskTool()
/**
 后台任务
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier backTask;
/**
 定时器
 */
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation HGBBackgroundTaskTool
#pragma mark 单例
static HGBBackgroundTaskTool *instance=nil;
+(instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBBackgroundTaskTool alloc]init];
    }
    return instance;
}
#pragma mark 功能
/**
 开启后台模式-执行完毕后请结束任务

 @param taskBlock 任务
 */
-(void)startBackgroundTaskWithTaskBlock:(HGBBackgroundTaskToolBlock)taskBlock {
     UIApplication*  app = [UIApplication sharedApplication];
    self.backTask =[app beginBackgroundTaskWithExpirationHandler:^(void) {
        taskBlock();
        //开启定时器 不断向系统请求后台任务执行的时间
        self.timer = [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
        [self.timer fire];

    }];
}
/**
 开启后台模式-执行完毕后请结束任务
 */
-(void)startBackgroundTask{
    UIApplication*  app = [UIApplication sharedApplication];
    self.backTask =[app beginBackgroundTaskWithExpirationHandler:^(void) {
        //开启定时器 不断向系统请求后台任务执行的时间
        self.timer = [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
        [self.timer fire];

    }];
}

-(void)applyForMoreTime {
    UIApplication*  app = [UIApplication sharedApplication];
    //如果系统给的剩余时间小于60秒 就终止当前的后台任务，再重新初始化一个后台任务，重新让系统分配时间，这样一直循环下去，保持APP在后台一直处于active状态。
    if (app.backgroundTimeRemaining < 60) {
        [app endBackgroundTask:self.backTask];
        self.backTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:self.backTask];
            self.backTask = UIBackgroundTaskInvalid;
        }];
    }
}

/**
 结束后台任务
 */
-(void)stopBackgroundTask{

    if(self.backTask){
        UIApplication*  app = [UIApplication sharedApplication];
        [app endBackgroundTask:self.backTask];
        self.backTask = UIBackgroundTaskInvalid;
        [self.timer invalidate];
    }
}
@end

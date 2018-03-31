//
//  HGBDistanceSensorTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/16.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBDistanceSensorTool.h"
#import <UIKit/UIKit.h>

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



@interface HGBDistanceSensorTool()

@end
@implementation HGBDistanceSensorTool
#pragma mark 单例
static HGBDistanceSensorTool *instance=nil;
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBDistanceSensorTool alloc]init];
    }
    return instance;
}

#pragma mark 功能
/**
 开始监测距离
 */
-(void)startMonitorDistance{

    if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        HGBLog(@"模拟器无距离传感器设备");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(distance:didFailedWithError:)]){
            [self.delegate distance:self  didFailedWithError:@{ReslutCode:@(HGBDistanceSensorToolErrorTypeDevice).stringValue,ReslutMessage:@"模拟器无距离传感器设备"}];
        }
        return;

    }
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    

    // 通过通知监听有物品靠近还是离开
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateDidChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];

}
/**
 结束监测距离
 */
-(void)stopMonitorDistance{
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)proximityStateDidChange:(NSNotification *)_n{
    if ([UIDevice currentDevice].proximityState) {
        HGBLog(@"有东西靠近");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(distance:didUpdatedWithProximityState:andWithDistanceInfo:)]){
            [self.delegate distance:self didUpdatedWithProximityState:YES andWithDistanceInfo:@{@"status":@(1),@"description":@"有东西靠近"}];
        }
    } else {
        HGBLog(@"有物体离开");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(distance:didUpdatedWithProximityState:andWithDistanceInfo:)]){
            [self.delegate distance:self didUpdatedWithProximityState:NO andWithDistanceInfo:@{@"status":@(0),@"description":@"有东西离开"}];
        }

    }
}
@end

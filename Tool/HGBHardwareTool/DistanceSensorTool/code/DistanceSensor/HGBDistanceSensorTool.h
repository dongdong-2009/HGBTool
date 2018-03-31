//
//  HGBDistanceSensorTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/16.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif



/**
 错误类型
 */
typedef enum HGBDistanceSensorToolErrorType
{
    HGBDistanceSensorToolErrorTypeAuthority=11,//权限受限
    HGBDistanceSensorToolErrorTypeDevice=10//设备受限

}HGBDistanceSensorToolErrorType;

@class HGBDistanceSensorTool;



@protocol HGBDistanceSensorToolDelegate<NSObject>
@optional
/**
 距离工具更新

 @param distance 距离工具
 @param proximity  物体靠近或远离
 @param distanceInfo  物体位置信息
 */
- (void)distance:(HGBDistanceSensorTool*)distance  didUpdatedWithProximityState:(BOOL)proximity andWithDistanceInfo:(NSDictionary *)distanceInfo;
/**
 距离工具错误

 @param distance 距离工具
 @param errorInfo 错误信息
 */
- (void)distance:(HGBDistanceSensorTool *)distance didFailedWithError:(NSDictionary *)errorInfo;

@end

@interface HGBDistanceSensorTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBDistanceSensorToolDelegate>delegate;
#pragma mark 单例
+ (instancetype)shareInstance;

/**
 开始监测距离
 */
-(void)startMonitorDistance;
/**
 结束监测距离
 */
-(void)stopMonitorDistance;
@end

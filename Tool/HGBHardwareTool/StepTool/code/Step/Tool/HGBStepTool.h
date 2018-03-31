//
//  HGBStepTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/17.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif
/**
 结果

 @param status 状态
 @param returnMessage 信息
 */
typedef void (^HGBStepReslutBlock)(BOOL status,NSDictionary *returnMessage);

/**
 错误类型
 */
typedef enum HGBStepToolErrorType
{
    HGBStepToolErrorTypeDevice=10,//设备受限
    HGBStepToolErrorTypeAuthorized=11,//权限
    HGBStepToolErrorTypeOther=99//其他

}HGBStepToolErrorType;

@interface HGBStepTool : NSObject
/**
 数据更新时间
 */
@property(assign,nonatomic)CGFloat timeInterval;
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance;
#pragma mark 计步
/**
 开启监听计步器

 @param reslut 结果
 */
-(void)startMonitortStepWithReslut:(HGBStepReslutBlock)reslut;

/**
 结束监听计步器

 @param reslut 结果
 */
-(void)stopMonitorStepWithReslut:(HGBStepReslutBlock)reslut;

#pragma mark 运动状态
/**
 开启监听运动状态

 @param reslut 结果 status:状态 speed 速度
  */
-(void)startMonitorActivityStatuspWithReslut:(HGBStepReslutBlock)reslut;

/**
 结束监听运动状态

 @param reslut 结果
 */
-(void)stopMonitorpActivityStatusWithReslut:(HGBStepReslutBlock)reslut;

#pragma mark 获取健康计步数据
/**
 获取健康计步数据

 @param startDate 开始日期
 @param endDate 结束日期
 @param reslut 结果 numberOfSteps：步数 distance:距离  floorsAscended:上楼 floorsDescended:下楼
 */
-(void)queryStepDataFromDate:(NSDate *)startDate toDate:(NSDate *)endDate andWithReslut:(HGBStepReslutBlock)reslut;

/**
 获取健康计步数据

 @param startDate 开始日期
 @param reslut 结果  numberOfSteps：步数 distance:距离  floorsAscended:上楼 floorsDescended:下楼
 */
-(void)queryStepDataFromDate:(NSDate *)startDate andWithReslut:(HGBStepReslutBlock)reslut;
@end

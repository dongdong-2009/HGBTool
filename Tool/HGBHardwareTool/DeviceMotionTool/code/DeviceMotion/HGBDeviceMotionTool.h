//
//  HGBDeviceMotionTool.h
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
 错误类型
 */
typedef enum  HGBDeviceMotionToolErrorType
{
    HGBDeviceMotionToolErrorTypeDevice=10,//设备受限
    HGBDeviceMotionToolErrorTypeAuthorized=11,//权限
    HGBDeviceMotionToolErrorTypeOther=99//其他

}HGBDeviceMotionToolErrorType;
/**
 结果

 @param status 状态
 @param returnMessage 信息
 */
typedef void (^HGBDeviceMotionReslutBlock)(BOOL status,NSDictionary *returnMessage);

@interface HGBDeviceMotionTool : NSObject
/**
 数据更新时间
 */
@property(assign,nonatomic)CGFloat timeInterval;

/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance;

/**
 获取手机运动监听

 @param reslut 结果
 */
-(void)startDeviceMotionWithReslut:(HGBDeviceMotionReslutBlock)reslut;
/**
 结束手机运动监听

 @param reslut 结果
 */
-(void)stoptDeviceMotionWithReslut:(HGBDeviceMotionReslutBlock)reslut;
@end

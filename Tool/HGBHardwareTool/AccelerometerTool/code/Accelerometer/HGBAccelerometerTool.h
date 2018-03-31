//
//  HGBAccelerometerTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/11/14.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
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
typedef enum  HGBAccelerometerToolErrorType
{
     HGBAccelerometerToolErrorTypeDevice=10,//设备受限
     HGBAccelerometerToolErrorTypeAuthorized=11,//权限
     HGBAccelerometerToolErrorTypeOther=99//其他

}HGBAccelerometerToolErrorType;


/**
 结果

 @param status 状态
 @param returnMessage 信息
 */
typedef void (^HGBAccelerometerReslutBlock)(BOOL status,NSDictionary *returnMessage);



@interface HGBAccelerometerTool : NSObject
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
 获取加速度监听

 @param reslut 结果
 */
-(void)startAccelerometerWithReslut:(HGBAccelerometerReslutBlock)reslut;
/**
 结束加速度监听

 @param reslut 结果
 */
-(void)stopAccelerometerWithReslut:(HGBAccelerometerReslutBlock)reslut;
@end

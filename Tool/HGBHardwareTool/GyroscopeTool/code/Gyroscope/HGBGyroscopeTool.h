//
//  HGBGyroscopeTool.h
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
typedef void (^HGBGyroscopeReslutBlock)(BOOL status,NSDictionary *returnMessage);

/**
 错误类型
 */
typedef enum  HGBGyroscopeToolErrorType
{
    HGBGyroscopeToolErrorTypeDevice=10,//设备受限
    HGBGyroscopeToolErrorTypeAuthorized=11,//权限
    HGBGyroscopeToolErrorTypeOther=99//其他

}HGBGyroscopeToolErrorType;

@interface HGBGyroscopeTool : NSObject
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
 获取陀螺仪监听

 @param reslut 结果
 */
-(void)startGyroscoperWithReslut:(HGBGyroscopeReslutBlock)reslut;
/**
 结束陀螺仪监听

 @param reslut 结果
 */
-(void)stoptGyroscoperWithReslut:(HGBGyroscopeReslutBlock)reslut;
@end

//
//  HGBGyroscopeTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/17.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBGyroscopeTool.h"
#import <CoreMotion/CoreMotion.h>




#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"




#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



@interface HGBGyroscopeTool()
/**
陀螺仪
 */
@property(strong,nonatomic)CMMotionManager *motionManager;

@end

@implementation HGBGyroscopeTool
#pragma mark 单例
static HGBGyroscopeTool *instance=nil;
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if(instance==nil){
        instance=[[HGBGyroscopeTool alloc]init];
        instance.motionManager = [[CMMotionManager alloc]init];
    }
    return instance;
}
#pragma mark 功能
/**
 获取陀螺仪监听

 @param reslut 结果
 */
-(void)startGyroscoperWithReslut:(HGBGyroscopeReslutBlock)reslut{
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    if (!self.motionManager.isGyroAvailable) {
        HGBLog(@"陀螺仪不可用");
        if (reslut) {
             reslut(NO,@{ReslutCode:@(HGBGyroscopeToolErrorTypeDevice).stringValue,ReslutMessage:@"陀螺仪不可用"});
        }
        return;
    }
    if (self.motionManager.isGyroActive) {
        HGBLog(@"陀螺仪已开启");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBGyroscopeToolErrorTypeDevice).stringValue,ReslutMessage:@"陀螺仪已开启"});
        }
        return;
    }
    if(self.timeInterval==0){
        self.motionManager.gyroUpdateInterval = 0.01;
    }else{
         self.motionManager.gyroUpdateInterval = self.timeInterval;
    }


    @try
    {
        /*
         1.push方式
         这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动获取加速计的数据。
         */
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            if (!self.motionManager.isGyroActive) {
                HGBLog(@"陀螺仪未开启");
                if (reslut) {
                    reslut(NO,@{ReslutCode:@(HGBGyroscopeToolErrorTypeDevice).stringValue,ReslutMessage:@"陀螺仪未开启"});
                }
                return;
            }

            //三个方向加速度值
            double x = gyroData.rotationRate.x;
            double y = gyroData.rotationRate.y;
            double z = gyroData.rotationRate.z;
            //g是一个double值 ,根据它的大小来判断是否计为1步.
            double g = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) - 1;

            //将信息保存
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];


            //日期

            [dic setObject:@(x).stringValue forKey:@"gravity_X"];
            [dic setObject:@(y).stringValue forKey:@"gravity_Y"];
            [dic setObject:@(z).stringValue forKey:@"gravity_Z"];
            [dic setObject:@(g).stringValue forKey:@"gravity_G"];
            if (reslut) {
                reslut(YES,dic);
            }
        }];
    }@catch (NSException * e) {
        HGBLog(@"Exception: %@", e);
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBGyroscopeToolErrorTypeOther).stringValue,ReslutMessage:e.name});
        }
        return;
    }
}
/**
 结束陀螺仪监听

 @param reslut 结果
 */
-(void)stoptGyroscoperWithReslut:(HGBGyroscopeReslutBlock)reslut{
    if(self.motionManager){
         [self.motionManager stopGyroUpdates];
        if (!(self.motionManager.isGyroAvailable)) {
            HGBLog(@"陀螺仪不可用");
            if (reslut) {
                reslut(NO,@{ReslutCode:@(HGBGyroscopeToolErrorTypeDevice).stringValue,ReslutMessage:@"陀螺仪不可用"});
            }
            return;
        }else{
            [self.motionManager stopGyroUpdates];
            [UIDevice currentDevice].proximityMonitoringEnabled = NO;
            if (reslut) {
                reslut(YES,@{ReslutCode:@(1).stringValue,ReslutMessage:@"关闭成功"});
            }
            instance=nil;
        }
    }else{
        HGBLog(@"未开启");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBGyroscopeToolErrorTypeOther).stringValue,ReslutMessage:@"未开启"});
        }
        return;
    }
}
@end

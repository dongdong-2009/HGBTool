//
//  HGBAccelerometerTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/11/14.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBAccelerometerTool.h"
#import <CoreMotion/CoreMotion.h>




#pragma mark 系统版本




#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"




#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBAccelerometerTool()<UIAccelerometerDelegate>

/**
 加速度传感器
 */
@property(strong,nonatomic)CMMotionManager *motionManager;

@end

@implementation HGBAccelerometerTool
#pragma mark 单例
static HGBAccelerometerTool *instance=nil;
/**
单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if(instance==nil){
        instance=[[HGBAccelerometerTool alloc]init];
        instance.motionManager = [[CMMotionManager alloc]init];
    }
    return instance;
}
#pragma mark 功能

/**
 获取加速度监听

 @param reslut 结果
 */
-(void)startAccelerometerWithReslut:(HGBAccelerometerReslutBlock)reslut{
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    if (!self.motionManager.isAccelerometerAvailable) {
        HGBLog(@"加速度传感器不可用");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBAccelerometerToolErrorTypeDevice).stringValue,ReslutMessage:@"加速度传感器不可用"});
        }
        return;
    }
    if (self.motionManager.isAccelerometerActive) {
        HGBLog(@"加速度传感器已开启");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBAccelerometerToolErrorTypeDevice).stringValue,ReslutMessage:@"加速度传感器已开启"});
        }
        return;
    }


    if(self.timeInterval==0){
        self.motionManager.accelerometerUpdateInterval=0.01;
    }else{
        self.motionManager.accelerometerUpdateInterval = self.timeInterval;
    }

    @try
    {
        /*
         1.push方式
         这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动获取加速计的数据。
         */
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
            if (!self.motionManager.isAccelerometerActive) {
                HGBLog(@"加速度传感器未开启");
                if (reslut) {
                    reslut(NO,@{ReslutCode:@(HGBAccelerometerToolErrorTypeDevice).stringValue,ReslutMessage:@"加速度传感器未开启"});
                }
                return;
            }


            //三个方向加速度值
            double x = accelerometerData.acceleration.x;
            double y = accelerometerData.acceleration.y;
            double z = accelerometerData.acceleration.z;
            //g是一个double值 ,根据它的大小来判断是否计为1步.
            double g = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) - 1;

            //将信息保存
              NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    
            [dic setObject:@(x).stringValue forKey:@"accelerometer_X"];
            [dic setObject:@(y).stringValue forKey:@"accelerometer_Y"];
            [dic setObject:@(z).stringValue forKey:@"accelerometer_X"];
            [dic setObject:@(g).stringValue forKey:@"accelerometer_G"];
            if (reslut) {
                reslut(YES,dic);
            }


        }];
    }@catch (NSException * e) {
        HGBLog(@"Exception: %@", e);
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBAccelerometerToolErrorTypeOther).stringValue,ReslutMessage:e.name});
        }
        return;
    }
}
/**
 结束加速度监听

 @param reslut 结果
 */
-(void)stopAccelerometerWithReslut:(HGBAccelerometerReslutBlock)reslut{

    if(self.motionManager){
         [self.motionManager stopAccelerometerUpdates];
        if (!(self.motionManager.isAccelerometerAvailable)) {
            HGBLog(@"加速度传感器不可用");
            if (reslut) {
                reslut(NO,@{ReslutCode:@(HGBAccelerometerToolErrorTypeDevice).stringValue,ReslutMessage:@"加速度传感器不可用"});
            }
            return;
        }else {
            [UIDevice currentDevice].proximityMonitoringEnabled = NO;
            [self.motionManager stopAccelerometerUpdates];
            reslut(YES,@{ReslutCode:@(1).stringValue,ReslutMessage:@"关闭成功"});

        }
    }else{
        HGBLog(@"未开启");
        if (reslut) {
             reslut(NO,@{ReslutCode:@(HGBAccelerometerToolErrorTypeOther).stringValue,ReslutMessage:@"未开启"});
        }
        return;
    }
}

@end

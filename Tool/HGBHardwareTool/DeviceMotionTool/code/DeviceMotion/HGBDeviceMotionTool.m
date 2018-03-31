//
//  HGBDeviceMotionTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/17.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBDeviceMotionTool.h"
#import <CoreMotion/CoreMotion.h>



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



@interface HGBDeviceMotionTool()
/**
 水平监控
 */
@property(strong,nonatomic)CMMotionManager *motionManager;

@end

@implementation HGBDeviceMotionTool
static HGBDeviceMotionTool *instance=nil;
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if(instance==nil){
        instance=[[HGBDeviceMotionTool alloc]init];
        instance.motionManager = [[CMMotionManager alloc]init];
    }
    return instance;
}

#pragma mark 功能
/**
 获取手机运动监听

 @param reslut 结果
 */
-(void)startDeviceMotionWithReslut:(HGBDeviceMotionReslutBlock)reslut{
     [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    if (!self.motionManager.isDeviceMotionAvailable) {
        HGBLog(@"手机运动监听不可用");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBDeviceMotionToolErrorTypeDevice).stringValue,ReslutMessage:@"手机运动监听不可用"});
        }
        return;
    }
    if (self.motionManager.isDeviceMotionActive) {
        HGBLog(@"手机运动已开启");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBDeviceMotionToolErrorTypeDevice).stringValue,ReslutMessage:@"手机运动监听已开启"});
        }

        return;
    }
    if(self.timeInterval==0){
        self.motionManager.deviceMotionUpdateInterval=0.01;
    }else{
        self.motionManager.deviceMotionUpdateInterval = self.timeInterval;
    }


    @try
    {
        /*
         1.push方式
         这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动获取加速计的数据。
         */
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (!self.motionManager.isDeviceMotionActive) {
                HGBLog(@"手机运动监听未开启");
                if (reslut) {
                    reslut(NO,@{ReslutCode:@(HGBDeviceMotionToolErrorTypeDevice).stringValue,ReslutMessage:@"手机运动监听未开启"});
                }

                return;
            }

            //三个方向加速度值
            double x = motion.userAcceleration.x;
            double y = motion.userAcceleration.y;
            double z = motion.userAcceleration.z;
            //g是一个double值 ,根据它的大小来判断是否计为1步.
            double g = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) - 1;


            double x2 = motion.gravity.x;
            double y2 = motion.gravity.y;
            double z2 = motion.gravity.z;
            //g是一个double值 ,根据它的大小来判断是否计为1步.
            double g2 = sqrt(pow(x2, 2) + pow(y2, 2) + pow(z2, 2)) - 1;


            double x3 = motion.rotationRate.x;
            double y3 = motion.rotationRate.y;
            double z3 = motion.rotationRate.z;
            //g是一个double值 ,根据它的大小来判断是否计为1步.
            double g3 = sqrt(pow(x3, 2) + pow(y3, 2) + pow(z3, 2)) - 1;

            //将信息保存
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];

            [dic setObject:@(x).stringValue forKey:@"accelerometer_X"];
            [dic setObject:@(y).stringValue forKey:@"accelerometer_Y"];
            [dic setObject:@(z).stringValue forKey:@"accelerometer_X"];
            [dic setObject:@(g).stringValue forKey:@"accelerometer_G"];

            [dic setObject:@(x2).stringValue forKey:@"gravity_X"];
            [dic setObject:@(y2).stringValue forKey:@"gravity_Y"];
            [dic setObject:@(z2).stringValue forKey:@"gravity_Z"];
            [dic setObject:@(g2).stringValue forKey:@"gravity_G"];

            [dic setObject:@(x3).stringValue forKey:@"rotation_X"];
            [dic setObject:@(y3).stringValue forKey:@"rotation_Y"];
            [dic setObject:@(z3).stringValue forKey:@"rotation_Z"];
            [dic setObject:@(g3).stringValue forKey:@"rotation_G"];
            if (reslut) {
                 reslut(YES,dic);
            }
        }];
    }@catch (NSException * e) {
        HGBLog(@"Exception: %@", e);
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBDeviceMotionToolErrorTypeOther).stringValue,ReslutMessage:e.name});
        }

        return;
    }

}
/**
 结束手机运动监听

 @param reslut 结果
 */
-(void)stoptDeviceMotionWithReslut:(HGBDeviceMotionReslutBlock)reslut{
    if(self.motionManager){
        if (!(self.motionManager.isDeviceMotionAvailable)) {
            HGBLog(@"手机运动监听不可用");
            if (reslut) {
                reslut(NO,@{ReslutCode:@(HGBDeviceMotionToolErrorTypeDevice).stringValue,ReslutMessage:@"手机运动监听不可用"});
            }

            return;
        }else {
            [self.motionManager startDeviceMotionUpdates];
             [UIDevice currentDevice].proximityMonitoringEnabled = NO;
            if (reslut) {
                reslut(YES,@{ReslutCode:@(1).stringValue,ReslutMessage:@"关闭成功"});
            }

        }
    }else{
        HGBLog(@"未开启");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBDeviceMotionToolErrorTypeOther).stringValue,ReslutMessage:@"未开启"});
        }

        return;
    }
}
@end

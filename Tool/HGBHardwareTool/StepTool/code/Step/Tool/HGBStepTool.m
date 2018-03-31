//
//  HGBStepTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/17.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBStepTool.h"
#import <CoreMotion/CoreMotion.h>
#import "HGBStepMoel.h"

#import <HealthKit/HealthKit.h>

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"




#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



// 计步器开始计步时间（秒）
#define ACCELERO_START_TIME 2

// 计步器开始计步步数（步）
#define ACCELERO_START_STEP 1

// 数据库存储步数采集间隔（步）
#define DB_STEP_INTERVAL 1


@interface HGBStepTool(){


    NSMutableArray *arrAll;                 // 加速度传感器采集的原始数组
    int record_no_save;
    int record_no;
    NSDate *lastDate;
}
//@property (nonatomic,strong)NSMutableArray *arrAll;                 // 加速度传感器采集的原始数组
//@property (nonatomic,assign)int record_no_save;
//@property (nonatomic,assign)int record_no;
//@property (nonatomic,strong)NSDate *lastDate;
@property (nonatomic,assign) NSInteger startStep;                          // 计步器开始步数

@property (nonatomic, retain) NSMutableArray *arrSteps;         // 步数数组
@property (nonatomic, retain) NSMutableArray *arrStepsSave;     // 数据库纪录步数数组

@property (nonatomic,assign) CGFloat gpsDistance;                  // GPS轨迹的移动距离（总计）
@property (nonatomic,assign) CGFloat agoGpsDistance;               // GPS轨迹的移动距离（之前）
@property (nonatomic,assign) CGFloat agoActionDistance;            // 实际运动的移动距离（之前）

@property (nonatomic, retain) NSString *actionId;           // 运动识别ID
@property (nonatomic,assign) CGFloat distance;                     // 运动里程（总计）
@property (nonatomic,assign) NSInteger calorie;                    // 消耗卡路里（总计）
@property (nonatomic,assign) NSInteger second;                     // 运动用时（总计）
@property (nonatomic) NSInteger step;                       // 运动步数（总计）



/**
 陀螺仪
 */
@property(strong,nonatomic)CMMotionManager *motionManager;
/**
 计步器
 */
@property (nonatomic, strong) CMPedometer *stepCounter;
/**
 运动
 */
@property (nonatomic, strong) CMMotionActivityManager *activityManager;
/**
 计时器
 */
@property (nonatomic, strong)NSTimer *timer;

/**
 数据更新
 */
@property(assign,nonatomic)BOOL sendFlag;
@end
@implementation HGBStepTool
#pragma mark 单例
static HGBStepTool *instance=nil;
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if(instance==nil){
        instance=[[HGBStepTool alloc]init];
        instance.motionManager = [[CMMotionManager alloc]init];
         instance.stepCounter = [[CMPedometer alloc] init];
         instance.activityManager = [[CMMotionActivityManager alloc] init];
    }
    return instance;
}

#pragma mark 计步

/**
 开启监听计步器

 @param reslut 结果
 */
-(void)startMonitortStepWithReslut:(HGBStepReslutBlock)reslut{
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;

    if (!self.motionManager.isAccelerometerAvailable) {
        HGBLog(@"加速度传感器不可用");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeDevice).stringValue,ReslutMessage:@"加速度传感器不可用"});
        }
        return;
    }
    self.motionManager.accelerometerUpdateInterval=0.01;
    @try
    {
        //如果不支持陀螺仪,需要用加速传感器来采集数据
        if (arrAll == nil) {
            arrAll = [[NSMutableArray alloc] init];
        }
        else {
            [arrAll removeAllObjects];
        }

        /*
         1.push方式
         这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动获取加速计的数据。
         */
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        int n;
        if(self.timeInterval==0){
           
        }else{
            n=self.timeInterval/0.01;
            if(n<1){
                n=1;
            }
        }
        __block int i=0;

        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){

            if (!self.motionManager.isAccelerometerActive) {
                return;
            }

            //三个方向加速度值
            double x = accelerometerData.acceleration.x;
            double y = accelerometerData.acceleration.y;
            double z = accelerometerData.acceleration.z;
            //g是一个double值 ,根据它的大小来判断是否计为1步.
            double g = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) - 1;

            //将信息保存在步数模型中
            HGBStepMoel *stepsAll = [[HGBStepMoel alloc] init];

            stepsAll.date = [NSDate date];

            //日期
            NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
            df.dateFormat  = @"yyyy-MM-dd HH:mm:ss";
            NSString *strYmd = [df stringFromDate:stepsAll.date];
            df = nil;
            stepsAll.record_time =strYmd;

            stepsAll.g = g;
            // 加速度传感器采集的原始数组
            [arrAll addObject:stepsAll];

            // 每采集10条，大约1.2秒的数据时，进行分析
            if (arrAll.count == 10) {

                // 步数缓存数组
                NSMutableArray *arrBuffer = [[NSMutableArray alloc] init];

                arrBuffer = [arrAll copy];
                [arrAll removeAllObjects];

                // 踩点数组
                NSMutableArray *arrCaiDian = [[NSMutableArray alloc] init];

                //遍历步数缓存数组
                for (int i = 1; i < arrBuffer.count - 2; i++) {
                    //如果数组个数大于3,继续,否则跳出循环,用连续的三个点,要判断其振幅是否一样,如果一样,然并卵
                    if (![arrBuffer objectAtIndex:i-1] || ![arrBuffer objectAtIndex:i] || ![arrBuffer objectAtIndex:i+1])
                    {
                        continue;
                    }
                    HGBStepMoel *bufferPrevious = (HGBStepMoel *)[arrBuffer objectAtIndex:i-1];
                    HGBStepMoel *bufferCurrent = (HGBStepMoel *)[arrBuffer objectAtIndex:i];
                    HGBStepMoel *bufferNext = (HGBStepMoel *)[arrBuffer objectAtIndex:i+1];
                    //控制震动幅度,,,,,,根据震动幅度让其加入踩点数组,
                    if (bufferCurrent.g < -0.12 && bufferCurrent.g < bufferPrevious.g && bufferCurrent.g < bufferNext.g) {
                        [arrCaiDian addObject:bufferCurrent];
                    }
                }

                //如果没有步数数组,初始化
                if (nil == self.arrSteps) {
                    self.arrSteps = [[NSMutableArray alloc] init];
                    self.arrStepsSave = [[NSMutableArray alloc] init];
                }

                // 踩点过滤
                for (int j = 0; j < arrCaiDian.count; j++) {
                    HGBStepMoel *caidianCurrent = (HGBStepMoel *)[arrCaiDian objectAtIndex:j];

                    //如果之前的步数为0,则重新开始记录
                    if (self.arrSteps.count == 0) {
                        //上次记录的时间
                        lastDate = caidianCurrent.date;

                        // 重新开始时，纪录No初始化
                        record_no = 1;
                        record_no_save = 1;

                        // 运动识别号
                        NSTimeInterval interval = [caidianCurrent.date timeIntervalSince1970];
                        NSNumber *numInter = [[NSNumber alloc] initWithDouble:interval*1000];
                        long long llInter = numInter.longLongValue;
                        //运动识别id
                        self.actionId = [NSString stringWithFormat:@"%lld",llInter];

                        self.distance = 0.00f;
                        self.second = 0;
                        self.calorie = 0;
                        self.step = 0;

                        self.gpsDistance = 0.00f;
                        self.agoGpsDistance = 0.00f;
                        self.agoActionDistance = 0.00f;

                        caidianCurrent.record_no = record_no;
                        caidianCurrent.step = (int)self.step;

                        [self.arrSteps addObject:caidianCurrent];
                        [self.arrStepsSave addObject:caidianCurrent];

                    }
                    else {

                        int intervalCaidian = [caidianCurrent.date timeIntervalSinceDate:lastDate] * 1000;

                        // 步行最大每秒2.5步，跑步最大每秒3.5步，超过此范围，数据有可能丢失
                        int min = 259;
                        if (intervalCaidian >= min) {

                            if (self.motionManager.isAccelerometerActive) {

                                //存一下时间
                                lastDate = caidianCurrent.date;

                                if (intervalCaidian >= ACCELERO_START_TIME * 1000) {// 计步器开始计步时间（秒)
                                    self.startStep = 0;
                                }

                                if (self.startStep < ACCELERO_START_STEP) {//计步器开始计步步数 (步)

                                    self.startStep ++;
                                    break;
                                }
                                else if (self.startStep == ACCELERO_START_STEP) {
                                    self.startStep ++;
                                    // 计步器开始步数
                                    // 运动步数（总计）
                                    self.step = self.step + self.startStep;
                                }
                                else {
                                    self.step ++;
                                }



                                //步数在这里
                                HGBLog(@"步数%ld",self.step);

                                int intervalMillSecond = [caidianCurrent.date timeIntervalSinceDate:[[self.arrSteps lastObject] date]] * 1000;
                                if (intervalMillSecond >= 1000) {

                                    record_no++;

                                    caidianCurrent.record_no = record_no;

                                    caidianCurrent.step = (int)self.step;
                                    [self.arrSteps addObject:caidianCurrent];
                                }

                                // 每隔100步保存一条数据（将来插入DB用）
                                HGBStepMoel *arrStepsSaveVHSSteps = (HGBStepMoel *)[self.arrStepsSave lastObject];
                                int intervalStep = caidianCurrent.step - arrStepsSaveVHSSteps.step;

                                // DB_STEP_INTERVAL 数据库存储步数采集间隔（步） 100步
                                if (self.arrStepsSave.count == 1 || intervalStep >= DB_STEP_INTERVAL) {
                                    //保存次数
                                    record_no_save++;
                                    caidianCurrent.record_no = record_no_save;
                                    [self.arrStepsSave addObject:caidianCurrent];

                                    HGBLog(@"---***%ld",self.step);
                                    // 备份当前运动数据至文件中，以备APP异常退出时数据也不会丢失
                                    // [self bkRunningData];

                                }
                            }
                        }

                        // 运动提醒检查
                        // [self checkActionAlarm];
                    }
                }
            }
            if(self.timeInterval==0){
                if (reslut) {
                     reslut(YES,@{@"numberOfSteps":@(self.step).stringValue});
                }
            }else{
                if(i==n){
                    if (reslut) {
                         reslut(YES,@{@"numberOfSteps":@(self.step).stringValue});
                    }
                    i=0;
                }
                i++;
            }


        }];



    }@catch (NSException * e) {
        HGBLog(@"Exception: %@", e);
        if (reslut) {
             reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeOther).stringValue,ReslutMessage:e.name});
        }
        return;
        return;
    }
}
/**
 结束监听计步器

 @param reslut 结果
 */
-(void)stopMonitorStepWithReslut:(HGBStepReslutBlock)reslut{
    if(self.motionManager){
        [self.motionManager stopAccelerometerUpdates];
        if (!(self.motionManager.isAccelerometerAvailable)) {
            HGBLog(@"加速度传感器不可用");
            if (reslut) {
                reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeDevice).stringValue,ReslutMessage:@"加速度传感器不可用"});
            }
            return;
        }else {
            [UIDevice currentDevice].proximityMonitoringEnabled = NO;
            [self.motionManager stopAccelerometerUpdates];

            if (reslut) {
                 reslut(YES,@{ReslutCode:@(1).stringValue,ReslutMessage:@"关闭成功"});
            }
             instance=nil;

        }

    }else{
        HGBLog(@"未开启");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeOther).stringValue,ReslutMessage:@"未开启"});
        }
        return;
    }



}

#pragma mark 运动状态
/**
 开启监听运动状态

 @param reslut 结果 status:状态 speed 速度
 */
-(void)startMonitorActivityStatuspWithReslut:(HGBStepReslutBlock)reslut{


    [self.activityManager stopActivityUpdates];
    if ([CMMotionActivityManager isActivityAvailable]) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        if(self.timer){
            [self.timer invalidate];
        }
        self.sendFlag=YES;
     __block BOOL flag=YES;
     self.timer=[NSTimer scheduledTimerWithTimeInterval:self.timeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
            flag=YES;
        }];
     [self.activityManager startActivityUpdatesToQueue:queue
                                              withHandler:
         ^(CMMotionActivity *activity) {

             if(flag&&self.sendFlag){
                 flag=NO;
                 NSString *status = [HGBStepTool statusForActivity:activity];
                 NSString *confidence = [HGBStepTool stringFromConfidence:activity.confidence];
                 NSDictionary *dic=@{@"status":status,@"speed":confidence};
                 if (reslut) {
                     reslut(YES,dic);
                 }
             }
         }];
    }else{
        HGBLog(@"无法获取");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeOther).stringValue,ReslutMessage:@"无法获取"});
        }
        return;
    }

}


/**
 结束监听运动状态

 @param reslut 结果
 */
-(void)stopMonitorpActivityStatusWithReslut:(HGBStepReslutBlock)reslut{
//    if (![CMMotionActivityManager isActivityAvailable]) {
//        HGBLog(@"无法获取");
//        reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeAuthorized).stringValue,ReslutMessage:@"无法获取"});
//        return;
//    }

    if (reslut) {
         reslut(YES,@{ReslutCode:@(1).stringValue,ReslutMessage:@"关闭成功"});
    }
    [self.activityManager stopActivityUpdates];
    if(self.timer){
        [self.timer invalidate];
    }
    self.sendFlag=NO;
    instance=nil;

}
/**
 速度状态

 @param activity 运动状态
 @return 状态
 */
+ (NSString *)statusForActivity:(CMMotionActivity *)activity {

    NSMutableString *status = @"".mutableCopy;

    if (activity.stationary) {

        [status appendString:@"not moving"];
    }

    if (activity.walking) {

        if (status.length) [status appendString:@", "];

        [status appendString:@"on a walking person"];
    }

    if (activity.running) {

        if (status.length) [status appendString:@", "];

        [status appendString:@"on a running person"];
    }

    if (activity.automotive) {

        if (status.length) [status appendString:@", "];

        [status appendString:@"in a vehicle"];
    }

    if (activity.unknown || !status.length) {

        [status appendString:@"unknown"];
    }

    return status;
}

/**
 速度

 @param confidence 运动状态
 @return 速度
 */
+ (NSString *)stringFromConfidence:(CMMotionActivityConfidence)confidence {

    switch (confidence) {

        case CMMotionActivityConfidenceLow:

            return @"Low";

        case CMMotionActivityConfidenceMedium:

            return @"Medium";

        case CMMotionActivityConfidenceHigh:

            return @"High";

        default:

            return nil;
    }
}
#pragma mark 获取健康计步数据

/**
 获取健康计步数据

 @param startDate 开始日期
 @param reslut 结果 numberOfSteps：步数 distance:距离  floorsAscended:上楼 floorsDescended:下楼
 */
-(void)queryStepDataFromDate:(NSDate *)startDate andWithReslut:(HGBStepReslutBlock)reslut{
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    // 1.判断计步器是否可用
    if (![CMPedometer isStepCountingAvailable] && ![CMPedometer isDistanceAvailable]) {
        HGBLog(@"记步功能不可用");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeDevice).stringValue,ReslutMessage:@"记步功能不可用"});
        }
        return;
    }

    if(startDate==nil){
        HGBLog(@"参数错误");
        if (reslut) {
             reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeDevice).stringValue,ReslutMessage:@"参数错误"});
        }
        return;
    }

    [self.stepCounter startPedometerUpdatesFromDate:startDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        if (error) {
            if (reslut) {
                reslut(NO,@{ReslutCode:@(error.code).stringValue,ReslutMessage:error.localizedDescription});
            }
            HGBLog(@"%@", error);
            return;
        }
        NSDictionary *dic=@{@"numberOfSteps":[NSString stringWithFormat:@"%@",pedometerData.numberOfSteps],@"distance":[NSString stringWithFormat:@"%@",pedometerData.distance],@"floorsAscended":[NSString stringWithFormat:@"%@",pedometerData.floorsAscended],@"floorsDescended":[NSString stringWithFormat:@"%@",pedometerData.floorsDescended]};
        if (reslut) {
            reslut(YES,dic);
        }
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        instance=nil;
    }];

}

/**
 获取健康计步数据

 @param startDate 开始日期
 @param endDate 结束日期
 @param reslut 结果 numberOfSteps：步数 distance:距离  floorsAscended:上楼 floorsDescended:下楼
 */
-(void)queryStepDataFromDate:(NSDate *)startDate toDate:(NSDate *)endDate andWithReslut:(HGBStepReslutBlock)reslut{
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    // 1.判断计步器是否可用
    if (![CMPedometer isStepCountingAvailable] && ![CMPedometer isDistanceAvailable]) {
        HGBLog(@"记步功能不可用");
        if (reslut) {
           reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeDevice).stringValue,ReslutMessage:@"记步功能不可用"});
        }
        return;
    }
    if(startDate==nil||endDate==nil){
        HGBLog(@"参数错误");
        if (reslut) {
            reslut(NO,@{ReslutCode:@(HGBStepToolErrorTypeDevice).stringValue,ReslutMessage:@"参数错误"});
        }
        return;
    }


    [self.stepCounter queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        if (error) {
            if (reslut) {
                reslut(NO,@{ReslutCode:@(error.code).stringValue,ReslutMessage:error.localizedDescription});
            }
            HGBLog(@"%@", error);
            return;
        }
       NSDictionary *dic=@{@"numberOfSteps":[NSString stringWithFormat:@"%@",pedometerData.numberOfSteps],@"distance":[NSString stringWithFormat:@"%@",pedometerData.distance],@"floorsAscended":[NSString stringWithFormat:@"%@",pedometerData.floorsAscended],@"floorsDescended":[NSString stringWithFormat:@"%@",pedometerData.floorsDescended]};
        if (reslut) {
            reslut(YES,dic);
        }
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        instance=nil;
    }];
}

#pragma mark --set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"健康访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"去设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if([[UIApplication sharedApplication] canOpenURL:url]) {

            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];

        }

    }];
    [alert addAction:action2];
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}
#pragma mark 权限判断
- (void)isCanUseHeathlyWithBolck:(void(^)(BOOL isCanGet))returnBolck
{

}

#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
- (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}
/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
- (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
@end

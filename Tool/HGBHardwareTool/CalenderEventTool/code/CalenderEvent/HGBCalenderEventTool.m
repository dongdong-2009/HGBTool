//
//  HGBCalenderEventTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/22.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBCalenderEventTool.h"


#import <UIKit/UIKit.h>


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBCalenderEventTool
static HGBCalenderEventTool *calendar;

+ (instancetype)sharedInstance{

    if(calendar==nil){
        calendar = [[HGBCalenderEventTool alloc] init];
    }
    return calendar;
}

+(EKEventStore *)shareStoreinstance{
    static dispatch_once_t once = 0;
    static EKEventStore *store;
    dispatch_once(&once, ^{ store = [[EKEventStore alloc] init]; });
    return store;
}

/**
 获取日历事件

 @param startDate 开始日期
 @param enDate 结束日期
 @return 结果
 */
+(NSArray *)fetchEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)enDate{
    [HGBCalenderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
        if (!isCanUseEvent) {

            [self jumpToSet];
        }
    }];
    EKEventStore *store = [HGBCalenderEventTool shareStoreinstance];
    NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate
                                                            endDate:enDate
                                                          calendars:nil];
    NSArray *events = [store eventsMatchingPredicate:predicate];
    NSInteger i = 1;
    for (EKEvent *event in events) {
        HGBLog(@"第 %zd 个提醒 %@",i,event);
        i++;
    }
    return events;
}
/** 用唯一标示查询一个事件(只能查询日历里面的事件)
 * eventidentifer 唯一标示
 */
+(EKEvent *)fetchEventWithIdentifer:(NSString *)eventidentifer{
    EKEventStore *store = [HGBCalenderEventTool shareStoreinstance];
    EKEvent *event = [store eventWithIdentifier:eventidentifer];
    return event;
}
/**
 *  将App事件添加到系统日历提醒事项，实现闹铃提醒的功能
 *
 *  @param title      事件标题
 *  @param location   事件位置
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param allDay     是否全天
 *  @param alarmArray 闹钟集合
 *  @param reslut  结果
 */
+ (void)saveEventCalendarTitle:(NSString *)title location:(NSString *)location startDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay alarmArray:(NSArray *)alarmArray andWithReslut:(HGBCalenderEventReslutBlock)reslut{
    [HGBCalenderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
        if (!isCanUseEvent) {
            if (reslut) {
                reslut(NO,@{ReslutCode:@(HGBCalenderEventToolErrorTypeAuthorized).stringValue,ReslutMessage:@"权限不足"});
            }
            [self jumpToSet];
        }
    }];

    EKEventStore *eventStore = [[EKEventStore alloc] init];

    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){

            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    HGBLog(@"添加失败");
                    if (reslut) {
                        reslut(NO,@{ReslutCode:@(HGBCalenderEventToolErrorTypeOther).stringValue,ReslutMessage:@"添加失败"});
                    }

                }else if (!granted){
                    HGBLog(@"权限不足");
                    if (reslut) {
                        reslut(NO,@{ReslutCode:@(HGBCalenderEventToolErrorTypeAuthorized).stringValue,ReslutMessage:@"权限不足"});
                    }

                }else{

                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = title;
                    event.location = location;

                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];

                    event.startDate = startDate;
                    event.endDate   = endDate;
                    event.allDay = allDay;

                    //添加提醒
                    if (alarmArray && alarmArray.count > 0) {

                        for (NSString *timeString in alarmArray) {
                            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[timeString integerValue]]];
                        }
                    }

                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];

                    HGBLog(@"添加成功");

                    if (reslut) {
                         reslut(YES,@{ReslutCode:@(1),ReslutMessage:@"添加成功",@"id":event.calendarItemIdentifier});
                    }

                }
            });
        }];
    }
}
/**
 删除日历

 @param eventIdentifier 事件唯一标识
 @return 结果
 */
+(BOOL)deleteEventWithEventIdentifier:(NSString *)eventIdentifier{
    [HGBCalenderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
        if (!isCanUseEvent) {
           
            [self jumpToSet];
        }
    }];

    EKEventStore *store = [HGBCalenderEventTool shareStoreinstance];
    NSError *err = nil;
    EKEvent *event = [store eventWithIdentifier:eventIdentifier];
    return  [store removeEvent:event span:EKSpanThisEvent commit:YES error:&err];
}
#pragma mark --set
+(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"日历访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
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
    [[HGBCalenderEventTool currentViewController] presentViewController:alert animated:YES completion:nil];
}
#pragma mark 权限判断
+ (void)isCanUseEventWithBolck:(void(^)(BOOL isCanUseEvent))returnBolck
{
    EKEventStore *store = [[EKEventStore alloc]init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        returnBolck(granted);
    }];


}

#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBCalenderEventTool findBestViewController:viewController];
}
/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
+ (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [HGBCalenderEventTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBCalenderEventTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBCalenderEventTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBCalenderEventTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
@end

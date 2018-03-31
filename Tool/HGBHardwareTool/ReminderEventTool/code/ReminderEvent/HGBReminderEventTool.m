
//
//  HGBReminderEventTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/22.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBReminderEventTool.h"
#import <UIKit/UIKit.h>


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif
@implementation HGBReminderEventTool
static HGBReminderEventTool *reminder;

+ (instancetype)sharedInstance{

    if(reminder==nil){
        reminder = [[HGBReminderEventTool alloc] init];
    }
    return reminder;
}

+(EKEventStore *)shareStoreinstance{
    static dispatch_once_t once = 0;
    static EKEventStore *store;
    dispatch_once(&once, ^{ store = [[EKEventStore alloc] init]; });
    return store;
}
/**
 查询所有的提醒

 @param reslut 结果
 */
+(void)fetchAllRemindersWithReslut:(HGBReminderEventToolFetchBlock)reslut{
    [HGBReminderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
        if (!isCanUseEvent) {

            [self jumpToSet];
        }
    }];
    EKEventStore *store      = [HGBReminderEventTool shareStoreinstance];
    NSPredicate  *predicate  = [store predicateForRemindersInCalendars:nil];
    [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {

        NSInteger i = 1;
        for (EKReminder *reminder in reminders) {
            HGBLog(@"第 %zd 个提醒 %@",i,reminder);
            i++;
        }
        if(reslut){
            reslut(YES,reminders);
        }
    }];
}
/**
 * 查询一个时间范围里面的提醒
 *@param starDate 开始时间
 *@param endDate 结束时间
 *@param reslut 结果
 */
+(void)fetchRemindersWithStartDate:(NSDate *)starDate endDate:(NSDate *)endDate andWithReslut:(HGBReminderEventToolFetchBlock)reslut{
    [HGBReminderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
        if (!isCanUseEvent) {
            
            [self jumpToSet];
        }
    }];
    EKEventStore *store = [HGBReminderEventTool shareStoreinstance];
    NSPredicate *predicate = [store predicateForIncompleteRemindersWithDueDateStarting:starDate
                                                                                ending:endDate
                                                                             calendars:[store calendarsForEntityType:EKEntityTypeReminder]];
    [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        if (reslut) {
            reslut(YES,reminders);
        }
    }];
}
/**
 通过id获取事件

 @param identifer id
 @return 事件
 */
+(EKCalendarItem *)fetchReminderWithIdentier:(NSString *)identifer{
    [HGBReminderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
        if (!isCanUseEvent) {

            [self jumpToSet];
        }
    }];

    EKEventStore *store = [HGBReminderEventTool shareStoreinstance];
    EKCalendarItem *item = [store calendarItemWithIdentifier:identifer];
    NSLog(@"item  item %@",item);
    return item;
}
/**
 添加事件

 @param title 事件标题
 @param notes 事件备注
 @param startDate 开始时间
 @param endDate 结束时间
 @param alarm 提醒
 @param priority 事件调度(1-4 高 5中   6-9低  0 不设置）
 @param completed 完成
 @param reslut 结果
 */
+(void)saveEventIntoReminderWithTitle:(NSString *)title notes:(NSString *)notes startDate:(NSDate *)startDate endDate:(NSDate *)endDate alarm:(EKAlarm *)alarm priority:(NSInteger)priority completed:(BOOL)completed reslutBlock:(HGBReminderEventReslutBlock)reslut
                          {
                              [HGBReminderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
                                  if (!isCanUseEvent) {
                                      if (reslut) {
                                          reslut(NO,@{ReslutCode:@(HGBReminderEventToolErrorTypeAuthorized).stringValue,ReslutMessage:@"权限不足"});
                                      }
                                      [self jumpToSet];
                                  }
                              }];

                              
    EKEventStore *store = [HGBReminderEventTool shareStoreinstance];
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:
     ^(BOOL granted, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 if(reslut){
                     HGBLog(@"添加失败");
                     reslut(NO,@{ReslutCode:@(HGBReminderEventToolErrorTypeOther).stringValue,ReslutMessage:@"添加失败"});
                 }
                 return;
             }
             if (!granted) {
                 HGBLog(@"权限不足");
                 reslut(NO,@{ReslutCode:@(HGBReminderEventToolErrorTypeAuthorized).stringValue,ReslutMessage:@"权限不足"});
                 return;
             }
             EKReminder *reminder = [EKReminder reminderWithEventStore:store];
             [reminder setCalendar:[store defaultCalendarForNewReminders]];
             reminder.title       = title;
             reminder.notes       = notes;
             reminder.completed   = completed;
             reminder.priority    = priority;
             if(alarm){
                  [reminder addAlarm:alarm];
             }

             NSCalendar *calender = [NSCalendar currentCalendar];
             [calender setTimeZone:[NSTimeZone systemTimeZone]];
             NSInteger flags      = NSCalendarUnitYear | NSCalendarUnitMonth |
             NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute |
             NSCalendarUnitSecond;
             NSDateComponents* startDateComp = [calender components:flags fromDate:startDate];
             startDateComp.timeZone = [NSTimeZone systemTimeZone];

             reminder.startDateComponents = startDateComp;

             NSDateComponents* endDateComp = [calender components:flags fromDate:startDate];
             endDateComp.timeZone   = [NSTimeZone systemTimeZone];
             reminder.dueDateComponents = endDateComp;

             NSError *err;
             [store saveReminder:reminder commit:YES error:&err];

             if (!err) {
                 if (reslut) {
                     HGBLog(@"添加成功");
                     reslut(YES,@{ReslutCode:@(1),ReslutMessage:@"添加成功",@"id":reminder.calendarItemIdentifier});
                 }
             }else{
                 if (reslut) {
                     HGBLog(@"添加失败");
                     reslut(NO,@{ReslutCode:@(HGBReminderEventToolErrorTypeOther).stringValue,ReslutMessage:@"添加失败"});
                 }
             }
         });
     }];
}
/**
 * 删除一个提醒
 */
+(BOOL)deleteReminderWithIdentifer:(NSString *)identifier{
    [HGBReminderEventTool isCanUseEventWithBolck:^(BOOL isCanUseEvent) {
        if (!isCanUseEvent) {

            [self jumpToSet];
        }
    }];
    EKEventStore *store = [HGBReminderEventTool shareStoreinstance];
    EKCalendarItem *item = [store calendarItemWithIdentifier:identifier];
    EKReminder *reminder =(EKReminder *)item;
    NSError *err = nil;
    return  [store removeReminder:reminder commit:YES error:&err];
}
#pragma mark --set
+(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"事件访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
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
    [[HGBReminderEventTool currentViewController] presentViewController:alert animated:YES completion:nil];
}
#pragma mark 权限判断
+ (void)isCanUseEventWithBolck:(void(^)(BOOL isCanUseEvent))returnBolck
{
    EKEventStore *store = [[EKEventStore alloc]init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
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
    return [HGBReminderEventTool findBestViewController:viewController];
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
        return [HGBReminderEventTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBReminderEventTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBReminderEventTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBReminderEventTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
@end

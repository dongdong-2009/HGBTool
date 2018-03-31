//
//  HGBReminderEventTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/22.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>


#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif
/**
 结果

 @param status 状态
 @param returnMessage 信息
 */
typedef void (^HGBReminderEventReslutBlock)(BOOL status,NSDictionary *returnMessage);

/**
 错误类型
 */
typedef enum HGBReminderEventToolErrorType
{
    HGBReminderEventToolErrorTypeOther=99,//其他
    HGBReminderEventToolErrorTypeDevice=10,//设备受限
    HGBReminderEventToolErrorTypeAuthorized=11//权限


}HGBReminderEventToolErrorType;

typedef void (^HGBReminderEventToolFetchBlock)(BOOL status,NSArray *eventArr);
@interface HGBReminderEventTool : NSObject
/**
 查询所有的提醒

 @param reslut 结果
 */
+(void)fetchAllRemindersWithReslut:(HGBReminderEventToolFetchBlock)reslut;
/**
* 查询一个时间范围里面的提醒
*@param starDate 开始时间
*@param endDate 结束时间
*@param reslut 结果
*/
+(void)fetchRemindersWithStartDate:(NSDate *)starDate endDate:(NSDate *)endDate andWithReslut:(HGBReminderEventToolFetchBlock)reslut;
/**
 通过id获取事件

 @param identifer id
 @return 事件
 */
+(EKCalendarItem *)fetchReminderWithIdentier:(NSString *)identifer;
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
+(void)saveEventIntoReminderWithTitle:(NSString *)title notes:(NSString *)notes startDate:(NSDate *)startDate endDate:(NSDate *)endDate alarm:(EKAlarm *)alarm priority:(NSInteger)priority completed:(BOOL)completed reslutBlock:(HGBReminderEventReslutBlock)reslut;
/**
 * 删除一个提醒
 */
+(BOOL)deleteReminderWithIdentifer:(NSString *)identifier;
@end

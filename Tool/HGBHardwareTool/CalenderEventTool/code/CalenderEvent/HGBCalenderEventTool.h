//
//  HGBCalenderEventTool.h
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
typedef void (^HGBCalenderEventReslutBlock)(BOOL status,NSDictionary *returnMessage);

/**
 错误类型
 */
typedef enum HGBCalenderEventToolErrorType
{
    HGBCalenderEventToolErrorTypeOther=99,//其他
    HGBCalenderEventToolErrorTypeDevice=10,//设备受限
    HGBCalenderEventToolErrorTypeAuthorized=11//权限


}HGBCalenderEventToolErrorType;

typedef void (^HGBCalenderEventToolFetchBlock)(BOOL status,NSArray *eventArr);

@interface HGBCalenderEventTool : NSObject


/**
 获取日历事件

 @param startDate 开始日期
 @param enDate 结束日期
 @return 结果
 */
+(NSArray *)fetchEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)enDate;

/** 用唯一标示查询一个事件(只能查询日历里面的事件)
 * eventidentifer 唯一标示
 */
+(EKEvent *)fetchEventWithIdentifer:(NSString *)eventidentifer;
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
+(void)saveEventCalendarTitle:(NSString *)title location:(NSString *)location startDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay alarmArray:(NSArray *)alarmArray andWithReslut:(HGBCalenderEventReslutBlock)reslut;
/**
 删除日历

 @param eventIdentifier 事件唯一标识
 @return 结果
 */
+(BOOL)deleteEventWithEventIdentifier:(NSString *)eventIdentifier;
@end

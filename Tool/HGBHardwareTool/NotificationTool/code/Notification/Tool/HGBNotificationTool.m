//
//  HGBNotificationTool.m
//  测试
//
//  Created by huangguangbao on 2017/8/6.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBNotificationTool.h"


#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>


#import "HGBNotificationDataBaseTool.h"


#define HGBMessageidentify @"messageIdentify"

#define HGBPushNotificationMessageKey @"HGBPushNotificationMessageKey"

#define HGBRegisterPushDeviceTokenKey @"HGBRegisterPushDeviceTokenKey"
#define HGBPushNotificationDeviceTokenKey @"HGBPushNotificationDeviceTokenKey"
#define HGBPushDeviceTokenKey @"HGBPushDeviceTokenKey"



#define HGBPushNotificationMessageSavePath @"document://HGBPushMessage"


#define NotificatonTable @"NotificatonTable"
#define NotificationID @"notification_id"


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


@interface HGBNotificationTool ()

@end


@implementation HGBNotificationTool
static HGBNotificationTool *noti=nil;
#pragma mark init
/**
 单例

 @return 实例
 */
+(instancetype)shareInstance{
    if(noti==nil){
      noti=[[HGBNotificationTool alloc]init];
      [[NSNotificationCenter defaultCenter]addObserver:noti selector:@selector(reciveRemoteDeviceToken:) name:HGBPushNotificationDeviceTokenKey object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:noti selector:@selector(recivePushMessage:) name:HGBPushNotificationMessageKey object:nil];
    }
    return noti;
}
#pragma mark 通知
/**
 发送通知

 @param name 通知名

 @param userInfo 消息相关信息
 */
-(void)sendNotificationWithName:(NSString *)name andWithUserInfo:(NSDictionary *)userInfo{
    [[NSNotificationCenter defaultCenter]postNotificationName:name object:self userInfo:userInfo];
}
/**
 监听通知

 @param name 通知名
 @param selector 监听方法
 @param observer 监听者
 */
-(void)observerNotificationWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name{
    [[NSNotificationCenter defaultCenter]addObserver:observer selector:selector name:name object:self];
}
/**
 移除通知监听
 @param name 通知名 可以为空 为空时移除所有通知
 @param observer 监听者
 */
- (void)removeNotificationObserver:(id)observer andWithName:(NSString *)name{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:self];
}

#pragma mark 本地推送


/**
 发送本地推送消息

 @param messageTitle 消息标题
 @param messageSubTitle 消息副标题
 @param messageBody 消息体
 @param userInfo 消息相关信息
 @param messageIdentify 消息标记
 @param fireDate 消息发送时间
 @param reslutBlock  结果

 */
-(void)pushLocalNotificationWithMessageTitle:(NSString *)messageTitle andWithMessageSubTitle:(NSString *)messageSubTitle andWithMessageBody:(NSString *)messageBody andWithUserInfo:(NSDictionary *)userInfo andWithMessageIdentify:(NSString *)messageIdentify InFireDate:(NSDate *)fireDate andWithReslutBlock:(HGBNotificationToolNotiReslutBlock)reslutBlock{
#ifdef __IPHONE_10_0
    UNMutableNotificationContent *content=[[UNMutableNotificationContent alloc]init];
    if(messageTitle){
        content.title=messageTitle;
    }

    if(userInfo){
        content.userInfo=userInfo;
    }
    if(messageBody){
        content.body=messageBody;
    }
    if(messageSubTitle){
         content.subtitle= messageSubTitle;
    }
    content.sound=[UNNotificationSound defaultSound];
    content.badge = @([[UIApplication sharedApplication]applicationIconBadgeNumber]+1);

    NSTimeInterval interval=[fireDate timeIntervalSinceNow];

    //第三步：通知触发机制。（重复提醒，时间间隔要大于60s）
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:interval repeats:NO];

    NSString *requertIdentifier;
    //第四步：创建UNNotificationRequest通知请求对象
    if(messageIdentify){
        requertIdentifier = messageIdentify;
    }else{
        requertIdentifier=[self getSecondTimeStringSince1970];
    }

    NSMutableDictionary *userInfoMessage=[[NSMutableDictionary alloc]initWithDictionary:userInfo];
    if (userInfoMessage==nil) {
        userInfoMessage=[NSMutableDictionary dictionary];
    }
    [userInfoMessage setObject:requertIdentifier forKey:HGBMessageidentify];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requertIdentifier content:content trigger:trigger];

    //第五步：将通知加到通知中心
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if(error){
            if (reslutBlock) {
                reslutBlock(YES,@{ReslutCode:@"99",ReslutMessage:error.localizedDescription});
            }
        }else{
            if (reslutBlock) {
                reslutBlock(YES,@{ReslutCode:@"1",ReslutMessage:@"成功"});
            }
        }
    }];



#else
    UILocalNotification *localNoti=[[UILocalNotification alloc]init];
    if(messageTitle){
        localNoti.alertTitle=messageTitle;
    }
    NSMutableDictionary *userInfoMessage=[[NSMutableDictionary alloc]initWithDictionary:userInfo];
    if (userInfoMessage==nil) {
        userInfoMessage=[NSMutableDictionary dictionary];
    }
    NSString *requertIdentifier;
    //第四步：创建UNNotificationRequest通知请求对象
    if(messageIdentify){
        requertIdentifier = messageIdentify;
    }else{
        requertIdentifier=[self getSecondTimeStringSince1970];
    }
    [userInfoMessage setObject:requertIdentifier forKey:HGBMessageidentify];
    localNoti.userInfo=userInfo;

    if(messageBody){
        localNoti.alertBody=messageBody;
    }
    localNoti.soundName= UILocalNotificationDefaultSoundName;

    localNoti.fireDate=fireDate;
    
    [[UIApplication sharedApplication]scheduleLocalNotification:localNoti];

    if (reslutBlock) {
        reslutBlock(YES,@{ReslutCode:@"1",ReslutMessage:@"成功"});
    }
#endif

}
//取消本地推送

/**
 取消本地推送

 @param messageIdentify 本地推送标志位-根据userInfo中id_key字段判断
 */
-(void)cancelLocalNotificationWithMessageIdentify:(NSString *)messageIdentify{
#ifdef __IPHONE_10_0
    UNUserNotificationCenter *center=[UNUserNotificationCenter currentNotificationCenter];
    [center removePendingNotificationRequestsWithIdentifiers:@[messageIdentify]];
    [center removeDeliveredNotificationsWithIdentifiers:@[messageIdentify]];
#else
    NSArray *notis=[[UIApplication sharedApplication]scheduledLocalNotifications];
    for(UILocalNotification *noti in notis){
        if([[noti.userInfo objectForKey:HGBMessageidentify] isEqualToString:messageIdentify]){
            [[UIApplication sharedApplication]cancelLocalNotification:noti];
        }
    }
#endif

}
/**
 取消所有本地通知
 */
-(void)cancelAllLocalNotification{
#ifdef __IPHONE_10_0
    UNUserNotificationCenter *center=[UNUserNotificationCenter currentNotificationCenter];
    [center removeAllDeliveredNotifications];
    [center removeAllPendingNotificationRequests];
#else
    NSArray *notis=[[UIApplication sharedApplication]scheduledLocalNotifications];
    for(UILocalNotification *noti in notis){
        [[UIApplication sharedApplication]cancelLocalNotification:noti];
    }
#endif

}
///**
// 获取推送消息
//
// @param reslutBlock 结果
// */
//-(void)getNotificationWithMessageIdentify:(NSString *)messageIdentify andWithResult:(void(^)(BOOL status,NSDictionary *notifivation))reslutBlock{
//#ifdef __IPHONE_10_0
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
//        int i=0;
//
//        for (UNNotification *noti in notifications) {
//            NSMutableDictionary *message=[NSMutableDictionary dictionary];
//            if(noti.request.){
//                [message setObject:noti.alertTitle forKey:@"title"];
//            }
//            if(noti.alertBody){
//                [message setObject:noti.alertBody forKey:@"body"];
//            }
//            if(noti.fireDate){
//                [message setObject:noti.fireDate forKey:@"fireDate"];
//            }
//            if(noti.userInfo){
//                [message setObject:noti.userInfo forKey:@"userInfo"];
//                if([[noti.userInfo objectForKey:HGBMessageidentify] isEqualToString:messageIdentify]){
//                    reslutBlock(YES,message);
//                    break;
//                }
//            }
//            i++;
//        }
//        if (i==notis.count) {
//            reslutBlock(NO,nil);
//        }
//        if (reslutBlock) {
//            reslutBlock(YES,notifications);
//        }
//    }];
//    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
//        if (reslutBlock) {
//            reslutBlock(YES,requests);
//        }
//
//    }];
//#else
//    NSArray *notis=[[UIApplication sharedApplication]scheduledLocalNotifications];
//    int i=0;
//
//    for (UILocalNotification *noti in notis) {
//        NSMutableDictionary *message=[NSMutableDictionary dictionary];
//        if(noti.alertTitle){
//            [message setObject:noti.alertTitle forKey:@"title"];
//        }
//        if(noti.alertBody){
//            [message setObject:noti.alertBody forKey:@"body"];
//        }
//        if(noti.fireDate){
//            [message setObject:noti.fireDate forKey:@"fireDate"];
//        }
//        if(noti.userInfo){
//            [message setObject:noti.userInfo forKey:@"userInfo"];
//            if([[noti.userInfo objectForKey:HGBMessageidentify] isEqualToString:messageIdentify]){
//                reslutBlock(YES,message);
//                break;
//            }
//        }
//        i++;
//    }
//    if (i==notis.count) {
//        reslutBlock(NO,nil);
//    }
//#endif
//
//}
///**
// 获取推送消息
//
// @param reslutBlock 结果
// */
//-(void)getAllNotificationsWithResult:(void(^)(BOOL status,NSArray *notifivations))reslutBlock{
//    NSMutableArray *messages=[NSMutableArray array];
//#ifdef __IPHONE_10_0
//      UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
//        if (reslutBlock) {
//            reslutBlock(YES,notifications);
//        }
//    }];
//    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
//        if (reslutBlock) {
//            reslutBlock(YES,requests);
//        }
//
//    }];
//
//#else
//    NSArray *notis=[[UIApplication sharedApplication]scheduledLocalNotifications];
//    for (UILocalNotification *noti in notis) {
//        NSMutableDictionary *message=[NSMutableDictionary dictionary];
//        if(noti.alertTitle){
//            [message setObject:noti.alertTitle forKey:@"title"];
//        }
//        if(noti.alertBody){
//            [message setObject:noti.alertBody forKey:@"body"];
//        }
//        if(noti.fireDate){
//            [message setObject:noti.fireDate forKey:@"fireDate"];
//        }
//        if(noti.userInfo){
//            [message setObject:noti.userInfo forKey:@"userInfo"];
//        }
//        [messages addObject:message];
//
//    }
//    if (reslutBlock) {
//        reslutBlock(YES,messages);
//    }
//
//#endif
//}
#pragma mark 远程推送
/**
 停止推送接受
 */
-(void)stopRemotePush{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
/**
 重启推送
 */
-(void)resumeRemotePush{
    [self sendNotificationWithName:HGBRegisterPushDeviceTokenKey andWithUserInfo:nil];
}
/**
 获取远程推送DeviceToken

 @return 远程推送token 为nil时获取失败
 */
-(NSString *)getRemoteNotificationDeviceToken{
    NSString *deviceToken=[self getDefaultsWithKey:HGBPushDeviceTokenKey];
    return deviceToken;
}

/**
 接受到推送token

 @param _n 消息
 */
-(void)reciveRemoteDeviceToken:(NSNotification *)_n{
    if(_n.userInfo){
        NSString *deviceToken=[_n.userInfo objectForKey:HGBPushDeviceTokenKey];
        if(self.deviceTokenBlock){
            self.deviceTokenBlock(YES, deviceToken);
        }
    }

}
#pragma mark 远程与本地推送

/**
 推送权限申请

 */
-(void)registerPushNotificationAuthority{
    [self sendNotificationWithName:HGBRegisterPushDeviceTokenKey andWithUserInfo:nil];
}
/**
 接受到推送消息

 @param _n 消息
 */
-(void)recivePushMessage:(NSNotification *)_n{
    if(_n.userInfo){
        NSNumber *number=[_n.userInfo objectForKey:@"type"];
        HGBNotificatonType type=(HGBNotificatonType)[number integerValue];
        if(self.messageBlock){
            self.messageBlock(type, _n.userInfo);
        }
    }

}
#pragma mark 文件存储消息

/**
 获取消息集合

 @return 消息集合
 */
- (NSArray *)getNotifications{
    NSArray *messages=[[HGBNotificationDataBaseTool shareInstance]queryNodesWithCondition:@{} inTableWithTableName:NotificatonTable];
    return messages;
}
/**
 * 根据状态获取消息
 *
 *  @param status 状态
 * @return 消息集合
 */
- (NSArray *)getNotificationsByStatus:(NSString *)status{
    NSArray *messages=[[HGBNotificationDataBaseTool shareInstance]queryNodesWithCondition:@{@"status":status} inTableWithTableName:NotificatonTable];
    return messages;

}
/**
 * 根据id获取消息
 *
 *  @param notificationId 消息id
 *   @return 消息
 */
- (NSDictionary *)getNotificationById:(NSString *)notificationId{
     NSArray *messages=[[HGBNotificationDataBaseTool shareInstance]queryNodesWithCondition:@{NotificationID:notificationId} inTableWithTableName:NotificatonTable];
    if (messages==nil||messages.count==0) {
        NSDictionary *message=messages[0];
        return messages;
    }
    return nil;



}
/**
 * 消息修改
 *
 *  @param notificationId 消息id
 *  @param status 消息状态
 *  @param notification 消息
 *   @return 结果
 */
- (BOOL)changeNotificationWithNotificationId:(NSString *)notificationId andWithStatus:(NSString *)status andWithNotification:(NSDictionary *)notification{
    if (notificationId==nil||notificationId.length==0) {
        return NO;
    }
    if(status==nil&&notification==nil){

        return NO;
    }
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    if(status){
        [dic setObject:status forKey:@"status"];
    }
    if(notification){
        [dic setObject:notification forKey:@"notification"];
    }
     BOOL flag=[[HGBNotificationDataBaseTool shareInstance]updateNodeWithCondition:@{NotificationID:notificationId} andWithChangeDic:dic inTableWithTableName:NotificatonTable];
    return flag;

}
/**
 * 删除一条消息
 *
 *  @param notificationId 消息id
 *   @return 结果
 */
- (BOOL)deleteNotificationById:(NSString *)notificationId{
    if (notificationId==nil||notificationId.length==0) {

        return NO;
    }



    BOOL flag=[[HGBNotificationDataBaseTool shareInstance]removeNodesWithCondition:@{NotificationID:notificationId} inTableWithTableName:NotificatonTable];
    return flag;
}
/**
 * 删除所有消息
 *
 *   @return 结果
 */
- (BOOL)deleteAllNotification{
     BOOL flag=[[HGBNotificationDataBaseTool shareInstance]removeNodesWithCondition:@{} inTableWithTableName:NotificatonTable];
    return flag;
}
#pragma mark 应用角标
/**
 设置应用角标

 @param badge 角标
 */
-(void)setApplicationBadge:(NSInteger )badge{
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;
}
/**
 应用角标+1
 */
-(void)addApplicationBadge{
    NSInteger badge=[UIApplication sharedApplication].applicationIconBadgeNumber;
    badge++;
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;
}
/**
 应用角标-1
 */
-(void)reduceApplicationBadge{
    NSInteger badge=[UIApplication sharedApplication].applicationIconBadgeNumber;
    if(badge>0){
        badge--;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;
}
/**
 应用角标添加
 @param number 角标加的数目
 */
-(void)addApplicationBadgeWithNumber:(NSInteger)number{
    NSInteger badge=[UIApplication sharedApplication].applicationIconBadgeNumber;
    if(badge+number>=0){
        badge=badge+number;
    }else{
        badge=0;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;

}
/**
 应用角标隐藏

 */
-(void)hideApplicationBadge{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
}
/**
 获取应用角标

 @return  应用角标
 */
-(NSInteger)getApplicationBadge{
    return [UIApplication sharedApplication].applicationIconBadgeNumber;
}

#pragma mark defaults保存

/**
 *  Defaults保存
 *
 *  @param value   要保存的数据
 *  @param key   关键字
 *  @return 保存结果
 */
-(BOOL)saveDefaultsValue:(id)value WithKey:(NSString *)key{
    if((!value)||(!key)||key.length==0){
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
    return YES;
}
/**
 *  Defaults取出
 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
-(id)getDefaultsWithKey:(NSString *)key{
    if(key==nil||key.length==0){
        return nil;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id  value=[defaults valueForKey:key];
    [defaults synchronize];
    return value;
}
/**
 *  Defaults删除 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
-(BOOL)deleteDefaultsWithKey:(NSString *)key{
    if(key==nil||key.length==0){
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
    return YES;
}

#pragma mark 获取时间
/**
 获取时间戳-秒级

 @return 秒级时间戳
 */
- (NSString *)getSecondTimeStringSince1970
{
    NSDate* date = [NSDate date];
    NSTimeInterval interval=[date timeIntervalSince1970];  //  *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%f", interval]; //转为字符型
    NSString *timeStr = [NSString stringWithFormat:@"%lf",[timeString doubleValue]*1000000];

    if(timeStr.length>=16){
        return [timeStr substringToIndex:16];
    }else{
        return timeStr;
    }
}
@end

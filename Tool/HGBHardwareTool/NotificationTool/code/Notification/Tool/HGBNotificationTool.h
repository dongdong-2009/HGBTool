//
//  HGBNotificationTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/6.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 通知消息类型
 */
typedef enum HGBNotificatonType
{
    HGBNotificatonTypeRemoteActive,//前台状态远程消息
    HGBNotificatonTypeLocalActive,//前台状态本地消息
    HGBNotificatonTypeRemoteBackGround,//后台状态远程消息
    HGBNotificatonTypeLocalBackGround,//后台状态本地消息
    HGBNotificatonTypeRemoteInActive,//挂起状态远程消息
    HGBNotificatonTypeLocalInActive,//挂起状态本地消息
    HGBNotificatonTypeRemoteLanuch,//app加载状态远程消息
    HGBNotificatonTypeLocalLanuch//app加载状态本地消息

}HGBNotificatonType;


/**
 消息监听

 @param type 消息类型
 @param message 消息
 */
typedef void (^HGBNotificationToolMessageMonitorBlock)(HGBNotificatonType type,NSDictionary *message);
/**
 deviceToken监听

 @param status 状态
 @param deviceToken deviceToken
 */
typedef void (^HGBNotificationToolDeviceTokenMonitorBlock)(BOOL status,NSString *deviceToken);

/**
 通用回调

 @param status 状态
 @param returnMessage 返回信息
 */
typedef void (^HGBNotificationToolNotiReslutBlock )(BOOL status,NSDictionary *returnMessage);


///**
// 扫描方式类型
// */
//typedef enum HGBRomotePushType
//{
//    HGBRomotePushTypeTest,//测试版证书
//    HGBRomotePushTypeFormal//发布版证书
//
//}HGBRomotePushType;



@interface HGBNotificationTool : NSObject
/**
 消息监听
 */
@property(strong,nonatomic)HGBNotificationToolMessageMonitorBlock messageBlock;
/**
 deviceToken监听
 */
@property(strong,nonatomic)HGBNotificationToolDeviceTokenMonitorBlock deviceTokenBlock;

#pragma mark init
/**
 单例

 @return 实例
 */
+(instancetype)shareInstance;

#pragma mark 通知
/**
 发送通知

 @param name 通知名

 @param userInfo 消息相关信息
 */
-(void)sendNotificationWithName:(NSString *)name andWithUserInfo:(NSDictionary *)userInfo;
/**
 监听通知

 @param name 通知名
 @param selector 监听方法
 @param observer 监听者
 */
-(void)observerNotificationWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name;
/**
 移除通知监听
 @param name 通知名 可以为空 为空时移除所有通知
 @param observer 监听者
 */
- (void)removeNotificationObserver:(id)observer andWithName:(NSString *)name;

#pragma mark 远程与本地推送
/**
 推送权限申请

 */
-(void)registerPushNotificationAuthority;
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
-(void)pushLocalNotificationWithMessageTitle:(NSString *)messageTitle andWithMessageSubTitle:(NSString *)messageSubTitle andWithMessageBody:(NSString *)messageBody andWithUserInfo:(NSDictionary *)userInfo andWithMessageIdentify:(NSString *)messageIdentify InFireDate:(NSDate *)fireDate andWithReslutBlock:(HGBNotificationToolNotiReslutBlock)reslutBlock;

//取消本地推送

/**
 取消本地推送

 @param messageIdentify 本地推送标志位-根据userInfo中id_key字段判断
 */
-(void)cancelLocalNotificationWithMessageIdentify:(NSString *)messageIdentify;
/**
 取消所有本地通知
 */
-(void)cancelAllLocalNotification;

#pragma mark 远程推送
/**
 停止推送接受
 */
-(void)stopRemotePush;
/**
 重启推送
 */
-(void)resumeRemotePush;

/**
 获取远程推送DeviceToken

 @return 远程推送token 为nil时获取失败
 */
-(NSString *)getRemoteNotificationDeviceToken;

#pragma mark 文件存储消息

/**
 获取消息集合

 @return 消息集合
 */
- (NSArray *)getNotifications;
/**
 * 根据状态获取消息
 *
 *  @param status 状态
 * @return 消息集合
 */
- (NSArray *)getNotificationsByStatus:(NSString *)status;
/**
 * 根据id获取消息
 *
 *  @param notificationId 消息id
 *   @return 消息
 */
- (NSDictionary *)getNotificationById:(NSString *)notificationId;
/**
 * 消息修改
 *
 *  @param notificationId 消息id
 *  @param status 消息状态
 *  @param notification 消息
 *   @return 结果
 */
- (BOOL)changeNotificationWithNotificationId:(NSString *)notificationId andWithStatus:(NSString *)status andWithNotification:(NSDictionary *)notification;
/**
 * 删除一条消息
 *
 *  @param notificationId 消息id
 *   @return 结果
 */
- (BOOL)deleteNotificationById:(NSString *)notificationId;
/**
 * 删除所有消息
 *
 *   @return 结果
 */
- (BOOL)deleteAllNotification;
#pragma mark 应用角标
/**
 设置应用角标

 @param badge 角标
 */
-(void)setApplicationBadge:(NSInteger )badge;
/**
 应用角标+1
 */
-(void)addApplicationBadge;
/**
 应用角标-1
 */
-(void)reduceApplicationBadge;
/**
 应用角标添加
 @param number 角标加的数目
 */
-(void)addApplicationBadgeWithNumber:(NSInteger)number;
/**
 应用角标隐藏

 */
-(void)hideApplicationBadge;
/**
 获取应用角标

 @return  应用角标
 */
-(NSInteger)getApplicationBadge;

@end

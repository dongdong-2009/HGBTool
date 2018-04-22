//
//  AppDelegate+HGBPush.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/9/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "AppDelegate+HGBPush.h"
#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>
#import "HGBNotificationDataBaseTool.h"


#define WidthScale [UIScreen mainScreen].bounds.size.width/375
#define HeightScale [UIScreen mainScreen].bounds.size.height/667
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height




#define HGBPushNotificationMessageKey @"HGBPushNotificationMessageKey"

#define HGBRegisterPushDeviceTokenKey @"HGBRegisterPushDeviceTokenKey"
#define HGBPushNotificationDeviceTokenKey @"HGBPushNotificationDeviceTokenKey"
#define HGBPushDeviceTokenKey @"HGBPushDeviceTokenKey"

#define NotificatonTable @"NotificatonTable"
#define NotificationID @"notification_id"


#define HGBPushNotificationMessageSavePath @"document://HGBPushMessage"



/**
 通知消息类型
 */
typedef enum HGBPushNotificatonType
{
    HGBPushNotificatonTypeRemoteActive,//前台状态远程消息
    HGBPushNotificatonTypeLocalActive,//前台状态本地消息
    HGBPushNotificatonTypeRemoteBackGround,//后台状态远程消息
    HGBPushNotificatonTypeLocalBackGround,//后台状态本地消息
    HGBPushNotificatonTypeRemoteInActive,//挂起状态远程消息
    HGBPushNotificatonTypeLocalInActive,//挂起状态本地消息
    HGBPushNotificatonTypeRemoteLanuch,//app加载状态远程消息
    HGBPushNotificatonTypeLocalLanuch//app加载状态本地消息

}HGBPushNotificatonType;



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


@implementation AppDelegate (HGBPush)

#pragma mark init
/**
 推送初始化

 @param launchOptions 加载参数
 */
-(void)init_Push_ServerWithOptions:(NSDictionary *)launchOptions{
    [self application_Push_DidLaunchHandleWithOptions:launchOptions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(application_Push_willResignActiveHandle:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(application_Push_DidBecomeActiveHandle:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(application_Push_willTerminateHandle:) name:UIApplicationWillTerminateNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerPushNotificationAuthority) name:HGBRegisterPushDeviceTokenKey object:nil];
    [[HGBNotificationDataBaseTool shareInstance] createTableWithTableName:NotificatonTable andWithKeys:@[NotificationID,@"time",@"status",@"notification"] andWithPrimaryKey:@"id"];
}
#pragma mark 权限
-(void)isCanPush:(void(^)(BOOL isCanPush))resultBlock{
#ifdef __IPHONE_10_0
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (resultBlock) {
            resultBlock(settings.authorizationStatus == UNAuthorizationStatusAuthorized);
        }
    }];
    resultBlock([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
#else
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (resultBlock) {
        resultBlock(type != UIRemoteNotificationTypeNone);
    }

#endif

}
#pragma mark set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"推送访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
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
#pragma mark life
/**
 app加载

 @param launchOptions 信息
 */
-(void)application_Push_DidLaunchHandleWithOptions:(NSDictionary *)launchOptions{
    
    [self registerPushNotificationAuthority];
    [self launchWithNotificationInfo:launchOptions];
}
/**
 app进入前台

 @param notification 消息
 */
-(void)application_Push_DidBecomeActiveHandle:(NSNotification *)notification{
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
/**
 app将要离开前台

 @param notification 消息
 */
-(void)application_Push_willResignActiveHandle:(NSNotification *)notification{
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
/**
 app将要销毁

 @param notification 消息
 */
-(void)application_Push_willTerminateHandle:(NSNotification *)notification{
}

#pragma mark 消息处理
/**
 消息处理

 @param messageTitle 消息标题
 @param messageBody 消息体
 @param messageInfo 消息信息
 */
-(void)applicationDidReciveMessageWithMessageTitle:(NSString *)messageTitle andWithMessageBody:(NSString *)messageBody andWithMessageInfo:(NSDictionary *)messageInfo andWithMessageType:(HGBPushNotificatonType )messageType{
    if(messageType==HGBPushNotificatonTypeLocalActive||messageType==HGBPushNotificatonTypeRemoteActive){
         [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    NSMutableDictionary *message=[NSMutableDictionary dictionary];
    if (messageTitle) {
        [message setObject:messageTitle forKey:@"title"];
    }
    if (messageBody) {
        [message setObject:messageBody forKey:@"body"];
    }
    NSString *messageTypeDesciption=@"";
    if (messageType==HGBPushNotificatonTypeRemoteActive) {
        messageTypeDesciption=@"远程推送-应用处于前台";
    }else if (messageType==HGBPushNotificatonTypeRemoteInActive){
        messageTypeDesciption=@"远程推送-应用处于挂起状态";
    }else if (messageType==HGBPushNotificatonTypeRemoteBackGround){
        messageTypeDesciption=@"远程推送-应用处于后台";
    }else if (messageType==HGBPushNotificatonTypeRemoteLanuch){
        messageTypeDesciption=@"远程推送-应用启动";
    }else if (messageType==HGBPushNotificatonTypeLocalActive) {
        messageTypeDesciption=@"本地推送-应用处于前台";
    }else if (messageType==HGBPushNotificatonTypeLocalInActive){
        messageTypeDesciption=@"本地推送-应用处于挂起状态";
    }else if (messageType==HGBPushNotificatonTypeLocalBackGround){
        messageTypeDesciption=@"本地推送-应用处于后台";
    }else if (messageType==HGBPushNotificatonTypeLocalLanuch){
        messageTypeDesciption=@"本地推送-应用启动";
    }
    if (messageTypeDesciption) {
        [message setObject:messageTypeDesciption forKey:@"desciption"];
    }
    [message setObject:@(messageType) forKey:@"type"];
    [message setObject:messageInfo forKey:@"message"];
    [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationMessageKey object:self userInfo:message];

    NSDate *date=[NSDate date];
    NSDateFormatter *f=[[NSDateFormatter alloc]init];
    f.dateFormat=@"yyyy-MM-dd HH:mm:ss";

    [[HGBNotificationDataBaseTool shareInstance]addNode:@{NotificationID:[self getSecondTimeStringSince1970],@"status":@"0",@"time":[f stringFromDate:date],@"notification":message} withTableName:NotificatonTable];

}
#pragma mark 申请推送权限
/**
 推送权限
 */
-(void)registerPushNotificationAuthority{
    UIApplication *application=[UIApplication sharedApplication];
    //注册
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {

#ifdef __IPHONE_10_0

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        //请求获取通知权限（角标，声音，弹框）
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted==NO) {
                if (error) {
                    NSDictionary *userInfo=@{ReslutCode:@"99",ReslutMessage:error.localizedDescription};
                    [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationDeviceTokenKey object:self userInfo:userInfo];
                }else{
                    NSDictionary *userInfo=@{ReslutCode:@"99",ReslutMessage:@"获取deviceToken失败"};
                    [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationDeviceTokenKey object:self userInfo:userInfo];
                }
            }
        }];
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        //        本地通知
        [application registerUserNotificationSettings:setting];
        //        远程通知
        [application registerForRemoteNotifications];

#else
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        //        本地通知
        [application registerUserNotificationSettings:setting];
        //        远程通知
        [application registerForRemoteNotifications];
#endif


    }
}

#pragma mark 远程通知注册反馈

/**
 注册远程通知成功

 @param application application
 @param deviceToken token
 */
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    NSString *dvsToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *formatToekn = [dvsToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (deviceToken) {
        [self saveDefaultsValue:formatToekn WithKey:HGBPushDeviceTokenKey];
        NSDictionary *userInfo=@{HGBPushDeviceTokenKey:formatToekn};
         [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationDeviceTokenKey object:self userInfo:userInfo];
    }else{
        NSDictionary *userInfo=@{ReslutCode:@"99",ReslutMessage:@"获取deviceToken失败"};
        [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationDeviceTokenKey object:self userInfo:userInfo];
    }
}
/**
 注册远程通知失败

 @param application application
 @param error 错误
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error) {
        NSDictionary *userInfo=@{ReslutCode:@"99",ReslutMessage:error.localizedDescription};
        [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationDeviceTokenKey object:self userInfo:userInfo];
    }else{
        NSDictionary *userInfo=@{ReslutCode:@"99",ReslutMessage:@"获取deviceToken失败"};
        [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationDeviceTokenKey object:self userInfo:userInfo];
    }
}
#pragma mark iOS10以下本地通知注册反馈
#ifdef __IPHONE_10_0
#else
/**
 本地通知注册成功

 @param application application
 @param notificationSettings 配置
 */
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings
{
//    [[NSNotificationCenter defaultCenter]postNotificationName:HGBPushNotificationMessageKey object:self userInfo:message];
}
#endif

#pragma mark 初次进入消息处理

/**
 初次进入application获取到消息（状态栏点击消息进入）

 @param launchOptions 信息
 */
-(void)launchWithNotificationInfo:(NSDictionary *)launchOptions{
    NSDictionary* remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    NSDictionary* localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];

    if(localNotification){
         [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:localNotification andWithMessageType:HGBPushNotificatonTypeLocalLanuch];

    }
    if(remoteNotification){
         [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:remoteNotification andWithMessageType:HGBPushNotificatonTypeRemoteLanuch];
       
    }

#ifdef __IPHONE_10_0
#else

#endif

}
#pragma mark iOS10以上消息处理
#ifdef __IPHONE_10_0
//
/**
 App处于前台接收通知时

 @param center 消息中心
 @param notification 消息中心
 @param completionHandler 完成
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{

    //收到推送的请求
    UNNotificationRequest *request = notification.request;

    //收到推送的内容
    UNNotificationContent *content = request.content;

    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;

    //收到推送消息的角标
//    NSNumber *badge = content.badge;

    //收到推送消息body
    NSString *body = content.body;

    //推送消息的声音
//    UNNotificationSound *sound = content.sound;

    // 推送消息的副标题
//    NSString *subtitle = content.subtitle;

    // 推送消息的标题
    NSString *title = content.title;

    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self applicationDidReciveMessageWithMessageTitle:title andWithMessageBody:body andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeRemoteActive];

    }else {
        [self applicationDidReciveMessageWithMessageTitle:title andWithMessageBody:body  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalActive];

    }


    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);

}



/**
 App通知的点击事件

 @param center 消息中心
 @param response 反馈
 @param completionHandler 完成
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;

    //收到推送的内容
    UNNotificationContent *content = request.content;

    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;

    //收到推送消息的角标
//    NSNumber *badge = content.badge;

    //收到推送消息body
    NSString *body = content.body;

    //推送消息的声音
//    UNNotificationSound *sound = content.sound;

    // 推送消息的副标题
//    NSString *subtitle = content.subtitle;

    // 推送消息的标题
    NSString *title = content.title;

    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self applicationDidReciveMessageWithMessageTitle:title andWithMessageBody:body  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeRemoteBackGround];


    }else {
        [self applicationDidReciveMessageWithMessageTitle:title andWithMessageBody:body  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalBackGround];
    }
    completionHandler(); // 系统要求执行这个方法
}
#else
#pragma mark iOS10以下本地消息处理

/**
 收到本地通知

 @param application application
 @param notification 消息
 */
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(application.applicationState==UIApplicationStateActive){
        [self applicationDidReciveMessageWithMessageTitle:notification.alertTitle andWithMessageBody:notification.alertBody  andWithMessageInfo:notification.userInfo andWithMessageType:HGBPushNotificatonTypeLocalActive];

    }else if(application.applicationState==UIApplicationStateInactive){
        [self applicationDidReciveMessageWithMessageTitle:notification.alertTitle andWithMessageBody:notification.alertBody  andWithMessageInfo:notification.userInfo andWithMessageType:HGBPushNotificatonTypeLocalInActive];

    }else if(application.applicationState==UIApplicationStateBackground){
        [self applicationDidReciveMessageWithMessageTitle:notification.alertTitle andWithMessageBody:notification.alertBody  andWithMessageInfo:notification.userInfo andWithMessageType:HGBPushNotificatonTypeLocalBackGround];
    }


}
/**
 本地通知事件

 @param application application
 @param identifier 标识
 @param notification 消息
 @param completionHandler 完成
 */
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    if(application.applicationState==UIApplicationStateActive){
        [self applicationDidReciveMessageWithMessageTitle:notification.alertTitle andWithMessageBody:notification.alertBody andWithMessageInfo:notification.userInfo andWithMessageType:HGBPushNotificatonTypeLocalActive];

    }else if(application.applicationState==UIApplicationStateInactive){
        [self applicationDidReciveMessageWithMessageTitle:notification.alertTitle andWithMessageBody:notification.alertBody  andWithMessageInfo:notification.userInfo andWithMessageType:HGBPushNotificatonTypeLocalInActive];

    }else if(application.applicationState==UIApplicationStateBackground){
        [self applicationDidReciveMessageWithMessageTitle:notification.alertTitle andWithMessageBody:notification.alertBody  andWithMessageInfo:notification.userInfo andWithMessageType:HGBPushNotificatonTypeLocalBackGround];
    }


}
#pragma mark iOS10以下远程消息处理
/**
 收到远程通知

 @param application application
 @param userInfo 信息
 @param completionHandler 完成
 */
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    if(application.applicationState==UIApplicationStateActive){
         [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalActive];

    }else if(application.applicationState==UIApplicationStateInactive){
       [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalInActive];

    }else if(application.applicationState==UIApplicationStateBackground){
         [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalBackGround];
    }

    // 1.打开后台模式 2.告诉系统是否有新内容的更新 3.发送的通知有固定的格式("content-available":"1")
    // 2.告诉系统有新内容
    completionHandler(UIBackgroundFetchResultNewData);
}
/**
 远程通知事件

 @param application application
 @param identifier 标识
 @param userInfo 消息
 @param completionHandler 完成
 */
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if(application.applicationState==UIApplicationStateActive){
        [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalActive];

    }else if(application.applicationState==UIApplicationStateInactive){
        [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalInActive];

    }else if(application.applicationState==UIApplicationStateBackground){
        [self applicationDidReciveMessageWithMessageTitle:nil andWithMessageBody:nil  andWithMessageInfo:userInfo andWithMessageType:HGBPushNotificatonTypeLocalBackGround];
    }
}
#endif


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
#pragma mark 工具
/**
 把Json对象转化成json字符串

 @param object json对象
 @return json字符串
 */
- (NSString *)ObjectToJSONString:(id)object
{
    if(!([object isKindOfClass:[NSDictionary class]]||[object isKindOfClass:[NSArray class]]||[object isKindOfClass:[NSString class]])){
        return @"";
    }
    if([object isKindOfClass:[NSString class]]){
        return object;
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}
#pragma mark BundleID
/**
 获取BundleID

 @return BundleID
 */
-(NSString*) getBundleID

{

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

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


#pragma mark url
/**
 判断路径是否是URL

 @param url url路径
 @return 结果
 */
-(BOOL)isURL:(NSString*)url{
    if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"/User"]||[url hasPrefix:@"/var"]||[url hasPrefix:@"http://"]||[url hasPrefix:@"https://"]||[url hasPrefix:@"file://"]){
        return YES;
    }else{
        return NO;
    }
}
/**
 url校验存在

 @param url url
 @return 是否存在
 */
-(BOOL)urlExistCheck:(NSString *)url{
    if(url==nil||url.length==0){
        return NO;
    }
    if(![self isURL:url]){
        return NO;
    }
     url=[self urlAnalysis:url];
    if(![url containsString:@"://"]){
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    if([url hasPrefix:@"file://"]){
        NSString *filePath=[[NSURL URLWithString:url]path];
        if(filePath==nil||filePath.length==0){
            return NO;
        }
        NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
        return [filemanage fileExistsAtPath:filePath];
    }else{
        NSURL *urlCheck=[NSURL URLWithString:url];

        return [[UIApplication sharedApplication]canOpenURL:urlCheck];

    }
}
/**
 url解析

 @return 解析后url
 */
-(NSString *)urlAnalysisToPath:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![self isURL:url]){
        return nil;
    }
    NSString *urlstr=[self urlAnalysis:url];
    return [[NSURL URLWithString:urlstr]path];
}
/**
 url解析

 @return 解析后url
 */
-(NSString *)urlAnalysis:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![self isURL:url]){
        return nil;
    }
    if([url containsString:@"://"]){
        //project://工程包内
        //home://沙盒路径
        //http:// https://网络路径
        //document://沙盒Documents文件夹
        //caches://沙盒Caches
        //tmp://沙盒Tmp文件夹
        if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]){
            if([url hasPrefix:@"project://"]){
                url=[url stringByReplacingOccurrencesOfString:@"project://" withString:@""];
                NSString *projectPath=[[NSBundle mainBundle]resourcePath];
                url=[projectPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"home://"]){
                url=[url stringByReplacingOccurrencesOfString:@"home://" withString:@""];
                NSString *homePath=NSHomeDirectory();
                url=[homePath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"document://"]){
                url=[url stringByReplacingOccurrencesOfString:@"document://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"defaults://"]){
                url=[url stringByReplacingOccurrencesOfString:@"defaults://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"caches://"]){
                url=[url stringByReplacingOccurrencesOfString:@"caches://" withString:@""];
                NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
                url=[cachesPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"tmp://"]){
                url=[url stringByReplacingOccurrencesOfString:@"tmp://" withString:@""];
                NSString *tmpPath =NSTemporaryDirectory();
                url=[tmpPath stringByAppendingPathComponent:url];
            }
            url=[[NSURL fileURLWithPath:url]absoluteString];

        }else{

        }
    }else {
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
}
/**
 url封装

 @return 封装后url
 */
-(NSString *)urlEncapsulation:(NSString *)url{
    if(![self isURL:url]){
        return nil;
    }
    NSString *homePath=NSHomeDirectory();
    NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
    NSString *projectPath=[[NSBundle mainBundle]resourcePath];
    NSString *tmpPath =NSTemporaryDirectory();

    if([url hasPrefix:@"file://"]){
        url=[url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    if([url hasPrefix:projectPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",projectPath] withString:@"project://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",projectPath] withString:@"project://"];
    }else if([url hasPrefix:documentPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",documentPath] withString:@"defaults://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",documentPath] withString:@"defaults://"];
    }else if([url hasPrefix:cachesPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",cachesPath] withString:@"caches://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",cachesPath] withString:@"caches://"];
    }else if([url hasPrefix:tmpPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",tmpPath] withString:@"tmp://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",tmpPath] withString:@"tmp://"];
    }else if([url hasPrefix:homePath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",homePath] withString:@"home://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",homePath] withString:@"home://"];
    }else if([url containsString:@"://"]){

    }else{
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
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

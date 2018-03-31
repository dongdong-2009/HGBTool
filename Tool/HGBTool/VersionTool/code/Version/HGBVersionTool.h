//
//  HGBVersionTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/11/16.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */


@interface HGBVersionTool : NSObject
#pragma mark 单例
+(instancetype)shareInstance;
#pragma mark 功能
/**
 下载应用

 @param plistUrl manifest.plist url
 @return 结果
 */
+(BOOL)downLoadAppWithManifestPlistUrl:(NSString *)plistUrl;

/**
 打开appstore应用界面

 @param appId appid
 @param reslut 结果
 */
-(void)openAppInAppStoreWithAppID:(NSString *)appId andWithReslut:(void(^)(BOOL status,NSDictionary *message))reslut;

/**
 打开appstore应用界面

 @param appId appid
 */
+(BOOL)openAppInAppStoreWithAppID:(NSString *)appId;

/**
 打开appstore应用评价界面

 @param appId appid
 */
+(BOOL)openAppVerbInAppStoreWithAppID:(NSString *)appId;
/**
 获取appstore应用信息

 @param appId appid
 @param reslut 结果
 */
+(void)getAppInfoFromAppStoreWithAppID:(NSString *)appId andWithReslut:(void(^)(BOOL status,NSDictionary *message))reslut;
@end

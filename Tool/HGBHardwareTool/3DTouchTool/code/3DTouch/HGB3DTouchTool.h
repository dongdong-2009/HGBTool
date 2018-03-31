//
//  HGB3DTouchTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/28.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HGBAppIcon3DTouchModel.h"

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif



/**
 3DTocuh类型
 */
typedef enum HGB3DTouchType
{
    HGB3DTouchTypeIconLanuch,//APP启动3DTouch
    HGB3DTouchTypeIconActive//将要后台进前台3DTouch
//    HGB3DTouchTypeView//view的3DTouch

}HGB3DTouchType;


/**
 3DTocuh事件

 @param touchType  3DTocuh类型
 @param title 标题
 @param subTitle 副标题
 @param type 3DTocuh自定义类型
 @param userInfo 3DTocuh信息
 */
typedef void (^HGBAppIcon3DTouchMonitorReslutBlock)(HGB3DTouchType touchType,NSString *title,NSString *subTitle,NSString *type,NSDictionary *userInfo);

@interface HGB3DTouchTool : NSObject
/**
 单例

 @return 单例
 */
+(instancetype)shareInstance;

/**
 结果监听
 */
@property(strong,nonatomic)HGBAppIcon3DTouchMonitorReslutBlock monitorReslut;
/**
 创建3DTouch

 @param dataSource 数据源
 */
-(BOOL)create3DTouchWithData:(NSArray <HGBAppIcon3DTouchModel *>*)dataSource;

/**
 发送3DTouch信息

 @param touchType  3DTocuh类型
 @param title 标题
 @param subTitle 副标题
 @param type 3DTocuh自定义类型
 @param userInfo 3DTocuh信息
 */
-(void)sendAppIcon3DTocuhMessageWith3DTouchType:(HGB3DTouchType )touchType andWithTitle:(NSString *)title andWithSubTitle:(NSString *)subTitle andWithType:(NSString *)type andWithUserInfo:(NSDictionary *)userInfo;
@end
